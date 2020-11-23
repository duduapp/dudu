import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dudu/constant/app_config.dart';
import 'package:dudu/utils/local_storage.dart';
import 'package:uuid/uuid.dart';

class DeviceUtil {

  static String getAppId() {
    String appId = Storage.getString('app_id');
    if (appId == null) {
      appId = generateAppId();
      Storage.saveString('app_id', appId);
    }
    return appId;
  }

  static String generateAppId() {
    var uuid = Uuid();
    String uuidStr =  sha256.convert(utf8.encode(uuid.v4())).toString().substring(0,32);
    var hash = sha256.convert(utf8.encode(uuidStr + AppConfig.seed)).toString();
    return uuidStr + hash.substring(0,8);
  }
}