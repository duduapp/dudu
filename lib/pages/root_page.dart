import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:fastodon/public.dart';
import 'package:popup_menu/popup_menu.dart';

import 'status/new_status.dart';
import 'timeline/timeline.dart';
import 'timeline/notifications.dart';
import 'setting/setting.dart';

class RootPage extends StatefulWidget {
  const RootPage(
      {Key key, this.showLogin, this.hideWidget, this.showNewArtical})
      : super(key: key);

  final Function showLogin;
  final Function hideWidget;
  final Function showNewArtical;


  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int _tabIndex = 0;
  bool _canLoadWidget = false;

  @override
  void initState() {
    super.initState();
    widget.showLogin();
    // 隐藏登录弹出页
    eventBus.on(EventBusKey.ShowLoginWidget, (arg) {
      widget.showLogin();
    });

    eventBus.on(EventBusKey.HidePresentWidegt, (arg) {
      widget.hideWidget();
    });
    // 弹出发送嘟文页面
    eventBus.on(EventBusKey.ShowNewArticalWidget, (arg) {
      widget.showNewArtical();
    });

    eventBus.on(EventBusKey.LoadLoginMegSuccess, (arg) {
      setState(() {
        _canLoadWidget = true;
      });
    });
  }

  @override
  void dispose() {
    eventBus.off(EventBusKey.ShowLoginWidget);
    eventBus.off(EventBusKey.HidePresentWidegt);
    eventBus.off(EventBusKey.ShowNewArticalWidget);
    super.dispose();
  }

  List<Icon> _tabImages = [
    Icon(Icons.home),
    Icon(Icons.people),
    Icon(Icons.notifications),
    Icon(Icons.settings),
  ];
  List<Icon> _tabSelectedImages = [
    Icon(Icons.home, color: MyColor.mainColor),
    Icon(Icons.people, color: MyColor.mainColor),
    Icon(Icons.notifications, color: MyColor.mainColor),
    Icon(Icons.settings, color: MyColor.mainColor),
  ];

  List<IconData> _tabIcons = [
    Icons.home,
    Icons.people,
    Icons.public,
    Icons.notifications,
    Icons.settings
  ];

  List<String> _tabTitles = ['首页', '本站', '跨站', '消息', '设置'];

  Icon getTabIcon(int index, Color activeColor) {
    if (index == _tabIndex) {
      return Icon(_tabIcons[index],
          color: activeColor); //_tabSelectedImages[index];
    } else {
      return Icon(_tabIcons[index]); //_tabImages[index];
    }
  }

  Text getTabTitle(int index, Color activeColor) {
    if (index == _tabIndex) {
      return Text(
        _tabTitles[index],
        style: TextStyle(color: activeColor, fontWeight: FontWeight.bold),
      );
    } else {
      return Text(_tabTitles[index]);
    }
  }

  void showNewArtical() {
    AppNavigate.push(context, NewStatus());
    // eventBus.emit(EventBusKey.ShowNewArticalWidget);
  }

  @override
  Widget build(BuildContext context) {
    Color activeColor = Theme.of(context).toggleableActiveColor;

    return Scaffold(
        key: _scaffoldKey,
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
            setState(() {
              _tabIndex = index;
            });
          },
        ),
    );
  }
}
