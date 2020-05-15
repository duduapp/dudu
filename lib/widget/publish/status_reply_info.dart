import 'package:cached_network_image/cached_network_image.dart';
import 'package:fastodon/models/article_item.dart';
import 'package:fastodon/public.dart';
import 'package:flutter/material.dart';

import '../avatar.dart';

class StatusReplyInfo extends StatelessWidget {
  ArticleItem item;

  StatusReplyInfo(this.item);

  @override
  Widget build(BuildContext context) {
    var primaryColor = Theme.of(context).primaryColor;
    Widget image;

    if (item.mediaAttachments.length > 0 && item.mediaAttachments[0]['type'] == 'image') {
      image = CachedNetworkImage(imageUrl:  item.mediaAttachments[0]['preview_url']);
    } else {
      image = Avatar(url: item.account.avatarStatic);
    }
    return Container(
      margin: EdgeInsets.only(top:30),
      width: Screen.width(context) - 30,
      padding: EdgeInsets.only(top: 6,bottom: 7),
      color: primaryColor,
      child: ListTile(
        leading: image,
        title: Text('@'+item.account.acct,maxLines: 1,overflow: TextOverflow.ellipsis,),
        subtitle: Text(item.content,maxLines: 2,overflow: TextOverflow.ellipsis,),
      ),
    );
  }
}