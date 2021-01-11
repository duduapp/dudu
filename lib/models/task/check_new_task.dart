import 'dart:async';

import 'package:dudu/constant/api.dart';
import 'package:dudu/models/http/request_manager.dart';
import 'package:flutter/cupertino.dart';

class CheckNewTask {
    static Timer timer;

    static start() {
        // debugPrint('fetch new task');
        // RequestManager.checkNewRecords();
        timer = Timer.periodic(Duration(minutes: 10),(t){
            debugPrint('fetch new task');
            RequestManager.checkNewRecords();
        });
    }

    static stop() {
        timer?.cancel();
    }
}