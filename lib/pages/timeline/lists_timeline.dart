import 'package:fastodon/api/lists_api.dart';
import 'package:fastodon/models/json_serializable/article_item.dart';
import 'package:fastodon/models/provider/result_list_provider.dart';
import 'package:fastodon/utils/list_view.dart';
import 'package:fastodon/widget/listview/provider_easyrefresh_listview.dart';
import 'package:fastodon/widget/status/status_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        body: ChangeNotifierProvider<ResultListProvider>(
          create: (context) => ResultListProvider(
            requestUrl: ListsApi.timelineUrl + '/' + id,
            buildRow: ListViewUtil.statusRowFunction(),
          ),
          child: ProviderEasyRefreshListView(),
        ));
  }

  Widget buildRow(int idx, List<dynamic> data) {
    var rowData = StatusItemData.fromJson(data[idx]);
    return StatusItem(
      item: rowData,
    );
  }
}
