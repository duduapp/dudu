import 'package:fastodon/untils/themes.dart';
import 'package:flutter/material.dart';

import 'package:fastodon/public.dart';
import 'package:flutter/services.dart';
import 'package:nav_router/nav_router.dart';

import 'pages/root_page.dart';
import 'pages/login/login.dart';
import 'pages/home/new_article.dart';

import 'models/user.dart';

User user = new User();
class MyApp extends StatelessWidget {
  // 这是一个异步操作，必须保证单例从local中拿到数据之后，才可以发起请求
  void _showLoginWidget(BuildContext context) {
    Future<String> hostString = Storage.getString(StorageKey.HostUrl);
    Future<String> tokenString = Storage.getString(StorageKey.Token);
// 保证本地存有host地址以及token
    Future.wait([hostString, tokenString]).then((List results) {
      var host = results[0];
      var token = results[1];
      if (host == '' || host == null || token == '' || token == null) {
        showBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Login();
          }
        );
      } else {
        user.setHost(host);
        user.setToken(token);
        _verifyToken(context);
      }
    });
  }

// 验证存储在本地的token是否可以使用
  Future<void> _verifyToken(BuildContext context) async {
    Request.get(url: Api.VerifyToken).then((data) {
      if(data['name'] == AppConfig.ClientName) {
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
          }
        );
      }
    });
  }
  
  void _showNewArticalWidget(BuildContext context) {
    showBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return NewArticle();
      }
    );
  }

  void _hideLoginWidget(BuildContext context) {
    AppNavigate.pop(context);
    eventBus.emit(EventBusKey.LoadLoginMegSuccess);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    return MaterialApp(
      title: 'fastondon',
      theme: defaultTheme,
      debugShowCheckedModeBanner: false,
      navigatorKey: navGK,
      home: Scaffold(
        body: Builder(
          builder: (context) => RootPage(
            showLogin: () {
              _showLoginWidget(context);
            },
            showNewArtical: () {
              _showNewArticalWidget(context);
            },
            hideWidget: () {
              _hideLoginWidget(context);
            },
          )
        )
      ),
    );
  }
}
