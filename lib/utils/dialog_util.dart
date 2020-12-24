import 'package:dudu/l10n/l10n.dart';
import 'package:dudu/public.dart';
import 'package:dudu/widget/common/bottom_sheet_item.dart';
import 'package:dudu/widget/common/normal_flat_button.dart';
import 'package:dudu/widget/dialog/loading_dialog.dart';
import 'package:dudu/widget/flutter_framework/progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nav_router/nav_router.dart';

class DialogUtils {
  static toastDownloadInfo(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Theme.of(navGK.currentContext).accentColor.withOpacity(0.8),
        textColor: Colors.white,
        fontSize: 14.0);
  }

  static toastFinishedInfo(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Theme.of(navGK.currentContext).accentColor.withOpacity(0.8),
        textColor: Colors.white,
        fontSize: 14.0);
  }

  static toastErrorInfo(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
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
                child: Text(S.of(context).determine),
                onPressed: () => AppNavigate.pop(),
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
      String confirmText,
      bool barrierDismissible = true}) async{
    if (popFirst != null && popFirst == true) {
      AppNavigate.pop();
    }
    Function onConfirmCallback;
    if (popAfter) {
      onConfirmCallback = () async {
        AppNavigate.pop();
        await onConfirm();
      };
    } else {
      onConfirmCallback = onConfirm;
    }
    if (onlyInfo) {
      onConfirmCallback = () {AppNavigate.pop();};
    }

    return await showDialog(
      barrierDismissible: barrierDismissible,
        context: context ?? navGK.currentState.overlay.context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            content: Text(text),
            actions: <Widget>[
              if (!onlyInfo)
              NormalFlatButton(
                text: cancelText ?? S.of(context).cancel,
                onPressed: () {
                  if (onCancel != null) {
                    onCancel();
                  }
                  AppNavigate.pop();
                },
              ),
              NormalFlatButton(
                text: confirmText ?? S.of(context).determine,
                onPressed: onConfirmCallback,
              )
            ],
          );
        });
  }



  static Future<ProgressDialog> showProgressDialog(String msg) async{
    var dialog = ProgressDialog(navGK.currentState.overlay.context,
        isDismissible: false,
        customBody: LoadingDialog(text: msg));
    dialog.style(borderRadius: 20);
    await dialog.show();
    return dialog;
  }

  static showRoundedDialog(
      {Widget content, BuildContext context, double radius = 8, bool barrierDismissible = true}) async {
    var res = await showDialog(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius)),
            child: content,
          );
        });
    return res;
  }

  static showBottomSheet({BuildContext context,List<Widget> widgets}) async{
    await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        builder: (context) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ...widgets,
                BottomSheetCancelItem()
              ],
            ),
          );
        });
  }
}
