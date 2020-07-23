import 'package:cached_network_image/cached_network_image.dart';
import 'package:fastodon/models/json_serializable/article_item.dart';
import 'package:fastodon/pages/user_profile/user_profile.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/widget/status/status_item_account.dart';
import 'package:fastodon/widget/status/status_item_card.dart';
import 'package:fastodon/widget/status/status_item_content.dart';
import 'package:fastodon/widget/status/status_item_primary_bottom.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../other/avatar.dart';
import 'status_item_action.dart';

class StatusItem extends StatefulWidget {
  StatusItem({Key key, @required this.item, this.refIcon, this.refString, this.subStatus,this.primary = false}) : super(key: key);
  final StatusItemData item;
  final IconData refIcon; // 用户引用status时显示的图标，比如 显示在status上面的（icon,who转嘟了）
  final String refString;
  final bool subStatus;
  final bool primary; // 点击status详情页后该status

  @override
  _StatusItemState createState() => _StatusItemState();
}

class _StatusItemState extends State<StatusItem> {

  @override
  Widget build(BuildContext context) {
    if (widget.subStatus != null && widget.subStatus) {
      return Container(
        color: Theme
            .of(context)
            .primaryColor,
        padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
        margin: EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
              child: Avatar(url: widget.item.account.avatarStatic),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  SubStatusItemHeader(widget.item),
                  StatusItemContent(widget.item),
                  StatusItemAction(item:widget.item)
                ],
              ),
            )
          ],
        ),
      );
    } else {
      StatusItemData data = widget.item.reblog ?? widget.item;
      return Container(
        color: Theme
            .of(context)
            .primaryColor,
        padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
        margin: EdgeInsets.only(bottom: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            refHeader(),
            StatusItemAccount(data.account,createdAt:widget.primary ?null :data.createdAt),
            StatusItemContent(data,primary: widget.primary,),
            StatusItemCard(data),
            if (widget.primary) StatusItemPrimaryBottom(data),
            StatusItemAction(
              item: data
            ),
          ],
        ),
      );
    }
  }

  Widget refHeader() {
    IconData icon = widget.refIcon;
    String str = widget.refString;

    if (widget.item.reblog != null) {
      icon = Icons.repeat;
      str = '${StringUtil.displayName(widget.item.account)}转嘟了';
    }

    return (icon != null && str != null) ? InkWell(
      onTap: () => AppNavigate.push(context, UserProfile(accountId: widget.item.account.id,)),
      child: Container(
        padding: EdgeInsets.only(top: 3,bottom: 8),
        child: Row(
          children: <Widget>[
            Icon(icon,color: Theme.of(context).buttonColor,),
            SizedBox(width: 5,),
            Text(str,)
          ],
        ),
      ),
    ) : Container();
  }
}