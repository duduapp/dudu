import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dudu/pages/timeline/timeline.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/device_util.dart';
import 'package:dudu/utils/dialog_util.dart';
import 'package:dudu/widget/common/normal_flat_button.dart';
import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';

class UpdateTask {
  static String key = "gityp34dkg" +
      TimelineType.federated.toString().split(".")[1].substring(0, 5);
  static Future<bool> check() async {
    var rnd = StringUtil.getRandomString(20);
    try {
      String appId = await DeviceUtil.getAppId();
      String checkUpdateUrl = "https://api.idudu.fans/app/android/update_check?auth=$rnd&id=$appId";
      debugPrint(checkUpdateUrl);
      Response response = await Dio().get(checkUpdateUrl);

      var data = response.data;
      if (data == null) {
        return true;
      }

      Storage.saveString(StorageKey.lastCheckUpdateTime, DateTime.now().toIso8601String());

      var auth = data['auth'];

      if (sha256.convert(utf8.encode(rnd + key)).toString() == auth) {
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        String version = packageInfo.version;

        if (version != data['version']) {
          // a new version is released
          DialogUtils.showSimpleAlertDialog(
              context: navGK.currentState.overlay.context,
              text: data['text'],
              confirmText: '更新',
              cancelText: '关闭程序',
              onConfirm: () async {
                DialogUtils.showRoundedDialog(
                    context: navGK.currentState.overlay.context,
                    content: ApkDownloadProgress(
                      url: data['apk_url'],
                    ));
              },
              onCancel: () async {
                exit(0);
              },
              barrierDismissible: false);
          return false;
        }
      }
      return true;
    } catch (e) {return true;}
  }

  static checkUpdateIfNeed() async{
    if (await needCheckUpdate())
      check();
  }

  // one day to send on request
  static needCheckUpdate() async{
    String lastUpdateTime = await Storage.getString(StorageKey.lastCheckUpdateTime);
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

  @override
  void initState() {
   startDownload();
    super.initState();
  }

  startDownload() async {
    savePath = (await getApplicationDocumentsDirectory()).path + widget.url.split("/").last;
    var res = await Dio().download(widget.url, savePath,
        onReceiveProgress: (count, total) {
      setState(() {
        this.download = count;
        this.total = total;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('下载中...'),
          SizedBox(height: 10,),
          SizedBox(
            height: 20,
            child: LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).buttonColor),
              value: total == 0 ? 0.01 : download/total,
            ),
          ),
          SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              NormalFlatButton(
                text: '取消',
                onPressed: () => AppNavigate.pop(),
              ),
              SizedBox(width: 10,),
              if (download != 0 && download == total)
                NormalFlatButton(
                  text: '安装',
                  onPressed: () async{
                    var res = await OpenFile.open(savePath);
                  },
                )
            ],
          )
        ],
      ),
    );
  }
}
