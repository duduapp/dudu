import 'package:fastodon/models/article_item.dart';
import 'package:fastodon/pages/setting/user_message.dart';
import 'package:fastodon/untils/app_navigate.dart';
import 'package:fastodon/untils/date_until.dart';
import 'package:fastodon/untils/my_color.dart';
import 'package:fastodon/untils/string_until.dart';
import 'package:flutter/material.dart';

import '../avatar.dart';

class StatusItemHeader extends StatelessWidget {
  final StatusItemData data;

  StatusItemHeader(this.data);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Padding(
            padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
            child: GestureDetector(
              onTap: () {
                AppNavigate.push(context, UserMessage(account: data.account));
              },
              child: Avatar(url: data.account.avatarStatic),
            )
        ),
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
                    Flexible(child: Text(StringUntil.displayName(data.account), style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),overflow: TextOverflow.ellipsis)),
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.only(right: 15),
                        child: Text(DateUntil.dateTime(data.createdAt) ,style: TextStyle(fontSize: 13, color: MyColor.greyText),overflow: TextOverflow.ellipsis),
                      ),
                    )
                  ],

                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('@' + data.account.username,  style: TextStyle(fontSize: 13, color: MyColor.greyText)),

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
