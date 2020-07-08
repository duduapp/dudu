import 'package:fastodon/constant/api.dart';
import 'package:fastodon/models/article_item.dart';
import 'package:fastodon/widget/listview/easyrefresh_listview.dart';
import 'package:fastodon/widget/status/status_item.dart';
import 'package:flutter/material.dart';

class BookmarksList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('书签'),
          centerTitle: true,
        ),
        body: Container(
          color: Theme.of(context).backgroundColor,
          child: EasyRefreshListView(
            requestUrl: Api.bookmarks,
            buildRow: row,
          ),
        )
    );
  }

  Widget row(int index, List data) {
    StatusItemData lineItem = StatusItemData.fromJson(data[index]);
    return StatusItem(item: lineItem);
  }

}
