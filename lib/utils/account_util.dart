import 'package:dudu/models/local_account.dart';
import 'package:dudu/models/logined_user.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/pages/home_page.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/app_navigate.dart';
import 'package:dudu/utils/cache_manager.dart';
import 'package:nav_router/nav_router.dart';

class AccountUtil {
  static switchToAccount(LocalAccount account) async{
    await LocalStorageAccount.setActiveAccount(account);
    LoginedUser().loadFromLocalAccount(account);
    await SettingsProvider().load();
    Request.closeDioClient();
    AppNavigate.pushAndRemoveUntil(HomePage(),
        routeType: RouterType.scale);
  }

  //第一次登录缓存emoji,加快emoji显示速度
  static cacheEmoji() async{
    var res = await Request.get(url: Api.CustomEmojis);
    if (res != null)
    for (var row in res) {
      if (row['visible_in_picker']) {
        CustomCacheManager().downloadFile(row['static_url']);
      }
    }
  }
}