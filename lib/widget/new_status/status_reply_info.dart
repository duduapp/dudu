import 'package:cached_network_image/cached_network_image.dart';
import 'package:dudu/models/json_serializable/article_item.dart';
import 'package:dudu/public.dart';
import 'package:flutter/material.dart';

import '../other/avatar.dart';

class StatusReplyInfo extends StatelessWidget {
  StatusItemData item;

  StatusReplyInfo(this.item);

  @override
  Widget build(BuildContext context) {
    var primaryColor = Theme.of(context).primaryColor;
    Widget image;

    if (item.mediaAttachments.length > 0 && item.mediaAttachments[0]['type'] == 'image') {
      image = CachedNetworkImage(imageUrl:  item.mediaAttachments[0]['preview_url'],fit: BoxFit.cover,width: 55,height: 55,);
    } else {
      image = Avatar(account: item.account,width: 55,height: 55,);
    }
    return Container(
      margin: EdgeInsets.only(top:30),
      width: ScreenUtil.width(context) - 30,
      padding: EdgeInsets.only(top: 3,bottom: 3),
      color: Theme.of(context).backgroundColor,
      child: ListTile(
        contentPadding: EdgeInsets.only(left: 8,right: 8),
        leading: image,
        title: Text('@'+item.account.acct,maxLines: 1,overflow: TextOverflow.ellipsis,),
        subtitle: Text(StringUtil.removeAllHtmlTags(item.content),maxLines: 2,overflow: TextOverflow.ellipsis,),
      ),
    );
  }
}