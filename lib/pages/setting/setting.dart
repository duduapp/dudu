import 'package:fastodon/api/accounts_api.dart';
import 'package:fastodon/models/json_serializable/owner_account.dart';
import 'package:fastodon/models/local_account.dart';
import 'package:fastodon/models/logined_user.dart';
import 'package:fastodon/pages/setting/account_setting.dart';
import 'package:fastodon/pages/setting/bookmarks_list.dart';
import 'package:fastodon/pages/setting/edit_user_profile.dart';
import 'package:fastodon/pages/setting/general_setting.dart';
import 'package:fastodon/pages/setting/lists/lists_page.dart';
import 'package:fastodon/pages/status/scheduled_statuses_list.dart';
import 'package:fastodon/pages/timeline/conversations_timeline.dart';
import 'package:fastodon/public.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

import '../../widget/setting/setting_cell.dart';
import 'favourites_list.dart';
import 'setting_head.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> with AutomaticKeepAliveClientMixin {
  OwnerAccount _account;
  ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  Function loginSuccess;

  @override
  void initState() {
    super.initState();
    _account = LoginedUser().account;

    if (_account == null) {
      _getMyAccount();
    }
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
    LoginedUser().account = account;
    setState(() {
      _account = account;
    });
  }


  Widget settingWidget() {
    return ListView(
      padding: EdgeInsets.only(top: 0),
      controller: _scrollController,
      children: <Widget>[
        GestureDetector(
          onTap: () {
           // AppNavigate.push(context, UserMessage(account: _account,));
            AppNavigate.push( EditUserProfile(_account));
          },
          child: SettingHead(
            account: _account,
          )
        ),
        SizedBox(height: 10),
        SettingCell(
          title: '私信',
          leftIcon: Icon(Icons.mail_outline),
          onPress: () => AppNavigate.push(ConversationTimeline()),
        ),
        SettingCell(
          title: '赞',
          leftIcon: Icon(OMIcons.thumbUp),
          onPress: () => AppNavigate.push(FavouritesList()),
        ),
        SettingCell(
          title: '书签',
          leftIcon: Icon(Icons.bookmark_border),
          onPress: () => AppNavigate.push(BookmarksList()),
        ),
        SettingCell(
          title: '列表',
          leftIcon: Icon(Icons.list),
          onPress: () => AppNavigate.push(ListsPage()),
        ),
        SettingCell(
          title: '定时嘟文',
          leftIcon: Icon(Icons.access_time),
          onPress: () => AppNavigate.push(ScheduledStatusesList()),
        ),

        SizedBox(height: 10,),
        SettingCell(
          title: '账号设置',
          leftIcon: Icon(OMIcons.accountBox),
          onPress: () => AppNavigate.push(AccountSetting()),
        ),
        SettingCell(
          title: '通用',
          leftIcon: Icon(OMIcons.settings),
          onPress: () => AppNavigate.push(GeneralSetting()),
        ),

        SizedBox(height: 10),

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return settingWidget();
  }
}