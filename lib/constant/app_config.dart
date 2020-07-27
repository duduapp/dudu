import 'package:flutter/material.dart';

class AppConfig {
  static String ClientName = 'masfto';
  static String RedirectUris = 'https://google.com';
  static String Scopes = 'read write follow push';

  static bool dialogOpened = false;

  static const Color buttonColor = Colors.blue;

  static const Map<String, IconData> visibilityIcons = {
    'public': Icons.public,
    'unlisted': Icons.lock_open,
    'private': Icons.lock_outline,
    'direct': Icons.mail_outline
  };
}
