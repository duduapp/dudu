import 'package:dudu/l10n/l10n.dart';
import 'package:dudu/api/timeline_api.dart';
import 'package:dudu/models/json_serializable/article_item.dart';
import 'package:dudu/models/provider/result_list_provider.dart';
import 'package:dudu/widget/common/custom_app_bar.dart';
import 'package:dudu/widget/listview/provider_easyrefresh_listview.dart';
import 'package:dudu/widget/status/status_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConversationTimeline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(S.of(context).private_letters),
      ),
      body: ChangeNotifierProvider<ResultListProvider>(
        create: (context) => ResultListProvider(
          tag: 'conversation',
          requestUrl: TimelineApi.conversations,
          buildRow: _buildRow,


        ),
        child: ProviderEasyRefreshListView(
        ),
      ),
    );
  }

  _buildRow(int index, List data, ResultListProvider provider) {
    StatusItemData lineItem = StatusItemData.fromJson(data[index]['last_status']);
    return StatusItem(item: lineItem);
  }
}
