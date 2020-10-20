import 'package:dudu/constant/app_config.dart';
import 'package:dudu/db/tb_cache.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

import 'package:path/path.dart';

class DBProvider {
  static final DBProvider _instance = DBProvider._internal();
  static Database database;

  factory DBProvider() {
    return _instance;
  }

  Future<Database> getDatabase() async {
    if (database == null) {
      var databasesPath = await getDatabasesPath();
      String path = join(databasesPath, AppConfig.dbName);

      var adb = await openDatabase(path, version: 1,
          onCreate: (Database db, int version) async {
            await db.execute("CREATE TABLE ${CacheColumn.table}("
                "${CacheColumn.account} Text,"
                "${CacheColumn.tag} TEXT,"
                "${CacheColumn.content} TEXT,"
                "${CacheColumn.time} INTEGER"
                ")");

            await db.execute("CREATE UNIQUE INDEX ${CacheColumn.table}U1 ON ${CacheColumn.table}(${CacheColumn.account},${CacheColumn.tag})");
          });
      database = adb;
    }
    return database;



  }

  DBProvider._internal();
}
