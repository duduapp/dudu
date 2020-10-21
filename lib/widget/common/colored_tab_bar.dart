import 'package:flutter/material.dart';

class ColoredTabBar extends Container implements PreferredSizeWidget {
  ColoredTabBar({Key key,this.color, this.tabBar,this.height = 50}):super(key: key);

  final Color color;
  final Widget tabBar;
  final double height;

  @override
  Size get preferredSize =>  Size.fromHeight(height);

  @override
  Widget build(BuildContext context) => Container(
 //   width: double.infinity,
    height: height,
    color: color,
    child: Center(child: tabBar),
  );
}