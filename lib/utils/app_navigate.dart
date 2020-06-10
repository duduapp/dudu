import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nav_router/nav_router.dart' as router;

class AppNavigate {
  static push(BuildContext context, Widget scene, {Function callBack,Color statusBarColor}) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (BuildContext context) => scene,
    //   ),
    // ).then((data) {
    //   callBack(data);
    // });
    Widget widget;
    if (statusBarColor != null) {
      widget = AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: statusBarColor,
        ),
        child:scene,
      );
    } else {
      widget = scene;
    }

    router.routePush(widget).then((data) {
      callBack(data);
    });
  }

  static pop(BuildContext context, {dynamic param}) {
    router.pop(param);
    //Navigator.of(context).pop(param);
  }
}
