import 'package:fastodon/models/json_serializable/owner_account.dart';
import 'package:fastodon/pages/user_profile/user_profile.dart';
import 'package:fastodon/utils/app_navigate.dart';
import 'package:fastodon/utils/date_until.dart';
import 'package:fastodon/utils/string_until.dart';
import 'package:fastodon/widget/other/avatar.dart';
import 'package:flutter/material.dart';

class AccountItem extends StatelessWidget {
  AccountItem(this.account);

  final OwnerAccount account;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Padding(
            padding: EdgeInsets.fromLTRB(0, 15, 15, 0),
            child: GestureDetector(
              onTap: () {
                AppNavigate.push(UserProfile(accountId: account.id));
              },
              child: Avatar(account: account,),
            )),
        Expanded(
          child: Container(
            height: 50,
            margin: EdgeInsets.only(top: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      child: Text(StringUtil.displayName(account),
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis),
                      flex: 2,
                    ),
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.only(right: 15),
                        child: Text(DateUntil.dateTime(account.createdAt),
                            style: TextStyle(
                                fontSize: 13, color: Theme.of(context).accentColor),
                            overflow: TextOverflow.ellipsis),
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('@' + account.username,
                        style:
                        TextStyle(fontSize: 13, color: Theme.of(context).accentColor)),
                  ],
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
