


import 'package:fastodon/api/lists_api.dart';
import 'package:fastodon/constant/api.dart';
import 'package:fastodon/models/article_item.dart';
import 'package:fastodon/widget/listview/easyrefresh_listview.dart';
import 'package:fastodon/widget/status/status_item.dart';
import 'package:flutter/material.dart';

class ListTimeline extends StatelessWidget {
  final String id;

  ListTimeline(this.id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('列表时间轴'),
        centerTitle: false,
      ),
      body: EasyRefreshListView(
        requestUrl: ListsApi.timelineUrl+'/'+id,
        buildRow: buildRow,
      ),
    );
  }

  Widget buildRow(int idx, List<dynamic> data) {
    var rowData = StatusItemData.fromJson(data[idx]);
    return StatusItem(item: rowData,);
  }
}
