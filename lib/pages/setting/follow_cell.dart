import 'package:fastodon/models/json_serializable/owner_account.dart';
import 'package:fastodon/pages/user_profile/user_profile.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/widget/other/avatar.dart';
import 'package:flutter/material.dart';

class FollowCell extends StatefulWidget {
  FollowCell({Key key, this.item}) : super(key: key);
  final OwnerAccount item;

  @override
  _FollowCellState createState() => _FollowCellState();
}

class _FollowCellState extends State<FollowCell> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppNavigate.push(context, UserProfile(account: widget.item));
      },
      child: Container(
        color: MyColor.widgetDefaultColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(15),
                  child: Avatar(url: widget.item.avatar)
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(StringUtil.displayName(widget.item), style: TextStyle(fontSize: 16)),
                    Text('@' + widget.item.username,  style: TextStyle(fontSize: 13, color: MyColor.greyText)),
                  ],
                )
              ],
            ),
          ],
        )
      ),
    );
  }
}