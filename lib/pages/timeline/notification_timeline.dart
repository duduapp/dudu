import 'package:dudu/api/notification_api.dart';
import 'package:dudu/constant/api.dart';
import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/models/json_serializable/notificate_item.dart';
import 'package:dudu/models/local_account.dart';
import 'package:dudu/models/logined_user.dart';
import 'package:dudu/models/notification/NotificationType.dart';
import 'package:dudu/models/provider/result_list_provider.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/pages/login/login.dart';
import 'package:dudu/pages/search/search_page_delegate.dart';
import 'package:dudu/pages/status/new_status.dart';
import 'package:dudu/pages/timeline/conversations_timeline.dart';
import 'package:dudu/pages/timeline/notification_display_type_dialog.dart';
import 'package:dudu/pages/timeline/notification_type_timeline.dart';
import 'package:dudu/utils/app_navigate.dart';
import 'package:dudu/utils/dialog_util.dart';
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

  List displayType;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _headerKey = GlobalKey();
    _menuController1 = MKDropDownMenuController();
    _menuController2 = MKDropDownMenuController();
    displayType = SettingsProvider().settings['notification_display_type'];
    provider = ResultListProvider(
        requestUrl: Request.buildGetUrl(
            Api.Notifications, getRequestParams(displayType)),
        buildRow: ListViewUtil.notificationRowFunction(),
        tag: 'notifications');
    super.initState();
  }

  Map getRequestParams(List displayType) {
    var notificationTypes = [
      'follow',
      'favourite',
      'reblog',
      'mention',
      'poll',
      'follow_request'
    ];
    notificationTypes.removeWhere((element) => displayType.contains(element));
    return {'exclude_types': notificationTypes};
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  width: 102,
                ),
                Expanded(
                  child: ColoredTabBar(
                    key: _headerKey,
                    color: Theme.of(context).appBarTheme.color,
                    tabBar: TabBar(
                      onTap: (idx) {
                        OverlayUtil.hideAllOverlay();
                      },
                      indicator: UnderlineTabIndicator(
                          borderSide: BorderSide(
                              width: 2.5, color: Theme.of(context).buttonColor),
                          insets: EdgeInsets.only(left: 5, right: 25)),
                      isScrollable: true,
                      labelPadding: EdgeInsets.all(0),
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: [
                        _tabController.index == 0
                            ? MKDropDownMenu(
                                controller: _menuController1,
                                headerBuilder: (menuShowing) {
                                  return DropDownTitle(
                                    title: '全部',
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
                                title: '全部',
                              ),
                        _tabController.index == 1
                            ? MKDropDownMenu(
                                controller: _menuController2,
                                headerKey: _headerKey,
                                headerBuilder: (menuShowing) {
                                  return DropDownTitle(
                                    title: '分类',
                                    expand: menuShowing,
                                    showIcon: true,
                                  );
                                },
                                menuBuilder: () {
                                  return AccountListHeader(_menuController2);
                                },
                              )
                            : DropDownTitle(
                                title: '分类',
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
                        value: 'clear', child: new Text('清空')),
                    PopupMenuItem<String>(
                        value: 'choose_type', child: new Text('分类'))
                  ],
                  onSelected: (String value) {
                    switch (value) {
                      case 'clear':
                        DialogUtils.showSimpleAlertDialog(
                            context: context,
                            text: '你确定要永远删除通知列表吗',
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
            height: 0,
          ),
          Expanded(
              child: TabBarView(
            controller: _tabController,
            children: [
              ChangeNotifierProvider<ResultListProvider>.value(
                value: provider,
                builder: (context, snapshot) {
                  return ProviderEasyRefreshListView();
                },
              ),
              NotificationTypeList(),
            ],
          ))
        ],
      ),
    );
  }

  _clearNotification() async{
    await NotificationApi.clear();
    provider.clearData();
  }

  showChooseTypeDialog() async {
    var newDisplayType = await DialogUtils.showRoundedDialog(
        context: context, content: NotificationDisplayTypeDialog());
    if (newDisplayType != null) {
      provider.requestUrl = Request.buildGetUrl(
          Api.Notifications, getRequestParams(newDisplayType));
      provider.refresh();
    }
  }
}

class NotificationTypeList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SettingCell(
            title: "私信",
            onPress: () => AppNavigate.push(ConversationTimeline()),
          ),
          SettingCell(
            title: "关注请求",
            onPress: () => AppNavigate.push(
                NotificationTypeTimeline(NotificationType.followRequest)),
          ),
          SettingCell(
            title: "@我的",
            onPress: () => AppNavigate.push(
                NotificationTypeTimeline(NotificationType.mention)),
          ),
          SettingCell(
            title: '转嘟',
            onPress: () => AppNavigate.push(
                NotificationTypeTimeline(NotificationType.reblog)),
          ),
          SettingCell(
            title: '关注我的',
            onPress: () => AppNavigate.push(
                NotificationTypeTimeline(NotificationType.follow)),
          ),
          SettingCell(
            title: '收藏我的',
            onPress: () => AppNavigate.push(
                NotificationTypeTimeline(NotificationType.favourite)),
          ),
          SettingCell(
            title: '投票',
            onPress: () => AppNavigate.push(
                NotificationTypeTimeline(NotificationType.poll)),
          )
        ],
      ),
    );
  }
}
