import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/models/runtime_config.dart';
import 'package:dudu/models/task/notification_task.dart';
import 'package:dudu/models/task/update_task.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/filter_util.dart';
import 'package:dudu/widget/common/bottom_navigation_item.dart';
import 'package:dudu/widget/other/app_retain_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'setting/setting.dart';
import 'status/new_status.dart';
import 'timeline/notifications.dart';
import 'timeline/timeline.dart';

class HomePage extends StatefulWidget{
  const HomePage(
      {Key key})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver{
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      UpdateTask.checkUpdateIfNeed();
    }
  }

  int _tabIndex;

  @override
  void initState() {
    super.initState();
    _tabIndex = RuntimeConfig.tabIndex ?? 0;



    UpdateTask.checkUpdateIfNeed();
    FilterUtil.getFiltersAndApply();

    NotificationTask.enable();

    WidgetsBinding.instance.addObserver(this);
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
    IconFont.earthSmall,
    IconFont.notification,
    IconFont.mine
  ];

  List<String> _tabTitles = ['首页', '本站', '跨站', '消息', '我'];

  Icon getTabIcon(int index, Color activeColor) {
    if (index == _tabIndex) {
      return Icon(_tabIcons[index],
          color: activeColor,); //_tabSelectedImages[index];
    } else {
      return Icon(_tabIcons[index],color: Theme.of(context).textTheme.bodyText1.color,); //_tabImages[index];
    }
  }

  Text getTabTitle(int index, Color activeColor) {
    if (index == _tabIndex) {
      return Text(
        _tabTitles[index],
        style: TextStyle(color: activeColor, fontWeight: FontWeight.normal),
      );
    } else {
      return Text(_tabTitles[index],style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color),);
    }
  }

  void showNewArtical() {
    AppNavigate.push(NewStatus());
    // eventBus.emit(EventBusKey.ShowNewArticalWidget);
  }


  @override
  Widget build(BuildContext context) {
    Color activeColor = Theme.of(context).toggleableActiveColor;

    return AppRetainWidget(
      child: Scaffold(

          body: IndexedStack(
            children: <Widget>[Timeline(TimelineType.home), Timeline(TimelineType.local), Timeline(TimelineType.federated),Notifications(), Setting()],
            index: _tabIndex,
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(height: 0,),
              CupertinoTabBar(
                iconSize: 30,
                items: [
                  BottomNavigationBarItem(
                      icon: getTabIcon(0, activeColor),
                      title: getTabTitle(0, activeColor)),
                  BottomNavigationBarItem(
                      icon: getTabIcon(1, activeColor),
                      title: getTabTitle(1, activeColor)),
                  BottomNavigationBarItem(
                      icon: getTabIcon(2, activeColor),
                      title: getTabTitle(2, activeColor)),
                  BottomNavigationBarItem(
                      icon: getTabIcon(3, activeColor),
                      title: getTabTitle(3, activeColor)),
                  BottomNavigationBarItem(
                      icon: getTabIcon(4, activeColor),
                      title: getTabTitle(4, activeColor)),
                ],
                currentIndex: _tabIndex,
                onTap: (index) {
                  // 选中状态后继续点击，开启刷新
                  if (index == _tabIndex) {
                    RefreshController refreshController;
                    switch (index) {
                      case 0:
                        refreshController = SettingsProvider().homeProvider.refreshController;
                        break;
                      case 1:
                        refreshController = SettingsProvider().localProvider.refreshController;
                        break;
                      case 2:
                        refreshController = SettingsProvider().federatedProvider.refreshController;
                        break;
                      case 3:
                        refreshController = SettingsProvider().notificationProvider.refreshController;
                        break;
                      case 4:
                        return;
                        break;
                    }
                    if (refreshController.position != null) {
                      refreshController.requestRefresh(duration: Duration(milliseconds: 1));
                    }
                  } else {
              //      _tabIndex = index;
                    RuntimeConfig.tabIndex = index;
                    setState(() {
                      _tabIndex = index;
                    });
                  }
                },
              ),
            ],
          ),
      ),
    );
  }
}
