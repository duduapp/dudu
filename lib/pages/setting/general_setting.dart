import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/models/local_account.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/pages/login/login.dart';
import 'package:dudu/pages/setting/about_app.dart';
import 'package:dudu/pages/setting/account_switch.dart';
import 'package:dudu/pages/setting/setting_content.dart';
import 'package:dudu/public.dart';
import 'package:dudu/widget/common/bottom_sheet_item.dart';
import 'package:dudu/widget/common/custom_app_bar.dart';
import 'package:dudu/widget/setting/setting_cell.dart';
import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart';
import 'package:theme_provider/theme_provider.dart';

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
                text: '退出登录',
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
    AppNavigate.pushAndRemoveUntil(Login(),routeType: RouterType.fade);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text('通用设置'),
      ),
      body: ListView(
        children: <Widget>[
          SettingCell(
            leftIcon: Icon(IconFont.theme),
            title: '应用主题',
            onPress: () => showDialog(
                context: context,
                builder: (_) => ThemeConsumer(child: ThemeDialog(title: Text('选择主题'),hasDescription: false,selectedOverlayColor: Theme.of(context).buttonColor,))),
          ),
          ProviderSettingCell(
            providerKey: 'text_scale',
            leftIcon: Icon(IconFont.fontSize),
            title: '字体大小',
            options: ['0','1','2'],
            displayOptions: ['小','中','大'],
            type: SettingType.string,
          ),
          SettingCell(
            leftIcon: Icon(IconFont.display),
            title: '显示设置',
            onPress: () => AppNavigate.push(SettingContent()),
          ),


          SettingCell(
            leftIcon: Icon(IconFont.about),
    title: '关于嘟嘟',

            onPress: () => AppNavigate.push(AboutApp()),
          ),

          SizedBox(height: 30,),
          SettingCellText(
            text: Text('切换账号',style: TextStyle(fontSize: 16),),
            onPressed: () => AppNavigate.push(AccountSwitch(),routeType: RouterType.material),
          ),
          SizedBox(height: 10,),
          SettingCellText(
            text: Text('退出登录',style: TextStyle(fontSize: 16),),
            onPressed: _onExitPressed,
          ),
        ],
      ),
    );
  }
}
