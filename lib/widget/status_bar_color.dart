

import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';

class StatusBarColor extends StatefulWidget {
  final Widget child;
  final Color toColor;
  final Color fromColor;

  StatusBarColor({this.child,this.fromColor,this.toColor});

  @override
  _StatusBarColorState createState() => _StatusBarColorState();
}

class _StatusBarColorState extends State<StatusBarColor> {
  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(widget.toColor);
    FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
    return WillPopScope(child: widget.child,onWillPop: _onWillPop,);
  }

  Future<bool> _onWillPop() async {
    revertStatusBar();
    return true;
  }

  revertStatusBar() {
    FlutterStatusbarcolor.setStatusBarColor(widget.fromColor);
    FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
  }
}
