import 'package:dudu/constant/api.dart';
import 'package:dudu/models/provider/result_list_provider.dart';
import 'package:dudu/utils/view/list_view_util.dart';
import 'package:dudu/widget/common/custom_app_bar.dart';
import 'package:dudu/widget/listview/provider_easyrefresh_listview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookmarksList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
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
