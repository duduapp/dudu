import 'package:flutter/material.dart';

import 'package:fastodon/public.dart';

import 'model/notificate_item.dart';
import 'package:fastodon/widget/avatar.dart';

class FollowCell extends StatelessWidget {
  FollowCell({Key key, @required this.item}) : super(key: key);
  final NotificateItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MyColor.widgetDefaultColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 10,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 80,
                child: Center(
                  child: Icon(Icons.remove_red_eye),
                ),
              ),
              Expanded(
                child: Text(StringUntil.displayName(item.account) + '开始关注你了', style: TextStyle(fontSize: 14),),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: Avatar(url: item.account.avatar)
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(StringUntil.displayName(item.account), style: TextStyle(fontSize: 16)),
                      Text('@' + item.account.username,  style: TextStyle(fontSize: 13, color: MyColor.greyText)),
                    ],
                  )
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}

