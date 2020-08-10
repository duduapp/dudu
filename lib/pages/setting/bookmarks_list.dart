import 'package:fastodon/constant/api.dart';
import 'package:fastodon/models/provider/result_list_provider.dart';
import 'package:fastodon/utils/view/list_view_util.dart';
import 'package:fastodon/widget/listview/provider_easyrefresh_listview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookmarksList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('书签'),
          centerTitle: false,
        ),
        body: ChangeNotifierProvider<ResultListProvider>(
            create: (context) => ResultListProvider(
                requestUrl: Api.bookmarks,
                buildRow: ListViewUtil.statusRowFunction(),
                headerLinkPagination: true),
            builder: (context, snapshot) {
              return ProviderEasyRefreshListView(
              );
            }
        )
    );
  }



}
