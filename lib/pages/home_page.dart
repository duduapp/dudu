import 'package:dudu/l10n/l10n.dart';
import 'package:dudu/api/admin_api.dart';
import 'package:dudu/api/timeline_api.dart';
import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/models/logined_user.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/models/runtime_config.dart';
import 'package:dudu/models/task/check_role_task.dart';
import 'package:dudu/models/task/get_emoji_task.dart';
import 'package:dudu/models/task/notification_task.dart';
import 'package:dudu/models/task/register_help_task.dart';
import 'package:dudu/models/task/update_task.dart';
import 'package:dudu/pages/discovery/instance_list.dart';
import 'package:dudu/pages/timeline/local_timeline.dart';
import 'package:dudu/pages/timeline/notification_timeline.dart';
import 'package:dudu/pages/timeline/public_timeline.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/account_util.dart';
import 'package:dudu/utils/dialog_util.dart';
import 'package:dudu/utils/filter_util.dart';
import 'package:dudu/widget/common/bottom_navigation_item.dart';
import 'package:dudu/widget/home/bottom_navi_bar.dart';
import 'package:dudu/widget/other/app_retain_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'setting/setting.dart';
import 'status/new_status.dart';
import 'timeline/notifications.dart';
import 'timeline/timeline.dart';

class HomePage extends StatefulWidget {
  final bool logined;
  const HomePage({Key key, this.logined = true}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      UpdateTask.checkUpdateIfNeed();
      RegisterHelpTask.start();
      if (LoginedUser().account != null) {
        CheckRoleTask.checkUserRole();
        GetEmojiTask.get();
        removeState();
      }
    } else if (state == AppLifecycleState.paused) {
      saveState();
    }
  }

  saveState() {
    AccountUtil.saveState();
  }

  removeState() {
    AccountUtil.restoreState();
  }

  @override
  void initState() {
    super.initState();
    UpdateTask.checkUpdateIfNeed();

    if (LoginedUser().account != null) {
      CheckRoleTask.checkUserRole();
      FilterUtil.getFiltersAndApply();

      NotificationTask.enable();
      GetEmojiTask.get();

      WidgetsBinding.instance.addObserver(this);
    }
    RegisterHelpTask.start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    eventBus.off(EventBusKey.ShowLoginWidget);
    super.dispose();
  }

  List<IconData> _tabIcons = [
    IconFont.home,
    IconFont.local,
    IconFont.earth,
    IconFont.notification,
    IconFont.mine
  ];

  List<String> get _tabTitles {
    return [
      S.of(context).home,
      S.of(context).square,
      S.of(context).find,
      S.of(context).news,
      S.of(context).me
    ];
  }

  Icon getTabIcon(int index, Color activeColor, bool logined) {
    if (index == SettingsProvider().homeTabIndex) {
      return Icon(
        _tabIcons[index],
        color: activeColor,
        size: 28,
      ); //_tabSelectedImages[index];
    } else {
      return Icon(
        _tabIcons[index],
        color:
            logined ? Theme.of(context).textTheme.bodyText2.color : Colors.grey,
        size: 28,
      ); //_tabImages[index];
    }
  }

  Text getTabTitle(int index, Color activeColor, bool logined) {
    if (index == SettingsProvider().homeTabIndex) {
      return Text(
        _tabTitles[index],
        style: TextStyle(
            color: activeColor, fontWeight: FontWeight.normal, fontSize: 10),
      );
    } else {
      return Text(
        _tabTitles[index],
        style: TextStyle(
            color: logined
                ? Theme.of(context).textTheme.bodyText2.color
                : Colors.grey,
            fontSize: 10),
      );
    }
  }

  void showNewArtical() {
    AppNavigate.push(NewStatus());
    // eventBus.emit(EventBusKey.ShowNewArticalWidget);
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<SettingsProvider>(context);
    var homeTabIndex = provider.homeTabIndex;
    return AppRetainWidget(
      child: Scaffold(
          body: IndexedStack(
            children: <Widget>[
              widget.logined ? HomeTimeline() : Container(),
              widget.logined
                  ? PublicTimeline(
                      enableFederated: !LoginedUser()
                          .host
                          .startsWith('https://help.dudu.today'),
                    )
                  : Container(),
              InstanceList(),
              widget.logined ? NotificationTimeline() : Container(),
              widget.logined ? Setting() : Container()
            ],
            index: homeTabIndex,
          ),
          bottomNavigationBar: _bottomMenu(homeTabIndex, widget.logined)
          // Column(
          //   mainAxisSize: MainAxisSize.min,
          //   children: [
          //     Divider(height: 0,),
          //     CupertinoTabBar(
          //       backgroundColor: Theme.of(context).appBarTheme.color,
          //       iconSize: 30,
          //       items: [
          //         BottomNavigationBarItem(
          //             icon: getTabIcon(0, activeColor),
          //             title: getTabTitle(0, activeColor)),
          //         BottomNavigationBarItem(
          //             icon: getTabIcon(1, activeColor),
          //             title: getTabTitle(1, activeColor)),
          //         BottomNavigationBarItem(
          //             icon: getTabIcon(2, activeColor),
          //             title: getTabTitle(2, activeColor)),
          //         BottomNavigationBarItem(
          //             icon: getTabIcon(3, activeColor),
          //             title: getTabTitle(3, activeColor)),
          //         BottomNavigationBarItem(
          //             icon: getTabIcon(4, activeColor),
          //             title: getTabTitle(4, activeColor)),
          //       ],
          //       currentIndex: _tabIndex,
          //       onTap: (index) {
          //         // 选中状态后继续点击，开启刷新
          //         if (index == _tabIndex) {
          //           RefreshController refreshController;
          //           switch (index) {
          //             case 0:
          //               refreshController = SettingsProvider().homeProvider.refreshController;
          //               break;
          //             case 1:
          //               refreshController = SettingsProvider().localProvider.refreshController;
          //               break;
          //             case 2:
          //               refreshController = SettingsProvider().federatedProvider.refreshController;
          //               break;
          //             case 3:
          //               refreshController = SettingsProvider().notificationProvider.refreshController;
          //               break;
          //             case 4:
          //               return;
          //               break;
          //           }
          //           if (refreshController.position != null) {
          //             refreshController.requestRefresh(duration: Duration(milliseconds: 1));
          //           }
          //         } else {
          //     //      _tabIndex = index;
          //           RuntimeConfig.tabIndex = index;
          //           setState(() {
          //             _tabIndex = index;
          //           });
          //         }
          //       },
          //     ),
          //   ],
          // ),
          ),
    );
  }

  _bottomMenu(int _tabIndex, bool logined) {
    SettingsProvider provider = Provider.of<SettingsProvider>(context);
    Color activeColor = Theme.of(context).toggleableActiveColor;
    var showBadge = provider.get('red_dot_notfication');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(
          height: 0,
        ),
        Container(
          color: AppBarTheme.of(context).color,
          // height: 50,
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                BottomNaviBar(
                  icon: getTabIcon(0, activeColor, logined),
                  title: getTabTitle(0, activeColor, logined),
                  showBadge: showBadge && logined && provider.unread[TimelineApi.home] != 0,
                  onTap: logined
                      ? () {
                          if (_tabIndex == 0) {
                            //provider.homeProvider.scrollController.jumpTo(0);
                            provider.homeProvider.refreshController
                                .requestRefresh(
                                    duration: Duration(milliseconds: 100));
                          } else {
                            setState(() {
                              SettingsProvider().setHomeTabIndex(0);
                            });
                          }
                        }
                      : () => DialogUtils.showInfoDialog(context, S.of(context).need_login_before_operate),
                  onDoubleTap: logined
                      ? () {
                          provider.homeProvider.refreshController
                              .requestRefresh(
                                  duration: Duration(milliseconds: 100));
                        }
                      : null,
                ),
                BottomNaviBar(
                  icon: getTabIcon(1, activeColor, logined),
                  title: getTabTitle(1, activeColor, logined),
                  showBadge: showBadge && logined && provider.unread[TimelineApi.local] != 0,
                  onTap: logined
                      ? () {
                          if (_tabIndex == 1) {
                            // if (SettingsProvider().publicTabIndex == 0) {
                            //   provider.localProvider.scrollController.jumpTo(0);
                            // } else {
                            //   provider.federatedProvider.scrollController.jumpTo(0);
                            // }
                            if (SettingsProvider().publicTabIndex == 0) {
                              provider.localProvider.refreshController
                                  .requestRefresh(
                                      duration: Duration(milliseconds: 100));
                            } else {
                              provider.federatedProvider.refreshController
                                  .requestRefresh(
                                      duration: Duration(milliseconds: 100));
                            }
                          } else {
                            SettingsProvider().setHomeTabIndex(1);
                          }
                        }
                      : () => DialogUtils.showInfoDialog(context, S.of(context).need_login_before_operate),
                  onDoubleTap: logined
                      ? () {
                          if (SettingsProvider().publicTabIndex == 0) {
                            provider.localProvider.refreshController
                                .requestRefresh(
                                    duration: Duration(milliseconds: 100));
                          } else {
                            provider.federatedProvider.refreshController
                                .requestRefresh(
                                    duration: Duration(milliseconds: 100));
                          }
                        }
                      : null,
                ),
                BottomNaviBar(
                  showBadge: false,
                  icon: getTabIcon(2, activeColor, logined),
                  title: getTabTitle(2, activeColor, logined),
                  onTap: () {
                    SettingsProvider().setHomeTabIndex(2);
                  },
                ),
                BottomNaviBar(
                  icon: getTabIcon(3, activeColor, logined),
                  title: getTabTitle(3, activeColor, logined),
                  showBadge: showBadge && logined &&
                      ( //provider.unread[TimelineApi.notification] != 0 ||
                          provider.unread[TimelineApi.conversations] != 0 ||
                              provider.unread[TimelineApi.followRquest] != 0 ||
                              provider.unread[TimelineApi.follow] != 0 ||
                              provider.unread[TimelineApi.mention] != 0 ||
                              provider.unread[TimelineApi.reblogNotification] !=
                                  0 ||
                              provider.unread[
                                      TimelineApi.favoriteNotification] !=
                                  0 || provider.unread[TimelineApi.pollNotification] != 0),
                  onTap: logined
                      ? () {
                          if (_tabIndex == 3) {
                            // provider.notificationProvider.scrollController.jumpTo(0);
                            provider.notificationProvider.refreshController
                                .requestRefresh(
                                    duration: Duration(milliseconds: 100));
                          } else {
                            SettingsProvider().setHomeTabIndex(3);
                          }
                        }
                      : () => DialogUtils.showInfoDialog(context, S.of(context).need_login_before_operate),
                  onDoubleTap: logined
                      ? () {
                          provider.notificationProvider.refreshController
                              .requestRefresh(
                                  duration: Duration(milliseconds: 100));
                        }
                      : null,
                ),
                BottomNaviBar(
                  showBadge: false,
                  icon: getTabIcon(4, activeColor, logined),
                  title: getTabTitle(4, activeColor, logined),
                  onTap: logined
                      ? () {
                          SettingsProvider().setHomeTabIndex(4);
                        }
                      : () => DialogUtils.showInfoDialog(context, S.of(context).need_login_before_operate),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
