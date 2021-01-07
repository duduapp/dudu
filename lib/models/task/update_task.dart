import 'package:dudu/l10n/l10n.dart';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dudu/constant/db_key.dart';
import 'package:dudu/models/logined_user.dart';
import 'package:dudu/models/runtime_config.dart';
import 'package:dudu/pages/timeline/timeline.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/device_util.dart';
import 'package:dudu/utils/dialog_util.dart';
import 'package:dudu/utils/url_util.dart';
import 'package:dudu/widget/common/normal_flat_button.dart';
import 'package:dudu/widget/flutter_framework/progress_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nav_router/nav_router.dart';

import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateTask {
  static const logined = 10;
  static const notLogin = 12;
  
  static String key = "gityp34dkg" +
      TimelineType.federated.toString().split(".")[1].substring(0, 5);
  static Future<bool> check({ProgressDialog dialog}) async {
    debugPrint('checking update');
    if (RuntimeConfig.updateWindowDisplayed) return false;
    var rnd = StringUtil.getRandomString(20);
    try {
      String appId = await DeviceUtil.getAppId();
      String checkUpdateUrl;
      int state = LoginedUser().account != null ? logined : notLogin;
      if (Platform.isAndroid) {
        checkUpdateUrl =
            "http://api.idudu.fans/app/android/check_update?auth=$rnd&id=$appId&state=$state";
      } else if (Platform.isIOS) {
        checkUpdateUrl =
            "http://api.idudu.fans/app/ios/check_update?auth=$rnd&id=$appId&state=$state";
      }
      if (!kReleaseMode) {
        checkUpdateUrl = 'aaa';
      }
      debugPrint(checkUpdateUrl);
      Response response = await Dio().get(checkUpdateUrl);

      var data = response.data;
      if (data == null) {
        return true;
      }

      var auth = data['auth'];

      if (sha256.convert(utf8.encode(rnd + key)).toString() == auth) {
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        var version = Version.parse(packageInfo.version);
        var newestVersion = Version.parse(data['version']);
        if (version < newestVersion) {
          dialog?.hide();
          RuntimeConfig.updateWindowDisplayed = true;
          // a new version is released
//          DialogUtils.showSimpleAlertDialog(
//              context: navGK.currentState.overlay.context,
//              text: data['text'],
//              confirmText: S.of(context).update,
//              cancelText: S.of(context).turn_off_an_app,
//              onConfirm: () async {
//                DialogUtils.showRoundedDialog(
//                    context: navGK.currentState.overlay.context,
//                    content: ApkDownloadProgress(
//                      url: data['apk_url'],
//                    ));
//              },
//              onCancel: () async {
//                exit(0);
//              },
//              popAfter: false,
//              barrierDismissible: false,);
          await DialogUtils.showRoundedDialog(
              content: UpdateWindow(
                prompt: data['text'],
                apkUrl: data['apk_url'],
              ),
              context: navGK.currentState.overlay.context,
              barrierDismissible: false);
          RuntimeConfig.updateWindowDisplayed = false;
          return false;
        } else {
          DateUntil.markTime('', DbKey.lastCheckUpdateTime);
        }
      }
      return true;
    } catch (e) {
      return true;
    }
  }

  static checkUpdateIfNeed() async {

    if (!DateUntil.hasMarkedTimeDaily(StorageKey.lastCheckUpdateTime) &&
        !(await DateUntil.hasMarkedTimeToday('', DbKey.lastCheckUpdateTime)))
      check();
  }

  // one day to send on request
  static needCheckUpdate() async {
    String lastUpdateTime =
        await Storage.getString(StorageKey.lastCheckUpdateTime);
    if (lastUpdateTime == null) {
      return true;
    }
    var now = DateTime.now();
    var updateTime = DateTime.parse(lastUpdateTime);

    if (now.difference(updateTime).inDays >= 1 || now.day != updateTime.day) {
      return true;
    }
    return false;
  }
}

class UpdateWindow extends StatelessWidget {
  final String prompt;
  final String apkUrl;

  const UpdateWindow({Key key, this.prompt, this.apkUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Container(
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    S.of(context).new_version_detected,
                    style: TextStyle(fontSize: 18),
                  ),
//                NormalFlatButton(
//                    text: S.of(context).copy_the_download_link,
//                    onPressed: () {
//                      Clipboard.setData(new ClipboardData(text: apkUrl));
//                      DialogUtils.toastFinishedInfo(S.of(context).download_link_copied);
//                    }),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Text(prompt),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  NormalFlatButton(
                    text: S.of(context).turn_off_an_app,
                    onPressed: () => exit(0),
                  ),
                  NormalFlatButton(
                    text: S.of(context).update,
                    onPressed: () async {
                      UrlUtil.openUrl(apkUrl);
                    },
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ApkDownloadProgress extends StatefulWidget {
  final String url;

  const ApkDownloadProgress({Key key, this.url}) : super(key: key);

  @override
  _ApkDownloadProgressState createState() => _ApkDownloadProgressState();
}

class _ApkDownloadProgressState extends State<ApkDownloadProgress> {
  int download = 0;
  int total = 0;
  String savePath;
  CancelToken cancelToken;

  @override
  void initState() {
    cancelToken = CancelToken();
    startDownload();
    super.initState();
  }

  startDownload() async {
    savePath = (await getApplicationDocumentsDirectory()).path +
        widget.url.split("/").last;
    try {
      var res = await Dio().download(widget.url, savePath,
          cancelToken: cancelToken, onReceiveProgress: (count, total) {
        setState(() {
          this.download = count;
          this.total = total;
        });
      });
    } catch (e) {
      // do nothing
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(S.of(context).downloading),
          SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 20,
            child: LinearProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(Theme.of(context).buttonColor),
              value: total == 0 ? 0.01 : download / total,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              NormalFlatButton(
                text: S.of(context).cancel,
                onPressed: () {
                  cancelToken.cancel();
                  AppNavigate.pop();
                },
              ),
              SizedBox(
                width: 10,
              ),
              if (download != 0 && download == total)
                NormalFlatButton(
                  text: S.of(context).installation,
                  onPressed: () async {
                    //   var res = await OpenFile.open(savePath);
                  },
                )
            ],
          )
        ],
      ),
    );
  }
}
