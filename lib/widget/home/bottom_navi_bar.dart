import 'dart:io';

import 'package:badges/badges.dart';
import 'package:dudu/public.dart';
import 'package:flutter/material.dart';

class BottomNaviBar extends StatelessWidget {
  final Icon icon;
  final Text title;
  final Function onTap;
  final Function onDoubleTap;
  final bool showBadge;

  BottomNaviBar({this.icon, this.title, this.onTap, this.onDoubleTap,this.showBadge = true});

  @override
  Widget build(BuildContext context) {
    return InkWell(
   //   onDoubleTap: onDoubleTap,
      onTap: onTap,
      child: Container(
        width: ScreenUtil.width(context)/5,
        padding: EdgeInsets.only(top: 5,bottom: Platform.isAndroid ? 5 :0,),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Badge(
              child: icon,
              showBadge: showBadge,
              position: BadgePosition.topEnd(top: -1, end: -5),
            ),
            title,
          ],
        ),
      ),
    );
  }
}
