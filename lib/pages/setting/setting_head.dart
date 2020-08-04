import 'package:cached_network_image/cached_network_image.dart';
import 'package:fastodon/models/json_serializable/owner_account.dart';
import 'package:fastodon/pages/user_profile/user_follewers.dart';
import 'package:fastodon/pages/user_profile/user_follewing.dart';
import 'package:fastodon/pages/user_profile/user_profile.dart';
import 'package:fastodon/pages/user_profile/user_status.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/widget/other/avatar.dart';
import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart';

class SettingHead extends StatelessWidget {
  SettingHead({Key key, this.account}) : super(key: key);
  final OwnerAccount account;

  Widget userStatistics(BuildContext context) {
    if (account == null) {
      return Container();
    }
    return Container(
      color: Theme.of(context).primaryColor,
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          InkWell(
            child: headerSection(account.statusesCount, '嘟文'),
            onTap: () => AppNavigate.push(UserStatus(account.id)),
          ),
          InkWell(
            child: headerSection(account.followingCount, '关注'),
            onTap: () => AppNavigate.push(UserFollowing(account.id)),
          ),
          InkWell(
            child: headerSection(account.followersCount, '粉丝'),
            onTap: () => AppNavigate.push(UserFollowers(account.id)),
          ),
        ],
      ),
    );
  }

  Widget headerSection(int number, String title) {
    return Column(
      children: <Widget>[
        Text('$number',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        Text(title, style: TextStyle(fontSize: 13,color: Theme.of(navGK.currentContext).accentColor))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  ))),
          child: Column(
            children: [
              SizedBox(height: 90,),
              ListTile(
                leading: Avatar(
                  account: account,
                  width: 60,
                  height: 60,
                ),
                title: Text(
                  StringUtil.displayName(account),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(StringUtil.accountFullAddress(account),
                    style: TextStyle(fontSize: 15)),
              )
            ],
          ),
        ),
        userStatistics(context)
      ],
    );
  }
}
