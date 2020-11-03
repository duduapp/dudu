import 'package:badges/badges.dart';
import 'package:flutter/material.dart';

class BottomNaviBar extends StatelessWidget {
  final Icon icon;
  final Text title;
  final Function onTap;
  final bool showBadge;

  BottomNaviBar({this.icon, this.title, this.onTap, this.showBadge = true});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 5,
            ),
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
