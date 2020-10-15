import 'package:dudu/constant/storage_key.dart';
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


  static hasMarkedTimeDaily(String storageKey) {
    String lastUpdateTime =
     Storage.getString(storageKey);
    if (lastUpdateTime == null) {
      return true;
    }
    var now = DateTime.now();
    var updateTime = DateTime.parse(lastUpdateTime);

    if (now.difference(updateTime).inDays >= 1 || now.day != updateTime.day) {
      return true;
    }
    return false;
  }

  // set task has executed
  static markTime(String storageKey) {
    Storage.saveString(
        storageKey, DateTime.now().toIso8601String());
  }
}
