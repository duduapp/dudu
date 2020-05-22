import 'package:fastodon/widget/status/status_item_content.dart';
import 'package:fastodon/widget/status/status_item_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:fastodon/public.dart';

import 'package:fastodon/pages/setting/user_message.dart';
import 'package:fastodon/models/article_item.dart';
import 'package:fastodon/pages/home/article_detail.dart';
import '../avatar.dart';
import 'status_item_action.dart';
import 'article_media.dart';

class StatusItem extends StatefulWidget {
  StatusItem({Key key, this.item}) : super(key: key);
  final StatusItemData item;

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
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          StatusItemHeader(widget.item),
          StatusItemContent(widget.item),
          StatusItemAction(
            item: widget.item,
          ),
          SizedBox(height: 10)
        ],
      ),
    );
  }
}