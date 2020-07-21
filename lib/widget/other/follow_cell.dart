import 'package:fastodon/models/json_serializable/notificate_item.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/widget/other/avatar.dart';
import 'package:flutter/material.dart';


class FollowCell extends StatelessWidget {
  FollowCell({Key key, @required this.item}) : super(key: key);
  final NotificationItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      margin: EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 10,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: 15),
                child: Center(
                  child: Icon(Icons.remove_red_eye),
                ),
              ),
              SizedBox(width: 5,),
              Expanded(
                child: Text(StringUtil.displayName(item.account) + '开始关注你了', style: TextStyle(fontSize: 14),),
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
                      Text(StringUtil.displayName(item.account), style: TextStyle(fontSize: 16)),
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

