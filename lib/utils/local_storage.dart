import 'package:dudu/models/logined_user.dart';
import 'package:dudu/public.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static void saveString(String key, String value) async {
    try {
      print(key + value);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(key, value);
    } catch (e) {
      debugPrint('存储失败');
    }
  }

  static Future<String> getString(String key) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String response = prefs.getString(key);
      return response;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future<int> getInt(String key) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int response = prefs.getInt(key);
      return response;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static void removeString(String key) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove(key);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future<List<String>> getStringList(String key) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(key);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future<bool> getBool(String key) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool(key);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future saveBool(String key,bool value) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.setBool(key,value);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future saveInt(String key,int value) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.setInt(key,value);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future saveStringList(String key,List<String> value) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.setStringList(key,value);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static String _accountPrefix() {
    LoginedUser myAccount = LoginedUser();
    return StringUtil.accountFullAddress(myAccount.account);
  }

  static Future getIntWithAccount(String key) {

    return getInt(_accountPrefix()+key);
  }

  static void saveIntWithAccount(String key,int value) {
    saveInt(_accountPrefix()+key, value);
  }

  static Future getStringWithAccount(String key) {

    return getString(_accountPrefix()+key);
  }

  static void saveStringWithAccount(String key,String value) {
     saveString(_accountPrefix()+key, value);
  }
}