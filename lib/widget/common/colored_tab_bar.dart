import 'package:flutter/material.dart';

class ColoredTabBar extends Container implements PreferredSizeWidget {
  ColoredTabBar({this.color, this.tabBar});

  final Color color;
  final Widget tabBar;

  @override
  Size get preferredSize =>  Size.fromHeight(50);

  @override
  Widget build(BuildContext context) => Container(
    color: color,
    child: tabBar,
  );
}