import 'package:dudu/l10n/l10n.dart';
import 'package:dudu/models/local_account.dart';
import 'package:dudu/models/logined_user.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/models/task/check_new_task.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/local_storage.dart';
import 'package:dudu/utils/notification_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart';

import 'my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationUtil.init();
  await Storage.loadSharedPrefrences();
  LocalAccount account = await LocalStorageAccount.getActiveAccount();
  // UpdateTask.checkUpdateIfNeed();
  if (account != null && account.account.acct != null) {
    LoginedUser().loadFromLocalAccount(account);
  } else {
    //await DefaultServerTask.getServer();
  }

  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    return Container(
      child: Center(
        child: Text(
          S.of(navGK.currentState.overlay.context).an_error_occurred,
        ),
      ),
    );
  };

  await SettingsProvider().init();
  CheckNewTask.init();
  LocalStorageAccount.load();
  if (kReleaseMode) {
    debugPrint = (String message, {int wrapWidth}) {};
  }
  runApp(MyApp(
    logined: account != null,
  ));
}
