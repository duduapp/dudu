import 'package:dudu/l10n/l10n.dart';
import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/models/instance/instance_manager.dart';
import 'package:dudu/models/local_account.dart';
import 'package:dudu/models/logined_user.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/pages/home_page.dart';
import 'package:dudu/pages/login/login.dart';
import 'package:dudu/pages/setting/about_app.dart';
import 'package:dudu/pages/setting/account_switch.dart';
import 'package:dudu/pages/setting/setting_content.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/account_util.dart';
import 'package:dudu/widget/common/bottom_sheet_item.dart';
import 'package:dudu/widget/common/custom_app_bar.dart';
import 'package:dudu/widget/setting/setting_cell.dart';
import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart';

class GeneralSetting extends StatefulWidget {
  @override
  _GeneralSettingState createState() => _GeneralSettingState();
}

class _GeneralSettingState extends State<GeneralSetting> {
  int textScale = 1; // 0 , 1 ,2 分别对对应小中大

  @override
  void initState(){
    _getTextScale();
    super.initState();
  }

  _getTextScale() {
    setState(() {
      textScale = Storage.getInt('mastodon.text_scale');
    });
  }

  _onTextScaleChoosed(int idx) {
    setState(() {
      textScale = idx;
    });
    Storage.saveInt('mastodon.text_scale', idx);
    eventBus.emit(EventBusKey.textScaleChanged,idx);
  }

  _onExitPressed() {
    showModalBottomSheet(
        context: context,
        builder: (_) => Container(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              BottomSheetItem(
                text: S.of(context).sign_out,
                onTap: () => _onConfirmExit(),
              ),
              Container(
                height: 8,
                color: Theme.of(context).backgroundColor,
              ),
              BottomSheetCancelItem()
            ],
          ),
        ));
  }
  _onConfirmExit() async{
    await LocalStorageAccount.logout();
    Request.closeHttpClient();
    LoginedUser().logout();
    InstanceManager.removeAll();
    if (LocalStorageAccount.accounts.isNotEmpty) {
      AccountUtil.switchToAccount(LocalStorageAccount.accounts[0]);
    } else {
      SettingsProvider().setHomeTabIndex(2);
      SettingsProvider().setCurrentUser(null);
      AppNavigate.pushAndRemoveUntil(HomePage(logined: false,));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(S.of(context).general_settings),
      ),
      body: ListView(
        children: <Widget>[
          ProviderSettingCell(
            providerKey: 'theme',
            leftIcon: Icon(IconFont.theme),
            title: S.of(context).application_theme,
            options: ['0','1','2'],
            displayOptions: [S.of(context).normal_mode,S.of(context).dark_mode,S.of(context).darkest_mode],
            type: SettingType.string,
          ),
          ProviderSettingCell(
            providerKey: 'language',
            leftIcon: Icon(IconFont.fontSize),
            title: S.of(context).language,
            options: ['zh','en'],
            displayOptions: ['中文','English'],
            type: SettingType.string,
          ),
          ProviderSettingCell(
            providerKey: 'text_scale',
            leftIcon: Icon(IconFont.fontSize),
            title: S.of(context).font_size,
            options: ['0','1','2'],
            displayOptions: [S.of(context).small,S.of(context).medium,S.of(context).big],
            type: SettingType.string,
          ),
          SettingCell(
            leftIcon: Icon(IconFont.display),
            title: S.of(context).display_setting,
            onPress: () => AppNavigate.push(SettingContent()),
          ),


          SettingCell(
            leftIcon: Icon(IconFont.about),
    title: S.of(context).about_dudu,

            onPress: () => AppNavigate.push(AboutApp()),
          ),

          SizedBox(height: 30,),
          SettingCellText(
            text: Text(S.of(context).switch_account,style: TextStyle(fontSize: 16),),
            onPressed: () => AppNavigate.push(AccountSwitch(),routeType: RouterType.material),
          ),
          SizedBox(height: 10,),
          SettingCellText(
            text: Text(S.of(context).sign_out,style: TextStyle(fontSize: 16),),
            onPressed: _onExitPressed,
          ),
        ],
      ),
    );
  }
}
