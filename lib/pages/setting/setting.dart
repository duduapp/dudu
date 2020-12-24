import 'package:dudu/l10n/l10n.dart';
import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/models/logined_user.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/pages/setting/account_setting.dart';
import 'package:dudu/pages/setting/bookmarks_list.dart';
import 'package:dudu/pages/setting/edit_user_profile.dart';
import 'package:dudu/pages/setting/general_setting.dart';
import 'package:dudu/pages/setting/lists/lists_page.dart';
import 'package:dudu/pages/status/scheduled_statuses_list.dart';
import 'package:dudu/pages/timeline/conversations_timeline.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/i18n_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../widget/setting/setting_cell.dart';
import 'favourites_list.dart';
import 'setting_head.dart';
import 'package:provider/provider.dart';

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
    String  zan_or_shoucang =
    context.select<SettingsProvider, String>((m) => m.get('zan_or_shoucang'));

    bool isZh = I18nUtil.isZh(context);
    var zan_icon = isZh ? (zan_or_shoucang == '0' ? IconFont.thumbUp : IconFont.favorite) : IconFont.favorite;
    var zan_text = isZh ? (zan_or_shoucang == '0' ? '赞' : S.of(context).favorites) : S.of(context).favorites;

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
          title: zan_text,
          leftIcon: Icon(zan_icon),
          onPress: () => AppNavigate.push(FavouritesList()),
        ),
        SettingCell(
          title: S.of(context).bookmark,
          leftIcon: Icon(IconFont.bookmark),
          onPress: () => AppNavigate.push(BookmarksList()),
        ),
        SettingCell(
          title: S.of(context).list,
          leftIcon: Icon(IconFont.list),
          onPress: () => AppNavigate.push(ListsPage()),
        ),
        SettingCell(
          title: S.of(context).timed_beep,
          leftIcon: Icon(IconFont.time,size: 22,),
          onPress: () => AppNavigate.push(ScheduledStatusesList()),
        ),

        SizedBox(height: 10,),
        SettingCell(
          title: S.of(context).account_settings,
          leftIcon: Icon(IconFont.accountSetting),
          onPress: () => AppNavigate.push(AccountSetting()),
        ),
        SettingCell(
          title: S.of(context).universal,
          leftIcon: Icon(IconFont.settings),
          onPress: () => AppNavigate.push(GeneralSetting()),
        ),

        SizedBox(height: 10),

      ],
    );
  }
}