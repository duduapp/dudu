import 'dart:io';

import 'package:fastodon/public.dart';
import 'package:fastodon/widget/common/no_splash_ink_well.dart';
import 'package:flutter/material.dart';

class BottomSheetItem extends StatelessWidget {
  final String text;
  final String subText;
  final Function onTap;
  final double height;
  final bool safeArea;
  final bool bottomBorder;
  final IconData icon;
  final bool border;
  final Color color;

  BottomSheetItem(
      {this.text,
      this.subText,
      this.icon,
      this.onTap,
      this.height,
      this.safeArea = false,
      this.bottomBorder,
      this.border,
      this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      onTap: onTap,
      child: Container(
   //     height: height,
        width: double.infinity,
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: icon != null ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 10,
            ),
            if (icon != null) ...[
            Icon(icon,color: color ?? Theme.of(context).textTheme.bodyText1.color,size: 25,),
            SizedBox(
              width: 20,
            ),],
            if (subText != null) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(text,style: TextStyle(fontSize: 16),),
                  Text(subText,style: TextStyle(fontSize: 12,color: Theme.of(context).accentColor),)
                ],
              ),
            ] else ...[
              Text(
                text,
                style: TextStyle(fontSize: 16,color: color),
              )
            ],
          ],
        ),
      ),
    );
  }
}

class BottomSheetCancelItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NoSplashInkWell(
      onTap: () => AppNavigate.pop(),
      child: SafeArea(
        child: Container(
          width: double.infinity,
          padding: Platform.isAndroid
              ? EdgeInsets.fromLTRB(12, 12, 12, 20)
              : EdgeInsets.all(12),
          child: Align(
            child: Text('取消'),
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }
}
