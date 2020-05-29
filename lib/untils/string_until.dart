import 'package:fastodon/models/owner_account.dart';

class StringUntil {
  static String displayName(OwnerAccount item) {
    String displayName = '';
    if (item.displayName == '' || item.displayName.length == 0) {
      displayName = item.acct;
    } else {
      displayName = item.displayName;
    }
    return displayName;
  }

  static String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(
        r"<[^>]*>",
        multiLine: true,
        caseSensitive: true
    );

    return htmlText?.replaceAll(exp, '');
  }
}
