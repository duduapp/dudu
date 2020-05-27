

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fastodon/models/article_item.dart';
import 'package:fastodon/untils/my_color.dart';
import 'package:fastodon/widget/status/status_item_media.dart';
import 'package:fastodon/widget/status/status_item_poll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'article_media.dart';

class StatusItemContent extends StatefulWidget {
  final StatusItemData data;

  StatusItemContent(this.data);

  @override
  _StatusItemContentState createState() => _StatusItemContentState();
}

class _StatusItemContentState extends State<StatusItemContent> {
  Widget articleMedia() {
    if (widget.data.card != null && widget.data.card.image != null) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(15),
            color: Colors.grey[50],
            child: Row(
              children: <Widget>[
                CachedNetworkImage(
                  imageUrl: widget.data.card.image,
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
                        widget.data.card.title,
                        style: TextStyle(fontSize: 15),
                        softWrap: false,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 5),
                      Text(widget.data.card.providerName, style: TextStyle(fontSize: 13, color: MyColor.greyText))
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else if(widget.data.mediaAttachments != null && widget.data.mediaAttachments.length != 0) {
      return ArticleMedia(
        itemList: widget.data.mediaAttachments,
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Html(
        data: widget.data.content,
        onLinkTap: (url) {
          print('点击到的链接：' + url);
        },
      ),
      StatusItemMedia(widget.data),
      StatusItemPoll(widget.data.poll)
    ],);
  }


}
