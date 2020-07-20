import 'package:fastodon/models/json_serializable/owner_account.dart';

class LoginedUser {
  String host;
  String token;

  OwnerAccount account;

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
}

