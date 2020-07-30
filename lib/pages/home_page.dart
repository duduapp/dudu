import 'package:fastodon/models/local_account.dart';
import 'package:fastodon/models/logined_user.dart';
import 'package:fastodon/models/provider/settings_provider.dart';
import 'package:fastodon/models/task_runner.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/widget/other/app_retain_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart';

import 'login/login.dart';
import 'setting/setting.dart';
import 'status/new_status.dart';
import 'timeline/notifications.dart';
import 'timeline/timeline.dart';

class HomePage extends StatefulWidget {
  const HomePage(
      {Key key})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _verifyToken();
  }

  Future<void> _verifyToken() async {
//    LoginedUser user = LoginedUser();
//    LocalAccount localAccount = await LocalStorageAccount.getActiveAccount();
//



//    if (localAccount == null) {
//      AppNavigate.pushAndRemoveUntil(context, Login(),
//          routeType: RouterType.fade);
//    } else {
//      user.setHost(localAccount.hostUrl);
//      user.setToken(localAccount.token);
//      user.account = localAccount.account;
//    }
//
//
//    Request.get(url: Api.VerifyToken).then((data) {
//      if (data != null && data['name'] == AppConfig.ClientName) {
//        eventBus.emit(EventBusKey.LoadLoginMegSuccess);
//        TaskRunner.enableNotification();
//       // SettingsProvider.getCurrentContextProvider().load();
//      } else {
//        AppNavigate.pushAndRemoveUntil(context, Login(),
//            routeType: RouterType.fade);
//      }
//    });
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
    AppNavigate.push(NewStatus());
    // eventBus.emit(EventBusKey.ShowNewArticalWidget);
  }

  @override
  void didChangeDependencies() {


    super.didChangeDependencies();
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
              setState(() {
                _tabIndex = index;
              });
            },
          ),
      ),
    );
  }
}
