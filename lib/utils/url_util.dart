import 'package:dudu/models/logined_user.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlUtil {
  static openUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url,forceSafariVC: false);
    } else {
      throw 'Could not launch $url';
    }
  }

  static String hostUrl(String url) {
    return 'https://' + Uri.parse(url).host;
  }


}
