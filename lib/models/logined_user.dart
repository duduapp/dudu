import 'package:dudu/api/accounts_api.dart';
import 'package:dudu/models/json_serializable/owner_account.dart';
import 'package:dudu/models/local_account.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/local_storage.dart';

class LoginedUser {
  String host;
  String token;

  OwnerAccount account;
  String _fullAddress;
  bool _isAdmin;

  // 工厂模式
  factory LoginedUser() =>_getInstance();
  static LoginedUser get instance => _getInstance();
  static LoginedUser _instance;
  LoginedUser._internal() {
    // 
  }
  static LoginedUser _getInstance() {
    if (_instance == null) {
      _instance = new LoginedUser._internal();
    }
    return _instance;
  }

  logout() {
    host = null;
    token = null;
    account = null;
    _fullAddress = null;
    _isAdmin = null;
  }

  loadFromLocalAccount(LocalAccount localAccount) {
    host = localAccount.hostUrl;
    token = localAccount.token;
    account = localAccount.account;
    _fullAddress = StringUtil.accountFullAddress(localAccount.account);
    _isAdmin = Storage.getBoolWithAccount(StorageKey.isAdmin) ?? false;
  }

  String get fullAddress {
    if (account == null) return null;
    if (_fullAddress == null)
      _fullAddress = StringUtil.accountFullAddress(account);
    return _fullAddress;
  }

  bool get isAdmin {
    if (_isAdmin == null) {
      var admin =  Storage.getBoolWithAccount(StorageKey.isAdmin);
      if (admin == null) {
        return false;
      }
      _isAdmin = admin;
    }
    return _isAdmin;
  }

  set admin(bool admin) {
    _isAdmin = admin;
  }

  setHost(String host) {
    this.host = host;
  }

  setToken(String token) {
    this.token = token;
  }

  String getHost() {
    return this.host;
  }

  String getToken() {
    return this.token;
  }

  requestPreference() {
    AccountPreferences().request();
  }
}

class AccountPreferences {


  AccountPreferences();


  request() async{
    var res = await AccountsApi.getPreferences();
    if (res != null) {
      var media = res['reading:expand:media'];
      switch (media) {
        case 'default':
          SettingsProvider.updateWithCurrentContext('show_thumbnails', true);
          SettingsProvider.updateWithCurrentContext(
              'always_show_sensitive', false);
          break;
        case 'show_all':
          SettingsProvider.updateWithCurrentContext('show_thumbnails', true);
          SettingsProvider.updateWithCurrentContext(
              'always_show_sensitive', true);
          break;
        case 'hide_all':
          SettingsProvider.updateWithCurrentContext('show_thumbnails', false);
          SettingsProvider.updateWithCurrentContext(
              'always_show_sensitive', false);
          break;
      }
      SettingsProvider.updateWithCurrentContext('default_post_privacy', res['posting:default:visibility']);
      SettingsProvider.updateWithCurrentContext('always_expand_tools', res['reading:expand:spoilers']);
    }

  }


}

