import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/models/logined_user.dart';
import 'package:dudu/pages/setting/account_setting.dart';
import 'package:dudu/pages/setting/bookmarks_list.dart';
import 'package:dudu/pages/setting/edit_user_profile.dart';
import 'package:dudu/pages/setting/general_setting.dart';
import 'package:dudu/pages/setting/lists/lists_page.dart';
import 'package:dudu/pages/status/scheduled_statuses_list.dart';
import 'package:dudu/pages/timeline/conversations_timeline.dart';
import 'package:dudu/public.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../widget/setting/setting_cell.dart';
import 'favourites_list.dart';
import 'setting_head.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> with AutomaticKeepAliveClientMixin {
  ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  Function loginSuccess;

  @override
  void initState() {
    super.initState();


  }

  @override
  void dispose() {

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(top: 0),
      controller: _scrollController,
      children: <Widget>[
        GestureDetector(
            onTap: () {
              // AppNavigate.push(context, UserMessage(account: _account,));
              AppNavigate.push( EditUserProfile(LoginedUser().account,showBottomChooseImage: true,));
            },
            child:  SettingHead(
            )
        ),
        SizedBox(height: 10),
        SettingCell(
          title: '私信',
          leftIcon: Icon(IconFont.message),
          onPress: () => AppNavigate.push(ConversationTimeline()),
        ),
        SettingCell(
          title: '收藏',
          leftIcon: Icon(IconFont.favorite),
          onPress: () => AppNavigate.push(FavouritesList()),
        ),
        SettingCell(
          title: '书签',
          leftIcon: Icon(IconFont.bookmark),
          onPress: () => AppNavigate.push(BookmarksList()),
        ),
        SettingCell(
          title: '列表',
          leftIcon: Icon(IconFont.list),
          onPress: () => AppNavigate.push(ListsPage()),
        ),
        SettingCell(
          title: '定时嘟文',
          leftIcon: Icon(IconFont.time,size: 22,),
          onPress: () => AppNavigate.push(ScheduledStatusesList()),
        ),

        SizedBox(height: 10,),
        SettingCell(
          title: '账号设置',
          leftIcon: Icon(IconFont.accountSetting),
          onPress: () => AppNavigate.push(AccountSetting()),
        ),
        SettingCell(
          title: '通用',
          leftIcon: Icon(IconFont.settings),
          onPress: () => AppNavigate.push(GeneralSetting()),
        ),

        SizedBox(height: 10),

      ],
    );
  }
}