

import 'package:dudu/db/db_provider.dart';
import 'package:dudu/models/logined_user.dart';

class InstanceColumn {
  static const table = 'user_instance';
  static const account = 'account';
  static const instance = 'instance';
}

class TbInstanceHelper {
  static addInstance(String url) async{
    var db = await DBProvider().getDatabase();
    db.insert(InstanceColumn.table, {InstanceColumn.instance:url,InstanceColumn.account:LoginedUser().fullAddress});
  }

  static removeInstance(String url) async{
     var db = await DBProvider().getDatabase();
     db.delete(InstanceColumn.table,where: '${InstanceColumn.instance} = ?',whereArgs: [url]);
  }

  static Future<List> getInstanceList() async{
    var db = await DBProvider().getDatabase();
    List<Map> insList = await db.query(InstanceColumn.table);
    var list = [];
    for (Map map in insList) {
      String instance = map[InstanceColumn.instance];
      list.add(instance);
    }
    return list;
  }
}