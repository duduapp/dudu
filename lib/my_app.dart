import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/utils/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nav_router/nav_router.dart';
import 'package:provider/provider.dart';

import 'models/logined_user.dart';
import 'pages/home_page.dart';
import 'pages/login/login.dart';

LoginedUser user = new LoginedUser();

class MyApp extends StatelessWidget {
  final bool logined;

  const MyApp({Key key, this.logined}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return ChangeNotifierProvider<SettingsProvider>(
      create: (context) => SettingsProvider(),
      child: App(),
    );
  }
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    int chooseTheme = 0;

    try {
      chooseTheme = int.parse(
          context.select<SettingsProvider, String>((m) => m.get('theme')));
    } catch (e) {}
    return MaterialApp(
      theme: ThemeUtil.themes[chooseTheme],
      title: '嘟嘟',
      debugShowCheckedModeBanner: false,
      navigatorKey: navGK,
      home: Scaffold(body: HomePage()),
    );
  }
}
