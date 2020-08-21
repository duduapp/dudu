import 'package:dudu/models/local_account.dart';
import 'package:dudu/models/logined_user.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/utils/notification_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'my_app.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  NotificationUtil.init();
  LocalAccount account = await LocalStorageAccount.getActiveAccount();
  if (account != null) {
    LoginedUser().loadFromLocalAccount(account);
  }
  await SettingsProvider().init();
  if (kReleaseMode) {
    debugPrint = (String message, {int wrapWidth}) {};
  }
  runApp(MyApp(logined: account != null,));
}
