import 'package:dudu/l10n/l10n.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/utils/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nav_router/nav_router.dart';
import 'package:provider/provider.dart';

import 'models/logined_user.dart';
import 'pages/home_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
      localizationsDelegates: [
        // ... app-specific localization delegate[s] here
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: Locale(Provider.of<SettingsProvider>(context).settings['language']),
      supportedLocales: [
        const Locale('en', ''), // English, no country code
        const Locale('zh', ''), // Chinese *See Advanced Locales below*
        // ... other locales the app supports
      ],
      theme: ThemeUtil.themes[chooseTheme],
      onGenerateTitle: (context) => S.of(context).app_name,
      debugShowCheckedModeBanner: false,
      navigatorKey: navGK,
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: HomePage(
          logined: LoginedUser().account != null,
        ));
  }
}
