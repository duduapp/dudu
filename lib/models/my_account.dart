import 'package:fastodon/api/accounts_api.dart';
import 'package:fastodon/models/json_serializable/owner_account.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyAccount {
  OwnerAccount account;
  AccountPreferences preferences;


  // 工厂模式
  factory MyAccount() =>_getInstance();
  static MyAccount get instance => _getInstance();
  static MyAccount _instance;
  MyAccount._internal() {
    // 
  }
  static MyAccount _getInstance() {
    if (_instance == null) {
      _instance = new MyAccount._internal();
    }
    return _instance;
  }

  // 从服务器获取设置和本地设置合并
  requestPrefrence() async{
    if (preferences != null) {
      preferences.request();
    } else {
      preferences = AccountPreferences(account);
      preferences.request();
    }
  }

  setAcc(OwnerAccount account) {
    this.account = account;
  }

  removeAcc() {
    this.account = null;
  }

  OwnerAccount getAcc() {
    return this.account;
  }



}

class AccountPreferences {
  static const SHOW_MEDIA = 'show_media';
  static const SHOW_SENSITIVE = 'show_sensitive';
  static const EXPAND_SPOILERS = 'expand_spoilers';

  OwnerAccount account;
  bool showMedia;
  bool showSensitive;
  bool expandSpoilers;

  AccountPreferences(this.account);

  _spKey(String str) {
    return account.acct + '/' + str;
  }

  request() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var res = await AccountsApi.getPreferences();
    var media = res['reading:expand:media'];
    switch(media) {
      case 'default':
        showMedia = true;
        showSensitive = false;
        break;
      case 'show_all':
        showMedia = true;
        showSensitive = true;
        break;
      case 'hide_all':
        showMedia = false;
        showMedia = false;
        break;
    }
    expandSpoilers = res['reading:expand:spoilers'];
    bool spShowMedia = prefs.getBool(_spKey(SHOW_MEDIA));
    bool spShowSensitive = prefs.get(_spKey(SHOW_SENSITIVE));
    bool spExpandSpoilers = prefs.get(_spKey(EXPAND_SPOILERS));

    showMedia = spShowMedia ?? showMedia;
    showSensitive = spShowSensitive ?? showSensitive;
    expandSpoilers = spExpandSpoilers ?? expandSpoilers;
  }

  setShowMedia(bool value) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    showMedia = value;
    prefs.setBool(_spKey(SHOW_MEDIA), value);
  }

  setShowSensitive(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    showSensitive = value;
    prefs.setBool(_spKey(SHOW_SENSITIVE), value);
  }

  setExpandSpoilers(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    expandSpoilers = expandSpoilers;
    prefs.setBool(_spKey(EXPAND_SPOILERS), value);
  }
}


