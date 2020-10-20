import 'package:sqflite/sqlite_api.dart';

import 'db_provider.dart';

class CacheColumn {
  static const table = "cache";
  static const account = "account";
  static const tag = "tag";
  static const content = "content";
  static const time = "time"; // 消息未读数
}

class TbCache {
  String account;
  String tag;
  String content;
  DateTime time;

  TbCache({
    this.account,
    this.tag,
    this.content,
    DateTime time
  }):this.time = time ?? DateTime.now();

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      CacheColumn.account: account,
      CacheColumn.tag: tag,
      CacheColumn.content: content,
      CacheColumn.time: time.millisecondsSinceEpoch,
    };
    return map;
  }
}

class TbCacheHelper {

  static setCache(TbCache cache) async {
    var db = await DBProvider().getDatabase();
    db.insert(CacheColumn.table, cache.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static removeCache(String account,String tag) async{
    var db = await DBProvider().getDatabase();
    db.delete(CacheColumn.table,where: '${CacheColumn.account} = ? and ${CacheColumn.tag} = ?',whereArgs: [account, tag]);
  }

   static Future<TbCache> getCache(String account, String tag) async {
    var db = await DBProvider().getDatabase();
    List<Map> res = await db.query(CacheColumn.table,
        where: '${CacheColumn.account} = ? and ${CacheColumn.tag} = ?',
        whereArgs: [account, tag]);
    if (res.isEmpty) return null;
    var row = res[0];
    return TbCache(
        account: row[CacheColumn.account],
        tag: row[CacheColumn.tag],
        content: row[CacheColumn.content],
        time: DateTime.fromMillisecondsSinceEpoch(row[CacheColumn.time]));
  }
}
