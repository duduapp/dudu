import 'package:fastodon/models/local_account.dart';
import 'package:fastodon/models/provider/settings_provider.dart';
import 'package:fastodon/pages/login/login.dart';
import 'package:fastodon/pages/setting/account_switch.dart';
import 'package:fastodon/widget/setting/setting_cell.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/widget/common/bottom_sheet_item.dart';
import 'package:fastodon/widget/dialog/single_choice_dialog.dart';
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
    Storage.getInt('mastodon.text_scale').then((value) {
      if (value != null) {
        setState(() {
          textScale = value;
        });
      }
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
              BottomSheetItem(
                text: '取消',
                onTap: () => AppNavigate.pop(context),
                safeArea: true,
              )
            ],
          ),
        ));
  }
  _onConfirmExit() async{
    await LocalStorageAccount.logout();
    AppNavigate.pushAndRemoveUntil(context, Login(),routeType: RouterType.fade);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('通用设置'),
        centerTitle: false,
      ),
      body: ListView(
        children: <Widget>[
          SettingCell(
            leftIcon: Icon(Icons.color_lens),
            title: '应用主题',
            onPress: () => showDialog(
                context: context,
                builder: (_) => ThemeConsumer(child: ThemeDialog(title: Text('选择主题'),hasDescription: false,))),
          ),
          ProviderSettingCell(
            providerKey: 'text_scale',
            leftIcon: Icon(Icons.font_download),
            title: '字体大小',
            options: ['0','1','2'],
            displayOptions: ['小','中','大'],
            type: SettingType.string,
          ),
          SizedBox(height: 30,),
          SettingCellText(
            text: Text('切换账号',style: TextStyle(fontSize: 16),),
            onPressed: () => AppNavigate.push(context, AccountSwitch(),routeType: RouterType.material),
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
