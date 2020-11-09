import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart' as router;

class AppNavigate {
  static push(Widget scene,
      {Function callBack, router.RouterType routeType}) {
    return router.routePush(scene,routeType ?? router.RouterType.cupertino);
  }

  static pop({dynamic param}) {
    router.pop(param);
  }

  static pushAndRemoveUntil(Widget scene,
      {Function callBack, router.RouterType routeType}) {
    router.pushAndRemoveUntil(scene,routeType ?? router.RouterType.cupertino).then((data) {
      if (callBack != null) callBack(data);
    });
  }

  static popToRoot() {
    router.popUntil((route) => route.isFirst);
   // Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
