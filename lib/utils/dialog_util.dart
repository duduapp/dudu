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

  // only info 只是展示信息，不做其它操作
  static showSimpleAlertDialog (
      {BuildContext context,
      String text,
        Function onCancel,
      Function onConfirm,
      bool popFirst,
      bool popAfter = true,
      bool onlyInfo = false,
      String cancelText,
      String confirmText}) async{
    if (popFirst != null && popFirst == true) {
      AppNavigate.pop(context);
    }
    Function onConfirmCallback;
    if (popAfter) {
      onConfirmCallback = () async {
        AppNavigate.pop(context);
        await onConfirm();
      };
    } else {
      onConfirmCallback = onConfirm;
    }
    if (onlyInfo) {
      onConfirmCallback = () {AppNavigate.pop(context);};
    }

    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            content: Text(text),
            actions: <Widget>[
              if (!onlyInfo)
              FlatButton(
                child: Text(cancelText ?? '取消'),
                onPressed: () {
                  if (onCancel != null) {
                    onCancel();
                  }
                  AppNavigate.pop(context);
                },
              ),
              FlatButton(
                child: Text(confirmText ?? '确定'),
                onPressed: onConfirmCallback,
              )
            ],
          );
        });
  }



  static showProgressDialog() {}

  static showRoundedDialog(
      {Widget content, BuildContext context, double radius = 8}) async {
    var res = await showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius)),
            child: content,
          );
        });
    return res;
  }
}
