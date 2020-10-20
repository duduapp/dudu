import 'package:dudu/constant/icon_font.dart';
import 'package:flutter/material.dart';

class AppConfig {
  static String ClientName = '嘟嘟';
  static String RedirectUris = 'http://dudu.today/redirect.html';
  static String Scopes = 'read write follow push admin:write:accounts';
  static String website = 'http://dudu.today';

  static String dbName = "dudu.db";

  static String seed = 'DC814F2E67852803889C9EE84D189E1D255AF04F270D';

  static const Color buttonColor = Colors.blue;

  static const Map<String, IconData> visibilityIcons = {
    'public': IconFont.earth,
    'unlisted': IconFont.unlock,
    'private': IconFont.lock,
    'direct': IconFont.message
  };
}
