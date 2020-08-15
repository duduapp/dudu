import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dudu/pages/timeline/timeline.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/dialog_util.dart';
import 'package:dudu/widget/common/normal_flat_button.dart';
import 'package:dudu/widget/flutter_framework/progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:nav_router/nav_router.dart';
import 'package:open_file/open_file.dart';

import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateTask {
  static String key = "gityp34dkg" +
      TimelineType.federated.toString().split(".")[1].substring(0, 5);
  static check() async {
    var rnd = StringUtil.getRandomString(20);
    try {
      Response response =
          await Dio().get("https://api.idudu.fans/app/android/update_check?auth=" + rnd);

      var data = response.data;
      if (data == null) {
        return;
      }
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
        }
      }
    } catch (e) {}
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
