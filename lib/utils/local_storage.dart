import 'package:fastodon/models/my_account.dart';
import 'package:fastodon/public.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static void saveString(String key, String value) async {
    try {
      print(key + value);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(key, value);
    } catch (e) {
      print('存储失败');
    }
  }

  static Future<String> getString(String key) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String response = prefs.getString(key);
      return response;
    } catch (e) {
      print('报错了');
      print(e.toString());
      return null;
    }
  }

  static Future<int> getInt(String key) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int response = prefs.getInt(key);
      return response;
    } catch (e) {
      print('报错了');
      print(e.toString());
      return null;
    }
  }

  static void removeString(String key) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove(key);
    } catch (e) {
      print('报错了');
      print(e.toString());
      return null;
    }
  }

  static Future<List<String>> getStringList(String key) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(key);
    } catch (e) {
      print('报错了');
      print(e.toString());
      return null;
    }
  }

  static Future saveInt(String key,int value) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.setInt(key,value);
    } catch (e) {
      print('报错了');
      print(e.toString());
      return null;
    }
  }

  static Future saveStringList(String key,List<String> value) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.setStringList(key,value);
    } catch (e) {
      print('报错了');
      print(e.toString());
      return null;
    }
  }

  static String _accountPrefix() {
    MyAccount myAccount = MyAccount();
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