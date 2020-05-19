import 'package:flutter/material.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/widget/refresh_load_listview.dart';
import 'package:fastodon/widget/status/status_item.dart';
import 'package:fastodon/models/article_item.dart';

class PublicTimeline extends StatefulWidget {
  @override
  _PublicTimelineState createState() => _PublicTimelineState();
}

class _PublicTimelineState extends State<PublicTimeline> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Widget row(int index, List data) {
    ArticleItem lineItem = ArticleItem.fromJson(data[index]);
    return StatusItem(item: lineItem);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshLoadListView(
      requestUrl: Api.FederatedTimeLine,
      buildRow: row,
    );
  }
}