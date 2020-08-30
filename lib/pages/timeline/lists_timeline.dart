import 'package:dudu/api/lists_api.dart';
import 'package:dudu/models/json_serializable/article_item.dart';
import 'package:dudu/models/provider/result_list_provider.dart';
import 'package:dudu/utils/view/list_view_util.dart';
import 'package:dudu/widget/common/custom_app_bar.dart';
import 'package:dudu/widget/listview/provider_easyrefresh_listview.dart';
import 'package:dudu/widget/status/status_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListTimeline extends StatelessWidget {
  final String id;

  ListTimeline(this.id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          title: Text('列表时间轴'),
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
