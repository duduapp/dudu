import 'package:flutter/material.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/widget/refresh_load_listview.dart';
import 'package:fastodon/widget/status/status_item.dart';
import 'package:fastodon/models/article_item.dart';

class LocalTimeline extends StatefulWidget {
  @override
  _LocalTimelineState createState() => _LocalTimelineState();
}

class _LocalTimelineState extends State<LocalTimeline> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Widget row(int index, List data) {
    StatusItemData lineItem = StatusItemData.fromJson(data[index]);
    return StatusItem(item: lineItem);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshLoadListView(
      requestUrl: Api.LocalTimeLine,
      buildRow: row,
    );
  }
}