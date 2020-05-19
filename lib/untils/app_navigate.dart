import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart' as router;

class AppNavigate {
  static push(BuildContext context, Widget scene, {Function callBack}) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (BuildContext context) => scene,
    //   ),
    // ).then((data) {
    //   callBack(data);
    // });
    router.routePush(scene).then((data) {
      callBack(data);
    });
  }

  static pop(BuildContext context, {dynamic param}) {
    router.pop(param);
    //Navigator.of(context).pop(param);
  }
}
