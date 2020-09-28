import 'package:dudu/models/runtime_config.dart';
import 'package:http/http.dart' as http;

class DefaultServerTask {

  static getServer() async{
    try {
      var response = await http.get('http://api.idudu.fans/static/server').timeout(
          Duration(seconds: 2));
      if (response != null) {
        RuntimeConfig.defaultServer = response.body.replaceAll('\n', "");
      }
    } catch (e) {
      // do nothing
    }

  }
}