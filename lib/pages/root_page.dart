import 'package:fastodon/public.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'setting/setting.dart';
import 'status/new_status.dart';
import 'timeline/notifications.dart';
import 'timeline/timeline.dart';

class RootPage extends StatefulWidget {
  const RootPage(
      {Key key, this.showLogin})
      : super(key: key);

  final Function showLogin;


  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.showLogin();

  }

  @override
  void dispose() {
    eventBus.off(EventBusKey.ShowLoginWidget);
    super.dispose();
  }



  List<IconData> _tabIcons = [
    Icons.home,
    Icons.people,
    Icons.public,
    Icons.notifications,
    Icons.person
  ];

  List<String> _tabTitles = ['首页', '本站', '跨站', '消息', '我'];

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
    Color activeColor = AppConfig.buttonColor;

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
