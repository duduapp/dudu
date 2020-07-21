import 'package:fastodon/models/logined_user.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/utils/local_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart';
import 'package:provider/provider.dart';

enum SettingType {
  bool,
  string
}

class SettingsProvider extends ChangeNotifier {
  Map<String,dynamic> settings = {
  };

  String storageKey;

  SettingsProvider(){
    load();
  }

  load() {
    settings = {
      'show_thumbnails':true,
      'always_show_sensitive':false,
      'always_expand_tools':false,
      'default_post_privacy':'public',
      'make_media_sensitive':false,
      'text_scale':'1',

      'show_notifications':true,
      'show_notifications.reblog':true,
      'show_notifications.favourite': true,
      'show_notifications.follow_requests':true,
      'show_notifications.follow':true,
      'show_notifications.mention':true,
      'show_notifications.poll':true


    };
    _loadFromStorage();
  }

  _loadFromStorage() async{
    LoginedUser user = LoginedUser();
    if (user.account == null) {
      return;
    }
    storageKey = StringUtil.accountFullAddress(user.account)+'.settings';
    var keys = await Storage.getStringList(storageKey);
    if (keys == null) {
      await Storage.saveStringList(storageKey, settings.keys.toList());
      return;
    }
    for (String key in keys) {
      var type = await Storage.getString('$storageKey.$key.type');
      var settingType = SettingType.values.firstWhere((e) => describeEnum(e) == type,orElse: () => null);
      if (settingType != null) {
        dynamic value;
        switch (settingType) {
          case SettingType.bool:
            value = await Storage.getBool('$storageKey.$key.value');
            break;
          case SettingType.string:
            value = await Storage.getString('$storageKey.$key.value');
            break;
        }
        if (value != null) {
          settings[key] = value;
        }
      }
    }
  }

  update(String key,dynamic value) {
    settings[key] = value;
    if (value is String) {
      Storage.saveString('$storageKey.$key.type', 'string');
      Storage.saveString('$storageKey.$key.value', value);
      _saveKeys();
    } else if (value is bool) {
      Storage.saveString('$storageKey.$key.type', 'bool');
      Storage.saveBool('$storageKey.$key.value', value);
      _saveKeys();
    }
    notifyListeners();
  }

  _saveKeys() {
    Storage.saveStringList(storageKey, settings.keys.toList());
  }

  get(String key) {
    return settings[key];
  }

  static SettingsProvider getCurrentContextProvider({listen = false}) {
    return Provider.of<SettingsProvider>(navGK.currentContext,listen: listen);
  }

  static dynamic getWithCurrentContext(String key,{listen = false}) {
    SettingsProvider provider = getCurrentContextProvider(listen: listen);
    return provider.get(key);
  }

  static updateWithCurrentContext(String key,dynamic value) {
    SettingsProvider provider = getCurrentContextProvider();
    provider.update(key, value);
  }


}