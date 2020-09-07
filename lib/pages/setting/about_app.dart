import 'package:dudu/models/task/update_task.dart';
import 'package:dudu/pages/webview/inner_browser.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/device_util.dart';
import 'package:dudu/utils/dialog_util.dart';
import 'package:dudu/widget/common/custom_app_bar.dart';
import 'package:dudu/widget/flutter_framework/progress_dialog.dart';
import 'package:dudu/widget/setting/setting_cell.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

class AboutApp extends StatefulWidget {
  @override
  _AboutAppState createState() => _AboutAppState();
}

class _AboutAppState extends State<AboutApp> {
  String version;
  String appName;

  @override
  void initState() {
    _getVersion();
    super.initState();
  }

  _getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version + '版';
      appName = packageInfo.appName;
    });
  }

  @override
  Widget build(BuildContext context) {
    DeviceUtil.generateAppId();
    return Scaffold(
      appBar: CustomAppBar(
        title: Text('关于嘟嘟'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            header(),
            SizedBox(
              height: 20,
            ),
            SettingCell(
              title: '检查更新',
              onPress: _checkUpdate,
            ),
            SettingCell(
              title: '版权信息',
              onPress: () => showLicensePage(
                  context: context,
                  applicationIcon: appIcon(),
                  applicationName: appName,
                  applicationVersion: version),
            ),
            SettingCell(
              title: '官方网站',
              subTitleStyle: TextStyle(fontSize: 12,color: Theme.of(context).buttonColor),
              onPress: () => AppNavigate.push(InnerBrowser('http://dudu.today')),
            )
          ],
        ),
      ),
    );
  }

  _checkUpdate() async{
    ProgressDialog dialog = await DialogUtils.showProgressDialog('正在检查新版本');
    bool newestVersion = await UpdateTask.check(dialog: dialog);
    dialog.hide();
    if (newestVersion) {
      DialogUtils.showInfoDialog(context, '当前版本已是最新版本');
    }
  }

  Widget appIcon() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image(
        fit: BoxFit.cover,
        height: 80,
        width: 80,
        image: AssetImage('assets/images/icon.jpg'),
      ),
    );
  }

  Widget header() {
    return Container(
      padding: EdgeInsets.only(top: 25),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          appIcon(),
          SizedBox(
            height: 9,
          ),
          Text(
            '嘟嘟',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic),
          ),
          SizedBox(
            height: 1,
          ),
          Text(
            version ?? '',
            style: TextStyle(color: Theme.of(context).buttonColor),
          )
        ],
      ),
    );
  }
}
