import 'package:dudu/api/admin_api.dart';
import 'package:dudu/models/logined_user.dart';
import 'package:dudu/public.dart';

class CheckRoleTask {

  static checkUserRole() {
    if (DateUntil.hasMarkedTimeDaily(StringUtil.strWithAccountPrefix(StorageKey.lastCheckRoleTime))) {
      _checkRole();
    }
  }

  static _checkRole() async{
    bool isAdmin = await AdminApi.warnUser(LoginedUser().account.id);
    LoginedUser().admin = isAdmin;
    Storage.saveBoolWithAccount(StorageKey.isAdmin, isAdmin);
    DateUntil.markTime(StringUtil.strWithAccountPrefix(StorageKey.lastCheckRoleTime));
  }
}