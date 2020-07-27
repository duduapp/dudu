import 'package:fastodon/models/json_serializable/notificate_item.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/widget/other/avatar.dart';
import 'package:fastodon/widget/status/status_item_account.dart';
import 'package:flutter/material.dart';


class FollowCell extends StatelessWidget {
  FollowCell({Key key, @required this.item}) : super(key: key);
  final NotificationItem item;

  @override
  Widget build(BuildContext context) {

    return Container(
      color: Theme.of(context).primaryColor,
      padding: EdgeInsets.fromLTRB(15, 8, 15, 8),
      margin: EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Center(
                    child: Icon(Icons.remove_red_eye,color: Theme.of(context).buttonColor,),
                  ),
                ),
                SizedBox(width: 5,),
                Expanded(
                  child: Text(StringUtil.displayName(item.account) + '开始关注你了', style: TextStyle(fontSize: 14),),
                ),
              ],
            ),
          ),
          StatusItemAccount(item.account)
        ],
      ),
    );
  }
}

