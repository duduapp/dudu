

import 'package:dudu/db/db_provider.dart';

class InstanceColumn {
  static const table = 'user_instance';
  static const instance = 'instance';
  static const type = 'type'; // 3 for remote, 5 for custom instance

  static const info = 'info';
}

class TbInstanceHelper {
  static addInstance(String url) async{
    var db = await DBProvider().getDatabase();
    db.insert(InstanceColumn.table, {InstanceColumn.instance:url});
  }

  static removeInstance(String url) async{
     var db = await DBProvider().getDatabase();
     db.delete(InstanceColumn.instance,where: '${InstanceColumn.instance} = ?',whereArgs: [url]);
  }
}