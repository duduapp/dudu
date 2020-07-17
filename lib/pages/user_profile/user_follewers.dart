import 'package:fastodon/api/accounts_api.dart';
import 'package:fastodon/models/provider/result_list_provider.dart';
import 'package:fastodon/utils/list_view.dart';
import 'package:fastodon/widget/listview/provider_easyrefresh_listview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserFollowers extends StatelessWidget {
  final String id;

  UserFollowers(this.id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('粉丝'),
        centerTitle: false,
      ),
      body: ChangeNotifierProvider<ResultListProvider>(
        create: (context) => ResultListProvider(
          requestUrl: '${AccountsApi.url}/$id/followers',
          buildRow: ListViewUtil.accountRowFunction(),
          headerLinkPagination: true
        ),
        child: ProviderEasyRefreshListView(),
      ),
    );
  }
}