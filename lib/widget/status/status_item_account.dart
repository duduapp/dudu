import 'package:fastodon/models/article_item.dart';
import 'package:fastodon/models/owner_account.dart';
import 'package:fastodon/pages/setting/user_message.dart';
import 'package:fastodon/utils/app_navigate.dart';
import 'package:fastodon/utils/date_until.dart';
import 'package:fastodon/utils/my_color.dart';
import 'package:fastodon/utils/string_until.dart';
import 'package:flutter/material.dart';

import '../other/avatar.dart';

class StatusItemAccount extends StatelessWidget {
  final OwnerAccount account;

  final String createdAt;
  final Widget action;

  StatusItemAccount(this.account,{this.createdAt,this.action});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){if(createdAt == null) AppNavigate.push(context, UserMessage(account: account));}, // 用作搜索页时，整个页面可点击
      child: Row(
        children: <Widget>[
          Padding(
              padding: EdgeInsets.fromLTRB(0, 15, 15, 0),
              child: InkWell(
                onTap: () {
                  AppNavigate.push(context, UserMessage(account: account));
                },
                child: Avatar(url: account.avatarStatic),
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
                      if (createdAt != null)
                      Flexible(
                        child: Padding(
                          padding: EdgeInsets.only(right: 15),
                          child: Text(DateUntil.dateTime(createdAt),
                              style: TextStyle(
                                  fontSize: 13, color: MyColor.greyText),
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
                              TextStyle(fontSize: 13, color: MyColor.greyText)),
                    ],
                  )
                ],
              ),
            ),
          ),
          if (action != null)
            action
        ],
      ),
    );
  }
}

class SubStatusItemHeader extends StatelessWidget {
  final StatusItemData data;

  SubStatusItemHeader(this.data);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child:
            RichText(
              maxLines: 1,
              text: TextSpan(
                text: StringUtil.displayName(data.account)+' ',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,color: Colors.grey[850]),
                children: <TextSpan>[
                  TextSpan(text: '@' + data.account.username, style: TextStyle(fontSize: 13, color: MyColor.greyText))
                ]
              ),
              overflow: TextOverflow.ellipsis,
            )
//            Row(
//              children: <Widget>[
//                Text(StringUtil.displayName(data.account),
//                    style: TextStyle(
//                        fontSize: 16, fontWeight: FontWeight.bold),
//                    overflow: TextOverflow.ellipsis),
//                SizedBox(width: 2,),
//                Text('@' + data.account.username,
//                    style:
//                    TextStyle(fontSize: 13, color: MyColor.greyText),overflow: TextOverflow.ellipsis),
//              ],
//            ),
          ),

          Padding(
            padding: EdgeInsets.only(right: 15),
            child: Text(DateUntil.dateTime(data.createdAt),
                style: TextStyle(fontSize: 13, color: MyColor.greyText),
                overflow: TextOverflow.ellipsis),
          )
        ],
      ),
    );
  }
}
