

import 'dart:io';

import 'package:dudu/models/runtime_config.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class DefaultServerTask {

  static getServer() async{
    try {
      var response = await http.get('http://api.idudu.fans/static/server').timeout(
          Duration(seconds: Platform.isIOS ? 4 : 2)); // ios will prompt network access
      if (response != null) {
        RuntimeConfig.defaultServer = response.body.replaceAll('\n', "");
      }
    } catch (e) {
      // do nothing
    }

  }
}