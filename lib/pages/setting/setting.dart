import 'dart:math';

import 'package:fastodon/api/accounts_api.dart';
import 'package:fastodon/models/local_account.dart';
import 'package:fastodon/pages/setting/account_setting.dart';
import 'package:fastodon/pages/setting/bookmarks_list.dart';
import 'package:fastodon/pages/setting/edit_user_profile.dart';
import 'package:fastodon/pages/setting/general_setting.dart';
import 'package:fastodon/pages/setting/lists/lists_page.dart';
import 'package:fastodon/pages/status/scheduled_statuses_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:fastodon/public.dart';

import 'package:fastodon/models/my_account.dart';
import 'package:fastodon/models/owner_account.dart';
import 'package:fastodon/models/user.dart';

import '../user_profile/user_profile.dart';
import 'setting_head.dart';
import 'setting_cell.dart';
import 'about_app.dart';
import 'favourites_list.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> with AutomaticKeepAliveClientMixin {
  OwnerAccount _account;
  bool _finishRequest = false;
  ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  Function loginSuccess;

  @override
  void initState() {
    super.initState();
    loginSuccess = (arg) async{
      await _getMyAccount();
    };
    eventBus.on(EventBusKey.LoadLoginMegSuccess, loginSuccess);

    eventBus.on(EventBusKey.accountUpdated,(arg) {
      _getMyAccount();
    });
  }

  @override
  void dispose() {
    eventBus.off(EventBusKey.LoadLoginMegSuccess,loginSuccess);
    eventBus.off(EventBusKey.accountUpdated);
    super.dispose();
  }

  Future<void> _getMyAccount() async {
    OwnerAccount account = await AccountsApi.getMyAccount();
    LocalStorageAccount.addOwnerAccount(account);
    MyAccount saveAcc = new MyAccount();
    saveAcc.setAcc(account);
    saveAcc.requestPrefrence();
    setState(() {
      _finishRequest = true;
      _account = account;
    });
  }

  void showAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("提示"),
          content: Text("确定要退出登录"),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text("取消"),
              onPressed: () {
                Navigator.pop(context, 'Cancel');
              }
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text("确定"),
              onPressed: () {
                // 清除单例保存的内容
                MyAccount saveAcc = new MyAccount();
                saveAcc.removeAcc();
                // 清除本地存储的内容
                Storage.removeString(StorageKey.HostUrl);
                Storage.removeString(StorageKey.Token);

                Navigator.pop(context, 'Cancel');
                // 弹出登录页面
                eventBus.emit(EventBusKey.ShowLoginWidget);
              }
            )
          ],
        );
      }
    );
  }

  Widget settingWidget() {
    return ListView(
      padding: EdgeInsets.only(top: 0),
      controller: _scrollController,
      children: <Widget>[
        GestureDetector(
          onTap: () {
           // AppNavigate.push(context, UserMessage(account: _account,));
            AppNavigate.push(context, EditUserProfile(_account));
          },
          child: SettingHead(
            account: _account,
          )
        ),
        SizedBox(height: 10),
        SettingCell(
          title: '收藏',
          leftIcon: Icon(Icons.favorite),
          onPress: () => AppNavigate.push(context, FavouritesList()),
        ),
        SettingCell(
          title: '书签',
          leftIcon: Icon(Icons.bookmark),
          onPress: () => AppNavigate.push(context, BookmarksList()),
        ),
        SettingCell(
          title: '列表',
          leftIcon: Icon(Icons.list),
          onPress: () => AppNavigate.push(context, ListsPage()),
        ),
        SettingCell(
          title: '定时嘟文',
          leftIcon: Icon(Icons.access_time),
          onPress: () => AppNavigate.push(context, ScheduledStatusesList()),
        ),

        SizedBox(height: 10,),
        SettingCell(
          title: '账号设置',
          leftIcon: Icon(Icons.account_box),
          onPress: () => AppNavigate.push(context, AccountSetting()),
        ),
        SettingCell(
          title: '通用',
          leftIcon: Icon(Icons.settings),
          onPress: () => AppNavigate.push(context, GeneralSetting()),
        ),

        SizedBox(height: 10),

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingWidget(
      endLoading: _finishRequest,
      childWidget: settingWidget(),
    );
  }
}