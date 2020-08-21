import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/utils/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nav_router/nav_router.dart';
import 'package:provider/provider.dart';
import 'package:theme_provider/theme_provider.dart';

import 'models/logined_user.dart';
import 'pages/home_page.dart';
import 'pages/login/login.dart';

LoginedUser user = new LoginedUser();

class MyApp extends StatelessWidget {
  final bool logined;

  const MyApp({Key key, this.logined}) : super(key: key);

  Widget buildError(BuildContext context, FlutterErrorDetails error) {
    return Container(
      child: Center(
        child: Text(
          "出现错误",
        ),
      ),
    );
  }

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
      child: ThemeProvider(
          themes: [
            AppTheme(id: '普通模式', data: ThemeUtil.lightTheme(context), description: ''),
            AppTheme(id: '深色模式', data: ThemeUtil.darkTheme(context), description: ''),
          ],
          saveThemesOnChange: true,
          loadThemeOnInit: true,
          child: Builder(
            builder: (themeContext) => MaterialApp(
                builder: (BuildContext context, Widget widget) {
                  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                    return buildError(context, errorDetails);
                  };

                  return widget;
                },
              theme: ThemeProvider.themeOf(themeContext).data,
              title: '嘟嘟',
              debugShowCheckedModeBanner: false,
              navigatorKey: navGK,
              home: ThemeConsumer(
                child: Scaffold(
                    body: Builder(
                        builder: (context) => logined ? HomePage() : Login())),
              ),
            ),
          )),
    );
  }
}

