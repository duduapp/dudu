import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScreenUtil {
  static width(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static height(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static heightWithoutAppBar(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    var padding = MediaQuery.of(context).padding;
    return height - padding.top - kToolbarHeight;
  }

  static appBarAndStatusBarHeight(BuildContext context) {
    var padding = MediaQuery.of(context).padding;
    return kToolbarHeight + padding.top;
  }

  static navigationBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top + 44;
  }

  static statusBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  static bottomSafeHeight(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }

  static topSafeHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  static updateStatusBarStyle(SystemUiOverlayStyle style) {
    SystemChrome.setSystemUIOverlayStyle(style);
  }

  static scaleFromSetting(String textScale) {
    return 1.0 + 0.12 * double.parse(textScale);
  }

  static htmlTextScaleFromSetting(String textScale) {
    return 0.9 + 0.14 * double.parse(textScale);
  }
}
