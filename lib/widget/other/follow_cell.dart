import 'package:dudu/l10n/l10n.dart';
import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/models/json_serializable/notificate_item.dart';
import 'package:dudu/public.dart';
import 'package:dudu/widget/status/status_item_account.dart';
import 'package:dudu/widget/status/text_with_emoji.dart';
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
                    child: Icon(IconFont.personAdd,color: Theme.of(context).buttonColor,),
                  ),
                ),
                SizedBox(width: 5,),
                Expanded(
                  child: TextWithEmoji(text:  S.of(context).started_following_you(StringUtil.displayName(item.account)),emojis: item.account.emojis,style: TextStyle(fontSize: 12),),
                ),
              ],
            ),
          ),
          StatusItemAccount(item.account,noNavigateOnClick: false,padding: 0,)
        ],
      ),
    );
  }
}

