import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:dudu/models/instance/instance_manager.dart';
import 'package:dudu/models/json_serializable/owner_account.dart';
import 'package:dudu/models/local_account.dart';
import 'package:dudu/models/logined_user.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/models/task/notification_task.dart';
import 'package:dudu/pages/home_page.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/app_navigate.dart';
import 'package:dudu/utils/cache_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:nav_router/nav_router.dart';

class AccountUtil {
  static switchToAccount(LocalAccount account) async{
    await LocalStorageAccount.setActiveAccount(account);
    LoginedUser().loadFromLocalAccount(account);
    await SettingsProvider().load();
    Request.closeHttpClient();
    InstanceManager.removeAll();
    AppNavigate.pushAndRemoveUntil(HomePage(),
        routeType: RouterType.scale);
  }

  //第一次登录缓存emoji,加快emoji显示速度
  static cacheEmoji() async{
    try {
      var res = await Request.get(url: Api.CustomEmojis,enableCache: true,cacheOption: buildCacheOptions(Duration(days: 7),forceRefresh: true));
      if (res != null)
        for (var row in res) {
          if (row['visible_in_picker']) {
            CustomCacheManager().getSingleFile(row['static_url']);
          }
        }
    } catch (e) {
      // ignore
    }

  }

  static requestPreference() async {
    try {
      LoginedUser user = LoginedUser();
      user.requestPreference();
    } catch (e) {
      // ignore
    }
  }

  static bool sameInstance(String url) {
    if (url.startsWith(LoginedUser().host)) {
      return true;
    }
    return false;
  }

  static updateAccount(OwnerAccount account) {
    LoginedUser().account = account;
    LocalStorageAccount.addOwnerAccount(account);
  }

  static saveState() async{
    debugPrint('start save state');
    await SettingsProvider().homeProvider?.saveDataToCache();
    await SettingsProvider().localProvider?.saveDataToCache();
    await SettingsProvider().federatedProvider?.saveDataToCache();
    await SettingsProvider().notificationProvider?.saveDataToCache();
    debugPrint('finish save state');
  }

  static restoreState() {
    debugPrint('remove state');
    SettingsProvider().homeProvider?.removeCache();
    SettingsProvider().localProvider?.removeCache();
    SettingsProvider().federatedProvider?.removeCache();
    SettingsProvider().notificationProvider?.removeCache();
  }


}