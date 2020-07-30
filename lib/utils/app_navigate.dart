import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart' as router;
import 'package:theme_provider/theme_provider.dart';

class AppNavigate {
  static push(Widget scene,
      {Function callBack, router.RouterType routeType}) {
    return router.routePush(ThemeConsumer(child: scene),routeType ?? router.RouterType.cupertino);
  }

  static pop({dynamic param}) {
    router.pop(param);
  }

  static pushAndRemoveUntil(BuildContext context, Widget scene,
      {Function callBack, router.RouterType routeType}) {
    router.pushAndRemoveUntil(ThemeConsumer(child: scene),routeType ?? router.RouterType.cupertino).then((data) {
      if (callBack != null) callBack(data);
    });
  }
}
