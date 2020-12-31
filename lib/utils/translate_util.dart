import 'dart:io';

import 'package:dudu/utils/request.dart';
import 'package:translator/translator.dart';

class TranslateUtil {
  static List<String> engineName = ['Google','Google.cn'];
  static List engineUrl = ['https://translate.google.com','https://translate.google.cn','https://youdao.com'];

  static Future<String> translateByGoogleCn(String str) async{
    var url = 'http://translate.google.cn/translate_a/single?client=gtx&dt=t&dj=1&ie=UTF-8&sl=auto&tl='+Platform.localeName+'&q='+str;
    var res = await Request.get(url:url);
    if (res != null) {
      try {
        Map resMap = res as Map;
        if (resMap.containsKey('sentences')) {
          String transRes = '';
          for (Map s in resMap['sentences']) {
            if (s.containsKey('trans')) {
              transRes += s['trans'];
            }
          }
          return transRes;
        }
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<String> translateByGoogle(String str) async{
    var translator = GoogleTranslator();
    var locale = Platform.localeName;
    if (locale.contains('_')) {
      locale = locale.substring(0,locale.indexOf('_'));
    }
    var res = await translator.translate(str, to: locale);
    return res.text;
  }

  // do not use now
  static Future<String> translateByYoudao(String str) async{
    var res = Request.get(url: 'http://fanyi.youdao.com/translate?&doctype=json&type=AUTO&i='+str);
    if (res != null) {

    }
  }
}