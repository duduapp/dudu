import 'package:dudu/models/json_serializable/article_item.dart';
import 'package:dudu/widget/status/status_item_card.dart';
import 'package:dudu/widget/status/status_item_media.dart';
import 'package:dudu/widget/status/status_item_poll.dart';
import 'package:dudu/widget/status/status_item_text.dart';
import 'package:flutter/material.dart';


class StatusItemContent extends StatelessWidget {
  final StatusItemData data;
  final bool primary;
  final bool subStatus;

  StatusItemContent(this.data,{this.primary = false,this.subStatus = false});
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      StatusItemText(data,navigateToDetail: !primary,),
      StatusItemMedia(data),
      if (data.poll != null)
      StatusItemPoll(data),
      StatusItemCard(data),
    ],);
  }
}
