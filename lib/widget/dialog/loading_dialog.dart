import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingDialog extends StatelessWidget {
  final String text;
  final bool finished;

  LoadingDialog({this.text,this.finished = false});

  @override
  Widget build(BuildContext context) {
    Widget loadingIcon;
    if (finished) {
      loadingIcon = Icon(Icons.check_circle_outline,size: 40,color: Colors.white,);
    } else {
      loadingIcon =             SpinKitFadingCircle(
        size: 40,
        color: Colors.white,
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.all(20),
        width: 140,
        height: 110,
        color: Color.fromRGBO(54, 54, 54, 1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            loadingIcon,
            SizedBox(
              height: 10,
            ),
            Text(text ?? '加载中...',style: TextStyle(color: Colors.white),)
          ],
        ),
      ),
    );
  }
}
