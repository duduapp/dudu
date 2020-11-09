import 'package:dudu/constant/db_key.dart';
import 'package:dudu/models/logined_user.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/account_util.dart';

class GetEmojiTask {
  static get () async{
    if (LoginedUser().account != null) {
      if (!await DateUntil.hasMarkedTimeToday(LoginedUser().fullAddress, DbKey.lastGetEmojiTime)) {
        _fetchEmojiList();
      }
    }

  }

  static _fetchEmojiList() {
    if (LoginedUser().account != null) {
      AccountUtil.cacheEmoji();
      DateUntil.markTime(LoginedUser().fullAddress, DbKey.lastGetEmojiTime);
    }
  }
}