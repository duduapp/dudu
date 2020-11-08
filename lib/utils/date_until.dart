import 'package:dudu/constant/storage_key.dart';
import 'package:dudu/db/tb_cache.dart';
import 'package:intl/intl.dart';

import 'local_storage.dart';

class DateUntil {
  static String dateTime(String timestamp) {
    DateTime now = new DateTime.now();
    DateTime publicTime = DateTime.parse(timestamp);
    Duration diff = now.difference(publicTime);
    if (diff.inDays > 30) {
      return timestamp.substring(0, timestamp.indexOf('T'));
    } else if (diff.inDays > 0) {
      return '${diff.inDays}天前';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}小时前';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inSeconds > 0) {
      return '${diff.inSeconds}秒前';
    } else {
      return '刚刚';
    }
  }

  static String absoluteTime(String datetime) {
    DateTime time = DateTime.parse(datetime).toLocal();
    DateTime now = DateTime.now().toLocal();


    if (now.year == time.year) {
      return DateFormat('MM-dd HH:mm').format(time);
    } else {
      return DateFormat('yyyy-MM-dd HH:mm').format(time);
    }
  }

  static hasMarkedTimeToday(String account,String key) async{
    var cache = await TbCacheHelper.getCache(account, key);

    if (cache == null) {
      return false;
    }
    var updateTime = DateTime.fromMillisecondsSinceEpoch(int.parse(cache.content));
    var now = DateTime.now();

    if (now.difference(updateTime).inDays >= 1 || now.day != updateTime.day) {
      return false;
    }
    return true;
  }

  // deprecated in next version
  static hasMarkedTimeDaily(String storageKey) {
    String lastUpdateTime =
     Storage.getString(storageKey);
    if (lastUpdateTime == null) {
      return false;
    }
    var now = DateTime.now();
    var updateTime = DateTime.parse(lastUpdateTime);

    if (now.difference(updateTime).inDays >= 1 || now.day != updateTime.day) {
      return false;
    }
    return true;
  }

  // set task has executed
  static markTime(String account,String storageKey) {
    TbCacheHelper.setCache(TbCache(account: account,tag: storageKey,content: DateTime.now().millisecondsSinceEpoch.toString()));
  }
}
