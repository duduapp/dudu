import 'package:dudu/models/logined_user.dart';
import 'package:dudu/public.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static SharedPreferences prefs;
  
  static loadSharedPrefrences() async{
    prefs = await SharedPreferences.getInstance();
  }
  
  static  saveString(String key, String value) async {
    try {
      prefs.setString(key, value);
    } catch (e) {
      debugPrint('存储失败');
    }
  }

  static String getString(String key) {
    try {
      String response = prefs.getString(key);
      return response;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static int getInt(String key) {
    try {
      int response = prefs.getInt(key);
      return response;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static void removeString(String key) async {
    try {
      prefs.remove(key);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static List<String> getStringList(String key) {
    try {
      return prefs.getStringList(key);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static bool getBool(String key) {
    try {
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

  static  getIntWithAccount(String key) {

    return getInt(_accountPrefix()+key);
  }
  static  getBoolWithAccount(String key) {

    return getBool(_accountPrefix()+key);
  }

  static void saveIntWithAccount(String key,int value) {
    saveInt(_accountPrefix()+key, value);
  }

  static void saveBoolWithAccount(String key,bool value) {
    saveBool(_accountPrefix()+key, value);
  }

  static getStringWithAccount(String key) {

    return getString(_accountPrefix()+key);
  }

  static void saveStringWithAccount(String key,String value) {
     saveString(_accountPrefix()+key, value);
  }
}