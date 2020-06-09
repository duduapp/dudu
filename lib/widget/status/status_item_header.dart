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
            padding: EdgeInsets.fromLTRB(0, 15, 15, 0),
            child: GestureDetector(
              onTap: () {
                AppNavigate.push(context, UserMessage(account: data.account));
              },
              child: Avatar(url: data.account.avatarStatic),
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
                      child: Text(StringUtil.displayName(data.account),
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis),
                      flex: 2,
                    ),
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.only(right: 15),
                        child: Text(DateUntil.dateTime(data.createdAt),
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
                    Text('@' + data.account.username,
                        style:
                            TextStyle(fontSize: 13, color: MyColor.greyText)),
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
