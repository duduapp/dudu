import 'package:dudu/l10n/l10n.dart';
import 'package:badges/badges.dart';
import 'package:dudu/api/notification_api.dart';
import 'package:dudu/api/timeline_api.dart';
import 'package:dudu/constant/api.dart';
import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/models/json_serializable/notificate_item.dart';
import 'package:dudu/models/local_account.dart';
import 'package:dudu/models/logined_user.dart';
import 'package:dudu/models/notification/NotificationType.dart';
import 'package:dudu/models/provider/result_list_provider.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/models/runtime_config.dart';
import 'package:dudu/pages/login/login.dart';
import 'package:dudu/pages/search/search_page_delegate.dart';
import 'package:dudu/pages/status/new_status.dart';
import 'package:dudu/pages/timeline/conversations_timeline.dart';
import 'package:dudu/pages/timeline/notification_display_type_dialog.dart';
import 'package:dudu/pages/timeline/notification_type_timeline.dart';
import 'package:dudu/utils/app_navigate.dart';
import 'package:dudu/utils/dialog_util.dart';
import 'package:dudu/utils/i18n_util.dart';
import 'package:dudu/utils/request.dart';
import 'package:dudu/utils/string_until.dart';
import 'package:dudu/utils/view/list_view_util.dart';
import 'package:dudu/widget/common/app_bar_title.dart';
import 'package:dudu/widget/common/colored_tab_bar.dart';
import 'package:dudu/widget/common/custom_app_bar.dart';
import 'package:dudu/widget/listview/provider_easyrefresh_listview.dart';
import 'package:dudu/widget/other/follow_cell.dart';
import 'package:dudu/widget/other/follow_request_cell.dart';
import 'package:dudu/widget/setting/account_list_header.dart';
import 'package:dudu/widget/setting/account_row_top.dart';
import 'package:dudu/widget/setting/setting_cell.dart';
import 'package:dudu/widget/status/status_item.dart';
import 'package:dudu/widget/timeline/timeline_content.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mk_drop_down_menu/mk_drop_down_menu.dart';
import 'package:nav_router/nav_router.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../widget/other/search.dart' as customSearch;

class NotificationTimeline extends StatefulWidget {
  @override
  _NotificationTimelineState createState() => _NotificationTimelineState();
}

