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

  Widget header(BuildContext context) {
    if (account == null) {
      return Container(
        height: 150,
      );
    }
    return Container(
      height: 150,
      child: CachedNetworkImage(
        height: 150,
        width: Screen.width(context),
        imageUrl: account.header,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget displayName() {
    if (account == null) {
      return Container();
    }
    return Positioned(
      top: 130,
      left: 100,
      child: Text(StringUtil.displayName(account),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget userName() {
    if (account == null) {
      return Container();
    }
    return Positioned(
      top: 5,
      left: 100,
      child: Text(StringUtil.accountFullAddress(account),
          style: TextStyle(
              color: Theme.of(navGK.currentContext).splashColor, fontSize: 15)),
    );
  }

  Widget headerWidget() {
    if (account == null) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          InkWell(
            child: headerSection(account.statusesCount, '嘟文'),
            onTap: () => AppNavigate.push(null, UserStatus(account.id)),
          ),
          InkWell(
            child: headerSection(account.followingCount, '关注'),
            onTap: () => AppNavigate.push(null, UserFollowing(account.id)),
          ),
          InkWell(
            child: headerSection(account.followersCount, '粉丝'),
            onTap: () => AppNavigate.push(null, UserFollowers(account.id)),
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
        Text(title, style: TextStyle(fontSize: 13, color: MyColor.greyText))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                height: 180,
                child: Column(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        header(context),
                        Positioned(
                          top: Screen.statusBarHeight(context) + 15,
                          left: 0,
                          width: Screen.width(context),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('个人中心',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        displayName(),
                      ],
                    ),
                    Stack(
                      children: <Widget>[
                        Container(
                          height: 30,
                        ),
                        userName(),
                      ],
                    )
                  ],
                ),
              ),
              Positioned(left: 40, top: 125, child: InkWell(child: Avatar(url: account.avatar),onTap: () => AppNavigate.push(null, UserProfile(accountId: account.id,)),))
            ],
          ),
          Container(height: 50, child: headerWidget()),
        ],
      ),
    );
  }
}
