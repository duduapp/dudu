import 'package:dudu/l10n/l10n.dart';
import 'package:dudu/constant/storage_key.dart';
import 'package:dudu/db/tb_cache.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nav_router/nav_router.dart';

import 'local_storage.dart';

class DateUntil {
  static String dateTime(String timestamp,BuildContext context) {
    DateTime now = new DateTime.now();
    DateTime publicTime = DateTime.parse(timestamp);
    Duration diff = now.difference(publicTime);
    if (diff.inDays > 30) {
      return timestamp.substring(0, timestamp.indexOf('T'));
    } else if (diff.inDays > 0) {
      return S.of(context).days_ago(diff.inDays);
    } else if (diff.inHours > 0) {
      return S.of(context).hours_ago(diff.inHours);
    } else if (diff.inMinutes > 0) {
      return S.of(context).minutes_ago(diff.inMinutes);
    } else if (diff.inSeconds > 0) {
      return S.of(context).seconds_ago(diff.inSeconds);
    } else {
      return S.of(context).seconds_ago(0);//S.of(navGK.currentState.overlay.context).just;
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
