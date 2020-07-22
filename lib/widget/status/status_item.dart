import 'package:cached_network_image/cached_network_image.dart';
import 'package:fastodon/models/json_serializable/article_item.dart';
import 'package:fastodon/pages/user_profile/user_profile.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/widget/status/status_item_account.dart';
import 'package:fastodon/widget/status/status_item_content.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../other/avatar.dart';
import 'article_media.dart';
import 'status_item_action.dart';

class StatusItem extends StatefulWidget {
  StatusItem({Key key, @required this.item, this.refIcon, this.refString, this.subStatus}) : super(key: key);
  final StatusItemData item;
  final IconData refIcon; // 用户引用status时显示的图标，比如 显示在status上面的（icon,who转嘟了）
  final String refString;
  final subStatus;

  @override
  _StatusItemState createState() => _StatusItemState();
}

class _StatusItemState extends State<StatusItem> {
  Widget articleMedia() {
    if (widget.item.card != null && widget.item.card.image != null) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(15),
            color: Colors.grey[50],
            child: Row(
              children: <Widget>[
                CachedNetworkImage(
                  imageUrl: widget.item.card.image,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.item.card.title,
                        style: TextStyle(fontSize: 15),
                        softWrap: false,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 5),
                      Text(widget.item.card.providerName, style: TextStyle(fontSize: 13, color: MyColor.greyText))
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else if(widget.item.mediaAttachments != null && widget.item.mediaAttachments.length != 0) {
      return ArticleMedia(
        itemList: widget.item.mediaAttachments,
      );
    } else {
      return Container();
    }
  }

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
        padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
        margin: EdgeInsets.only(bottom: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            refHeader(),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: StatusItemAccount(data.account,createdAt:data.createdAt),
            ),
            StatusItemContent(data),
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
        padding: EdgeInsets.only(top: 8),
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