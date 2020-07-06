import 'package:fastodon/utils/themes.dart';
import 'package:flutter/material.dart';

import 'package:fastodon/public.dart';
import 'package:flutter/services.dart';
import 'package:nav_router/nav_router.dart';
import 'package:theme_provider/theme_provider.dart';

import 'pages/root_page.dart';
import 'pages/login/login.dart';
import 'pages/status/new_status.dart';

import 'models/user.dart';

User user = new User();

class MyApp extends StatelessWidget {






  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    return ThemeProvider(
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
                      builder: (context) => HomePage())),
            ),
          ),
        ));
  }
}

class HomePage extends StatelessWidget {
  // 验证存储在本地的token是否可以使用
  Future<void> _verifyToken(BuildContext context) async {
    Request.get(url: Api.VerifyToken).then((data) {
      if (data['name'] == AppConfig.ClientName) {
        eventBus.emit(EventBusKey.LoadLoginMegSuccess);
      } else {
        // token已失效，删除本地所有token信息
        Storage.removeString(StorageKey.HostUrl);
        Storage.removeString(StorageKey.Token);
        user.setHost(null);
        user.setToken(null);
        showBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Login();
            });
      }
    });
  }

  // 这是一个异步操作，必须保证单例从local中拿到数据之后，才可以发起请求
  void _showLoginWidget(BuildContext context) {
    Future<String> hostString = Storage.getString(StorageKey.HostUrl);
    Future<String> tokenString = Storage.getString(StorageKey.Token);
// 保证本地存有host地址以及token
    Future.wait([hostString, tokenString]).then((List results) {
      var host = results[0];
      var token = results[1];
      if (host == '' || host == null || token == '' || token == null) {
        pushAndRemoveUntil(Login());
      } else {
        user.setHost(host);
        user.setToken(token);
        _verifyToken(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RootPage(
      showLogin: () {
        _showLoginWidget(context);
      }
    );
  }
}

