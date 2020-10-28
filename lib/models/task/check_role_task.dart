import 'package:dudu/api/admin_api.dart';
import 'package:dudu/constant/db_key.dart';
import 'package:dudu/models/logined_user.dart';
import 'package:dudu/public.dart';

class CheckRoleTask {

  static checkUserRole() async{
    if (await DateUntil.hasMarkedTimeToday(LoginedUser().fullAddress,DbKey.lastCheckRoleTime)) {
      _checkRole();
    }
  }

  static _checkRole() async{
    bool isAdmin = await AdminApi.warnUser(LoginedUser().account.id);
    LoginedUser().admin = isAdmin;
    Storage.saveBoolWithAccount(StorageKey.isAdmin, isAdmin);
    DateUntil.markTime(LoginedUser().fullAddress,DbKey.lastCheckRoleTime);
  }
}