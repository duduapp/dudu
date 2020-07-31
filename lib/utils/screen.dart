import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScreenUtil {
  static width(BuildContext context) {
    return MediaQuery.of(context).size.width;
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
    return 1.0 + 0.18 * double.parse(textScale);
  }
}
