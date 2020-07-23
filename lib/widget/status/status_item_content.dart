import 'package:fastodon/models/json_serializable/article_item.dart';
import 'package:fastodon/widget/status/status_item_media.dart';
import 'package:fastodon/widget/status/status_item_poll.dart';
import 'package:fastodon/widget/status/status_item_text.dart';
import 'package:flutter/material.dart';


class StatusItemContent extends StatelessWidget {
  final StatusItemData data;
  final bool primary;

  StatusItemContent(this.data,{this.primary = false});
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      StatusItemText(data,navigateToDetail: !primary,),
      StatusItemMedia(data),
      StatusItemPoll(data.poll)
    ],);
  }
}
