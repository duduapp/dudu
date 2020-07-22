import 'package:fastodon/models/json_serializable/owner_account.dart';

class StringUtil {
  static String displayName(OwnerAccount item) {
    String displayName = '';
    if (item.displayName == '' || item.displayName.length == 0) {
      displayName = item.acct;
    } else {
      displayName = item.displayName;
    }
    return displayName;
  }

  static String accountFullAddress(OwnerAccount account) {
    return '@'+account.acct+'@'+account.url.substring(account.url.indexOf('\/\/')+2,account.url.lastIndexOf('\/'));
  }
  
  static String accountDomain(OwnerAccount account) {
    return account.url.substring(account.url.indexOf('\/\/')+2,account.url.lastIndexOf('\/'));
  }

  static String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(
        r"<[^>]*>",
        multiLine: true,
        caseSensitive: true
    );

    return htmlText?.replaceAll(exp, '');
  }

  static String urlToFullAccountAddress(String url) {

  }

  static bool isUrl(String str) {
    return Uri.parse(str).isAbsolute;
  }
}
