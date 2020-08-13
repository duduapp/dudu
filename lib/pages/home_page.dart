import 'package:fastodon/api/accounts_api.dart';
import 'package:fastodon/constant/icon_font.dart';
import 'package:fastodon/models/local_account.dart';
import 'package:fastodon/models/logined_user.dart';
import 'package:fastodon/models/provider/settings_provider.dart';
import 'package:fastodon/models/runtime_config.dart';
import 'package:fastodon/models/task/notification_task.dart';
import 'package:fastodon/models/task/update_task.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/utils/filter_util.dart';
import 'package:fastodon/widget/other/app_retain_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart';


import 'login/login.dart';
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
      UpdateTask.check();
    }
  }

  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    UpdateTask.check();
    FilterUtil.getFiltersAndApply();
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
    IconFont.earth,
    IconFont.notification,
    IconFont.mine
  ];

  List<String> _tabTitles = ['首页', '本站', '跨站', '消息', '我'];

  Icon getTabIcon(int index, Color activeColor) {
    if (index == _tabIndex) {
      return Icon(_tabIcons[index],
          color: activeColor); //_tabSelectedImages[index];
    } else {
      return Icon(_tabIcons[index],color: Theme.of(context).textTheme.bodyText1.color,); //_tabImages[index];
    }
  }

  Text getTabTitle(int index, Color activeColor) {
    if (index == _tabIndex) {
      return Text(
        _tabTitles[index],
        style: TextStyle(color: activeColor, fontWeight: FontWeight.bold),
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
          bottomNavigationBar: CupertinoTabBar(
            items: <BottomNavigationBarItem>[
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
                switch (index) {
                  case 0:
                    SettingsProvider().homeProvider.refreshController.requestRefresh(duration: const Duration(milliseconds: 100));
                    break;
                  case 1:
                    SettingsProvider().localProvider.refreshController.requestRefresh(duration: const Duration(milliseconds: 100));
                    break;
                  case 2:
                    SettingsProvider().federatedProvider.refreshController.requestRefresh(duration: const Duration(milliseconds: 100));
                    break;
                  case 3:
                    SettingsProvider().notificationProvider.refreshController.requestRefresh(duration: const Duration(milliseconds: 100));
                    break;
                }
              } else {
                setState(() {
                  _tabIndex = index;
                });
              }
            },
          ),
      ),
    );
  }
}
