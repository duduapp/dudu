import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static void save(String key, String value) async {
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
}