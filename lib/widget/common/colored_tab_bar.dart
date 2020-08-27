import 'package:flutter/material.dart';

class ColoredTabBar extends Container implements PreferredSizeWidget {
  ColoredTabBar({this.color, this.tabBar,this.height = 50});

  final Color color;
  final Widget tabBar;
  final double height;

  @override
  Size get preferredSize =>  Size.fromHeight(height);

  @override
  Widget build(BuildContext context) => Container(
    color: color,
    child: tabBar,
  );
}