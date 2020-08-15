import 'package:dudu/api/accounts_api.dart';
import 'package:dudu/models/provider/result_list_provider.dart';
import 'package:dudu/utils/view/list_view_util.dart';
import 'package:dudu/widget/listview/provider_easyrefresh_listview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserStatus extends StatelessWidget {
  final String id;

  UserStatus(this.id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('嘟文'),
        centerTitle: false,
      ),
      body: ChangeNotifierProvider<ResultListProvider>(
        create: (context) => ResultListProvider(
          requestUrl: '${AccountsApi.url}/$id/statuses',
          buildRow: ListViewUtil.statusRowFunction(),
          headerLinkPagination: true
        ),
        child: ProviderEasyRefreshListView(),
      ),
    );
  }
}
