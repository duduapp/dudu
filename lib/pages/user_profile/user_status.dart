import 'package:dudu/l10n/l10n.dart';
import 'package:dudu/api/accounts_api.dart';
import 'package:dudu/models/provider/result_list_provider.dart';
import 'package:dudu/utils/view/list_view_util.dart';
import 'package:dudu/widget/common/custom_app_bar.dart';
import 'package:dudu/widget/listview/provider_easyrefresh_listview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserStatus extends StatelessWidget {
  final String id;

  UserStatus(this.id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(S.of(context).toot),
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
