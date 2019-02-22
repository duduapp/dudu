import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'home/home.dart';
import 'local/local.dart';
import 'metion/metion.dart';
import 'setting/setting.dart';

class RootPage extends StatefulWidget {
  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int _tabIndex = 0;
  
  List<Icon> _tabImages = [
    Icon(Icons.home),
    Icon(Icons.people),
    Icon(Icons.notifications),
    Icon(Icons.settings),
  ];
  List<Icon> _tabSelectedImages = [
    Icon(Icons.home),
    Icon(Icons.people),
    Icon(Icons.notifications),
    Icon(Icons.settings),
  ];

  Icon getTabIcon(int index) {
    if(index == _tabIndex) {
      return _tabSelectedImages[index];
    }else {
      return _tabImages[index];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(),
      body: IndexedStack(
        children: <Widget>[
          Home(),
          Local(),
          Metion(),
          Setting()
        ],
        index: _tabIndex,
      ),
      bottomNavigationBar: CupertinoTabBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: getTabIcon(0)),
          BottomNavigationBarItem(icon: getTabIcon(1)),
          BottomNavigationBarItem(icon: getTabIcon(2)),
          BottomNavigationBarItem(icon: getTabIcon(3)),
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