class _NotificationTimelineState extends State<NotificationTimeline>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  GlobalKey _headerKey;
  MKDropDownMenuController _menuController1;
  MKDropDownMenuController _menuController2;
  ResultListProvider provider;
  ScrollController _scrollController = ScrollController();
  RefreshController _refreshController = RefreshController();

  List displayType;

  @override
  void initState() {
    _tabController = TabController(
        initialIndex: RuntimeConfig.notificationTimeline ?? 0,
        length: 2,
        vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _headerKey = GlobalKey();
    _menuController1 = MKDropDownMenuController();
    _menuController2 = MKDropDownMenuController();

    provider = ResultListProvider(
        firstRefresh: false,
        requestUrl: TimelineApi.notification,
        buildRow: ListViewUtil.notificationRowFunction(),
        tag: 'notifications');

    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<SettingsProvider>(context);
    var showBadge = settings.get('red_dot_notfication');
    return Scaffold(
      appBar: PreferredSize(
        child: CustomAppBar(
          elevation: 0,
        ),
        preferredSize: Size.fromHeight(0),
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).appBarTheme.color,
            height: 45,
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                ),
                Expanded(
                  child: ColoredTabBar(
                    key: _headerKey,
                    color: Theme.of(context).appBarTheme.color,
                    tabBar: TabBar(
                      onTap: (idx) {
                        RuntimeConfig.notificationTimeline = idx;
                        OverlayUtil.hideAllOverlay();
                      },
                      indicator: UnderlineTabIndicator(
                          borderSide: BorderSide(
                              width: 2.5, color: Theme.of(context).buttonColor),
                          insets: EdgeInsets.only(left: 5, right: 25)),
                      isScrollable: true,
                      labelPadding: EdgeInsets.all(0),
                      indicatorSize: TabBarIndicatorSize.label,
                      labelStyle: TextStyle(fontWeight: FontWeight.normal),
                      unselectedLabelStyle:
                          TextStyle(fontWeight: FontWeight.normal),
                      tabs: [
                        Badge(
                          position: BadgePosition.topEnd(top: 5, end: 18),
                          showBadge: false,
                          //     settings.unread[TimelineApi.notification] != 0,
                          child: _tabController.index == 0
                              ? MKDropDownMenu(
                                  controller: _menuController1,
                                  headerBuilder: (menuShowing) {
                                    return DropDownTitle(
                                      title: S.of(context).all,
                                      expand: menuShowing,
                                      showIcon: true,
                                    );
                                  },
                                  headerKey: _headerKey,
                                  menuBuilder: () {
                                    return AccountListHeader(_menuController1);
                                  },
                                )
                              : DropDownTitle(
                                  title: S.of(context).all,
                                ),
                        ),
                        Badge(
                          position: BadgePosition.topEnd(top: 5, end: 18),
                          showBadge: showBadge &&
                              (settings.unread[TimelineApi.conversations] !=
                                      0 ||
                                  settings.unread[TimelineApi.followRquest] !=
                                      0 ||
                                  settings.unread[TimelineApi.mention] != 0 ||
                                  settings.unread[TimelineApi.follow] != 0 ||
                                  settings.unread[
                                          TimelineApi.pollNotification] !=
                                      0 ||
                                  settings.unread[
                                          TimelineApi.reblogNotification] !=
                                      0 ||
                                  settings.unread[
                                          TimelineApi.favoriteNotification] !=
                                      0),
                          child: _tabController.index == 1
                              ? MKDropDownMenu(
                                  controller: _menuController2,
                                  headerKey: _headerKey,
                                  headerBuilder: (menuShowing) {
                                    return DropDownTitle(
                                      title: S.of(context).classification,
                                      expand: menuShowing,
                                      showIcon: true,
                                    );
                                  },
                                  menuBuilder: () {
                                    return AccountListHeader(_menuController2);
                                  },
                                )
                              : DropDownTitle(
                                  title: S.of(context).classification,
                                ),
                        ),
                      ],
                      controller: _tabController,
                    ),
                  ),
                ),
                PopupMenuButton(
                  offset: Offset(0, 45),
                  icon: Icon(Icons.more_vert),
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                        value: 'clear', child: new Text(S.of(context).clear)),
                    // PopupMenuItem<String>(
                    //     value: 'choose_type', child: new Text('分类'))
                  ],
                  onSelected: (String value) {
                    switch (value) {
                      case 'clear':
                        DialogUtils.showSimpleAlertDialog(
                            context: context,
                            text: S
                                .of(context)
                                .are_you_sure_you_want_to_delete_the_message_list_forever,
                            onConfirm: _clearNotification);
                        break;
                      case 'choose_type':
                        showChooseTypeDialog();
                        break;
                    }
                  },
                )
              ],
            ),
          ),
          Divider(
            height: 1,
          ),
          Expanded(
              child: TabBarView(
            controller: _tabController,
            children: [
              TimelineContent(
                url: TimelineApi.notification,
                rowBuilder: ListViewUtil.notificationRowFunction(),
                tag: 'notifications',
                provider: provider,
              ),
              NotificationTypeList()
            ],
          ))
        ],
      ),
    );
  }

  _clearNotification() async {
    await NotificationApi.clear();
    provider.clearData();
  }

  showChooseTypeDialog() async {
    var newDisplayType = await DialogUtils.showRoundedDialog(
        context: context, content: NotificationDisplayTypeDialog());
    if (newDisplayType != null) {
      provider.requestUrl = TimelineApi.notification;
      provider.refresh();
    }
  }
}

