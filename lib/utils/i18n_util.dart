import 'package:flutter/cupertino.dart';

class I18nUtil {
  static bool isZh(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'zh';
  }
}