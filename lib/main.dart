import 'package:fastodon/models/local_account.dart';
import 'package:fastodon/utils/notification_util.dart';
import 'package:flutter/material.dart';

import 'my_app.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  NotificationUtil.init();
  LocalAccount account = await LocalStorageAccount.getActiveAccount();
  runApp(MyApp(logined: account != null,));
}