class NotificationTypeList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<SettingsProvider>(context);
    String zan_or_shoucang = provider.get('zan_or_shoucang');
    var isZh = I18nUtil.isZh(context);
    var zan_icon = isZh
        ? (zan_or_shoucang == '0' ? IconFont.thumbUp : IconFont.favorite)
        : IconFont.favorite;
    var showBadge = provider.get('red_dot_notfication');
    return SingleChildScrollView(
      child: Column(
        children: [
          Badge(
            position: BadgePosition.topEnd(top: 20, end: 20),
            showBadge:
                showBadge && provider.unread[TimelineApi.conversations] != 0,
            child: SettingCell(
                leftIcon: Icon(IconFont.message),
                title: S.of(context).private_letters,
                onPress: () => AppNavigate.push(ConversationTimeline()),
                tail: provider.unread[TimelineApi.conversations] != 0
                    ? Container()
                    : null),
          ),
          Badge(
            position: BadgePosition.topEnd(top: 20, end: 20),
            showBadge:
                showBadge && provider.unread[TimelineApi.followRquest] != 0,
            child: SettingCell(
                leftIcon: Icon(IconFont.follow),
                title: S.of(context).follow_request,
                onPress: () => AppNavigate.push(NotificationTypeTimeline(
                    TimelineApi.followRquest, S.of(context).follow_request)),
                tail: provider.unread[TimelineApi.followRquest] != 0
                    ? Container()
                    : null),
          ),
          Badge(
            position: BadgePosition.topEnd(top: 20, end: 20),
            showBadge: showBadge && provider.unread[TimelineApi.follow] != 0,
            child: SettingCell(
                leftIcon: Icon(IconFont.follow),
                title: S.of(context).follow,
                onPress: () => AppNavigate.push(NotificationTypeTimeline(
                    TimelineApi.follow, S.of(context).follow)),
                tail: provider.unread[TimelineApi.follow] != 0
                    ? Container()
                    : null),
          ),
          Badge(
            position: BadgePosition.topEnd(top: 20, end: 20),
            showBadge: showBadge && provider.unread[TimelineApi.mention] != 0,
            child: SettingCell(
                leftIcon: Icon(IconFont.at),
                title: S.of(context).at_mine,
                onPress: () => AppNavigate.push(NotificationTypeTimeline(
                    TimelineApi.mention, S.of(context).at_mine)),
                tail: provider.unread[TimelineApi.mention] != 0
                    ? Container()
                    : null),
          ),
          Badge(
            position: BadgePosition.topEnd(top: 20, end: 20),
            showBadge: showBadge &&
                provider.unread[TimelineApi.reblogNotification] != 0,
            child: SettingCell(
                leftIcon: Icon(IconFont.reblog),
                title: S.of(context).tell_me,
                onPress: () => AppNavigate.push(NotificationTypeTimeline(
                    TimelineApi.reblogNotification, S.of(context).tell_me)),
                tail: provider.unread[TimelineApi.mention] != 0
                    ? Container()
                    : null),
          ),
          Badge(
            position: BadgePosition.topEnd(top: 20, end: 20),
            showBadge: showBadge &&
                provider.unread[TimelineApi.favoriteNotification] != 0,
            child: SettingCell(
                leftIcon: Icon(zan_icon),
                title: isZh
                    ? (StringUtil.getZanString() + S.of(context).mine)
                    : S.of(context).favorites,
                onPress: () => AppNavigate.push(NotificationTypeTimeline(
                    TimelineApi.favoriteNotification,
                    isZh
                        ? StringUtil.getZanString() + S.of(context).mine
                        : S.of(context).favorites)),
                tail: provider.unread[TimelineApi.favoriteNotification] != 0
                    ? Container()
                    : null),
          ),
          Badge(
            position: BadgePosition.topEnd(top: 20, end: 20),
            showBadge:
                showBadge && provider.unread[TimelineApi.pollNotification] != 0,
            child: SettingCell(
              leftIcon: Icon(IconFont.vote),
              title: S.of(context).vote,
              onPress: () => AppNavigate.push(NotificationTypeTimeline(
                  TimelineApi.pollNotification, S.of(context).vote)),
            ),
          ),
        ],
      ),
    );
  }
}
