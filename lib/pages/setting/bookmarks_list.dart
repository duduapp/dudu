import 'package:fastodon/constant/api.dart';
import 'package:fastodon/models/article_item.dart';
import 'package:fastodon/models/provider/result_list_provider.dart';
import 'package:fastodon/utils/list_view.dart';
import 'package:fastodon/widget/listview/easyrefresh_listview.dart';
import 'package:fastodon/widget/listview/provider_easyrefresh_listview.dart';
import 'package:fastodon/widget/status/status_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookmarksList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('书签'),
          centerTitle: true,
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
