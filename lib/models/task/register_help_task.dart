
import 'package:dudu/constant/storage_key.dart';
import 'package:dudu/models/http/http_response.dart';
import 'package:dudu/utils/device_util.dart';
import 'package:dudu/utils/local_storage.dart';
import 'package:dudu/utils/request.dart';
import 'package:flutter/foundation.dart';

class RegisterHelpTask {
  static start() {
    if (!kReleaseMode && !isRegistered()) {
      _registerHelpAccount();
    }
  }

  static _registerHelpAccount() async{
    debugPrint('start register account');
    String appId =  DeviceUtil.getAppId();
    String username = appId.substring(0,23);
    String password = appId.substring(24);
    String email = username+'@help.dudu.today';
    String local = 'zh-CN';
    var params = {
      'username':username,
      'email':email,
      'password':password,
      'agreement':'true',
      'locale':local
    };
    var header = {
      'Authorization':'Bearer u7LGsrL6G5HWnn5jmEzjK7flOiDDgrtF7KBPLiaqtuc'
    };

    HttpResponse response = await Request.post(url:'https://help.dudu.today/api/v1/accounts',params: params,header:header,returnAll: true,showDialog: false);
    debugPrint(response.body.toString());
    if (response.statusCode == 200 || response.statusCode == 422) {
      // register success or have registered
      Storage.saveBool(StorageKey.registeredHelpAccount, true);
    }
  }

  static bool isRegistered() {
    return Storage.getBool(StorageKey.registeredHelpAccount) != null;
  }

  static getEmail() {
    return DeviceUtil.getAppId().substring(0,23)+'@help.dudu.today';
  }

  static getPassword() {
    return DeviceUtil.getAppId().substring(24);
  }
}