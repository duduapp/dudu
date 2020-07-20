import 'package:fastodon/models/local_account.dart';
import 'package:fastodon/models/provider/settings_provider.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/utils/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nav_router/nav_router.dart';
import 'package:provider/provider.dart';
import 'package:theme_provider/theme_provider.dart';

import 'models/user.dart';
import 'pages/login/login.dart';
import 'pages/home_page.dart';

LoginedUser user = new LoginedUser();

class MyApp extends StatelessWidget {
  final bool logined;

  const MyApp({Key key, this.logined}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    return ChangeNotifierProvider<SettingsProvider>(
      create: (context) => SettingsProvider(),
      child: ThemeProvider(
          themes: [
            AppTheme(id: '普通模式', data: defaultTheme, description: ''),
            AppTheme(id: '深色模式', data: darTheme, description: ''),
          ],
          saveThemesOnChange: true,
          loadThemeOnInit: true,
          child: Builder(
            builder: (themeContext) => MaterialApp(
              theme: ThemeProvider.themeOf(themeContext).data,
              title: 'fastondon',
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

