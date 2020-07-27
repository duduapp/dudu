import 'package:fastodon/public.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  {BuildContext context, String text, Function onConfirm,bool popFirst,bool popAfter = true}) {
    if (popFirst != null && popFirst == true) {
      AppNavigate.pop(context);
    }
    Function callback;
    if (popAfter) {
      callback = () async {
        AppNavigate.pop(context);
        await onConfirm();
      };
    } else {
      callback = onConfirm;
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            content: Text(text),
            actions: <Widget>[
              FlatButton(
                child: Text('取消'),
                onPressed: () => AppNavigate.pop(context),
              ),
              FlatButton(
                child: Text('确定'),
                onPressed: callback,
              )
            ],
          );
        });
  }

  static showProgressDialog() {

  }

  static showRoundedDialog({Widget content,BuildContext context}) async{
     var res = await showDialog(
        context: context,
        builder: (context) {
      return Dialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: content,
      );
    });
     return res;
  }

}
