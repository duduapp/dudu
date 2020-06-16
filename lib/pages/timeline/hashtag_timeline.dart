


import 'package:fastodon/constant/api.dart';
import 'package:fastodon/models/article_item.dart';
import 'package:fastodon/widget/listview/easyrefresh_listview.dart';
import 'package:fastodon/widget/status/status_item.dart';
import 'package:flutter/material.dart';

class HashtagTimeline extends StatelessWidget {
  final String hashtag;

  HashtagTimeline(this.hashtag);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('#'+hashtag),
        centerTitle: false,
      ),
      body: EasyRefreshListView(
        requestUrl: Api.hashtagTimeline+'/'+hashtag,
        buildRow: buildRow,
      ),
    );
  }

  Widget buildRow(int idx, List<dynamic> data) {
    var rowData = StatusItemData.fromJson(data[idx]);
    return StatusItem(item: rowData,);
  }
}
