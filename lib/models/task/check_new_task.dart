import 'dart:async';

import 'package:dudu/models/http/request_manager.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:flutter/cupertino.dart';

class CheckNewTask {
  static Timer timer;

  static init() {
    if (!SettingsProvider().get('red_dot_notfication')) {
      return;
    }
    start();
  }

  static start() {
    // debugPrint('fetch new task');
    // RequestManager.checkNewRecords();
    timer = Timer.periodic(Duration(minutes: 10), (t) {
      debugPrint('fetch new task');
      RequestManager.checkNewRecords();
    });
  }

  static stop() {
    timer?.cancel();
  }
}
