import 'package:dudu/api/accounts_api.dart';
import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/l10n/l10n.dart';
import 'package:dudu/models/logined_user.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/pages/setting/account_setting.dart';
import 'package:dudu/pages/setting/bookmarks_list.dart';
import 'package:dudu/pages/setting/edit_user_profile.dart';
import 'package:dudu/pages/setting/general_setting.dart';
import 'package:dudu/pages/setting/lists/lists_page.dart';
import 'package:dudu/pages/status/scheduled_statuses_list.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/account_util.dart';
import 'package:dudu/utils/i18n_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../widget/setting/setting_cell.dart';
import 'favourites_list.dart';
import 'setting_head.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> with AutomaticKeepAliveClientMixin {
  ScrollController _scrollController = ScrollController();
  RefreshController _refreshController;

  @override
  bool get wantKeepAlive => true;

  Function loginSuccess;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  refresh() async {
    if (LoginedUser().account != null) {
      var newAccount = await AccountsApi.getAccount(LoginedUser().account);
      AccountUtil.updateAccount(newAccount);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    String zan_or_shoucang = context
        .select<SettingsProvider, String>((m) => m.get('zan_or_shoucang'));

    bool isZh = I18nUtil.isZh(context);
    var zan_icon = isZh
        ? (zan_or_shoucang == '0' ? IconFont.thumbUp : IconFont.favorite)
        : IconFont.favorite;
    var zan_text = isZh
        ? (zan_or_shoucang == '0' ? '赞' : S.of(context).favorites)
        : S.of(context).favorites;

    return SmartRefresher(
      header: ClassicHeader(
        releaseText: S.of(context).release_refresh,
        refreshingText: S.of(context).loading,
        completeText: S.of(context).complete_refresh,
        idleText: S.of(context).pull_down_to_refresh,
        releaseIcon: Icon(
          Icons.arrow_upward,
          color: Colors.grey,
        ),
        refreshingIcon: CupertinoActivityIndicator(),
        textStyle:
            TextStyle(fontSize: 12, color: Theme.of(context).accentColor),
      ),
      footer: ClassicFooter(
        loadingText: S.of(context).loading,
        loadingIcon: null,
        idleText: S.of(context).loading,
        idleIcon: null, // 自动加载，所以显示这个
        canLoadingText: S.of(context).release_load_more,
        noDataText: '',
      ),
      enablePullUp: false,
      onRefresh: () async {
        await refresh();
        _refreshController.refreshCompleted();
      },
      controller: _refreshController,
      child: ListView(
        padding: EdgeInsets.only(top: 0),
        children: <Widget>[
          GestureDetector(
              onTap: () {
                // AppNavigate.push(context, UserMessage(account: _account,));
                AppNavigate.push(EditUserProfile(
                  LoginedUser().account,
                  showBottomChooseImage: true,
                ));
              },
              child: SettingHead()),
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
            leftIcon: Icon(
              IconFont.time,
              size: 22,
            ),
            onPress: () => AppNavigate.push(ScheduledStatusesList()),
          ),
          SizedBox(
            height: 10,
          ),
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
      ),
    );
  }
}
