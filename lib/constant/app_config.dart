import 'package:dudu/l10n/l10n.dart';
import 'package:dudu/constant/icon_font.dart';
import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart';

class AppConfig {
  static String get ClientName => S.of(navGK.currentState.overlay.context).app_name;
  static String RedirectUris = 'http://dudu.today/redirect.html';
  static String Scopes = 'read write follow push admin:write:accounts';
  static String website = 'http://dudu.today';

  static const String instancesUrl = 'http://api.idudu.fans/static/instances';

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
