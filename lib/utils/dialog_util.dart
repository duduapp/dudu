import 'package:fastodon/public.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nav_router/nav_router.dart';

class DialogUtils {
  static toastDownloadInfo(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 14.0);
  }

  static toastErrorInfo(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static showInfoDialog(BuildContext context, String msg) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text(msg),
            actions: <Widget>[
              FlatButton(
                child: Text('确定'),
                onPressed: () => AppNavigate.pop(context),
              )
            ],
          );
        });
  }

  static showSimpleAlertDialog(
  {BuildContext context, String text, Function onConfirm,bool popFirst}) {
    if (popFirst != null && popFirst == true) {
      AppNavigate.pop(context);
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text(text),
            actions: <Widget>[
              FlatButton(
                child: Text('取消'),
                onPressed: () => AppNavigate.pop(context),
              ),
              FlatButton(
                child: Text('确定'),
                onPressed: onConfirm,
              )
            ],
          );
        });
  }

  static showProgressDialog() {

  }
}
