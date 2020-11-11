import 'package:dudu/api/admin_api.dart';
import 'package:dudu/constant/db_key.dart';
import 'package:dudu/models/logined_user.dart';
import 'package:dudu/public.dart';
import 'package:flutter/foundation.dart';

class CheckRoleTask {

  static checkUserRole() async{
   if (!await DateUntil.hasMarkedTimeToday(LoginedUser().fullAddress,DbKey.lastCheckRoleTime)) {
      checkRole();
   }
  }

  static checkRole() async{
    bool isAdmin;
    try {
      isAdmin = await AdminApi.warnUser(LoginedUser().account.id);
    } catch (e) {
      debugPrint('error to take admin action,is not admin');
    }
    LoginedUser().admin = isAdmin;
    Storage.saveBoolWithAccount(StorageKey.isAdmin, isAdmin);
    DateUntil.markTime(LoginedUser().fullAddress,DbKey.lastCheckRoleTime);

  }
}