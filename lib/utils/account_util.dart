import 'package:dudu/models/local_account.dart';
import 'package:dudu/models/logined_user.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/pages/home_page.dart';
import 'package:dudu/utils/app_navigate.dart';
import 'package:nav_router/nav_router.dart';

class AccountUtil {
  static switchToAccount(LocalAccount account) async{
    await LocalStorageAccount.setActiveAccount(account);
    LoginedUser().loadFromLocalAccount(account);
    await SettingsProvider().load();
    AppNavigate.pushAndRemoveUntil(HomePage(),
        routeType: RouterType.scale);
  }
}