import 'package:dudu/constant/icon_font.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  final String text;
  final bool finished;

  LoadingDialog({this.text,this.finished = false});

  @override
  Widget build(BuildContext context) {
    Widget loadingIcon;
    if (finished) {
      loadingIcon = Icon(IconFont.checkCircle,size: 40,color: Colors.white,);
    } else {
      loadingIcon =             CircularProgressIndicator(
        strokeWidth: 1,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.all(20),
        constraints: BoxConstraints(minWidth: 140),
     //   width: 140,
        color: Color.fromRGBO(54, 54, 54, 1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            loadingIcon,
            if (text != null && text.isNotEmpty) ...[
            SizedBox(
              height: 10,
            ),
            Text(text,style: TextStyle(color: Colors.white),)]
          ],
        ),
      ),
    );
  }
}
