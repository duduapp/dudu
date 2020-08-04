import 'package:intl/intl.dart';

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
}
