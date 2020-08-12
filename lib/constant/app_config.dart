import 'package:dio/dio.dart';
import 'package:fastodon/constant/icon_font.dart';
import 'package:flutter/material.dart';

class AppConfig {
  static String ClientName = '嘟嘟';
  static String RedirectUris = 'https://google.com';
  static String Scopes = 'read write follow push';

  static const Color buttonColor = Colors.blue;

  static const Map<String, IconData> visibilityIcons = {
    'public': IconFont.earth,
    'unlisted': IconFont.unlock,
    'private': IconFont.lock,
    'direct': IconFont.message
  };
}
