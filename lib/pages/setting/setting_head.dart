import 'package:cached_network_image/cached_network_image.dart';
import 'package:dudu/models/json_serializable/owner_account.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/pages/setting/edit_user_profile.dart';
import 'package:dudu/pages/user_profile/user_follewers.dart';
import 'package:dudu/pages/user_profile/user_follewing.dart';
import 'package:dudu/pages/user_profile/user_profile.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/cache_manager.dart';
import 'package:dudu/widget/common/no_splash_ink_well.dart';
import 'package:dudu/widget/other/avatar.dart';
import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart';
import 'package:provider/provider.dart';

class SettingHead extends StatelessWidget {
  SettingHead({Key key}) : super(key: key);

  Widget userStatistics(BuildContext context,OwnerAccount account) {
    if (account == null) {
      return Container();
    }
    return Ink(
      color: Theme.of(context).primaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          NoSplashInkWell(
            child: headerSection(account.statusesCount, '嘟文'),
            onTap: () => AppNavigate.push(UserProfile(account,false)),
          ),
          NoSplashInkWell(
            child: headerSection(account.followingCount, '关注'),
            onTap: () => AppNavigate.push(UserFollowing(account.id)),
          ),
          NoSplashInkWell(
            child: headerSection(account.followersCount, '粉丝'),
            onTap: () => AppNavigate.push(UserFollowers(account.id)),
          ),
        ],
      ),
    );
  }

  Widget headerSection(int number, String title) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          Text('$number',
              style: TextStyle(fontSize: 15)),
          Text(title, style: TextStyle(fontSize: 13,color: Theme.of(navGK.currentContext).accentColor))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    OwnerAccount account = Provider.of<SettingsProvider>(context)?.currentUser?.account;

    return account == null? Container(height: 180,):Column(
      children: [
        Container(
          height: 180,
          width: ScreenUtil.width(context),
          decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.cover,
                  colorFilter: new ColorFilter.mode(
                      Colors.black.withOpacity(0.5), BlendMode.dstATop),
                  image: CachedNetworkImageProvider(
                    account.header,
                    cacheManager: CustomCacheManager()
                  ))),
          child: Column(
            children: [
              SizedBox(height: 90,),
              ListTile(
                leading: NoSplashInkWell(
                  onTap: () => AppNavigate.push(EditUserProfile(account)),
                  child: Avatar(
                    account: account,
                    width: 60,
                    height: 60,
                    navigateToDetail: false,
                  ),
                ),
                title: Text(
                  StringUtil.displayName(account),
                  style: TextStyle(fontSize: 18),
                ),
                subtitle: Text(StringUtil.accountFullAddress(account),
                    style: TextStyle(fontSize: 15)),
              )
            ],
          ),
        ),
        userStatistics(context,account)
      ],
    );
  }
}
