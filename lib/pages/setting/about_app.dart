import 'package:dudu/l10n/l10n.dart';
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
      version = S.of(context).version_info(packageInfo.version);
      appName = packageInfo.appName;
    });
  }

  @override
  Widget build(BuildContext context) {
    DeviceUtil.generateAppId();
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(S.of(context).about_dudu),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            header(),
            SizedBox(
              height: 20,
            ),
            SettingCell(
              title: S.of(context).check_for_updates,
              onPress: _checkUpdate,
            ),
            SettingCell(
              title: S.of(context).copyright_information,
              onPress: () => showLicensePage(
                  context: context,
                  applicationIcon: appIcon(),
                  applicationName: appName,
                  applicationVersion: version),
            ),
            SettingCell(
              title: S.of(context).official_website,
              subTitleStyle:
                  TextStyle(fontSize: 12, color: Theme.of(context).buttonColor),
              onPress: () =>
                  AppNavigate.push(InnerBrowser('http://dudu.today')),
            ),
            SizedBox(
              height: 150,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  child: Text(
                    S.of(context).privacy_agreement,
                    style: TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                  onTap: () => AppNavigate.push(
                      InnerBrowser('http://dudu.today/privacy.html')),
                ),
                SizedBox(
                  width: 10,
                ),
                InkWell(
                    child: Text(S.of(context).service_agreement,
                        style: TextStyle(color: Colors.blue, fontSize: 12)),
                    onTap: () => AppNavigate.push(
                        InnerBrowser('http://dudu.today/contract.html')))
              ],
            )
          ],
        ),
      ),
    );
  }

  _checkUpdate() async {
    ProgressDialog dialog = await DialogUtils.showProgressDialog(
        S.of(context).checking_for_new_version);
    bool newestVersion = await UpdateTask.check(context, dialog: dialog);
    dialog.hide();
    if (newestVersion) {
      DialogUtils.showInfoDialog(
          context, S.of(context).the_current_version_is_the_latest_version);
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
            S.of(context).app_name,
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
