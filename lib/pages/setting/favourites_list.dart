import 'package:fastodon/widget/listview/easyrefresh_listview.dart';
import 'package:flutter/material.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/widget/listview/refresh_load_listview.dart';
import 'package:fastodon/widget/status/status_item.dart';
import 'package:fastodon/models/article_item.dart';

class FavoutitesList extends StatefulWidget {
  @override
  _FavoutitesListState createState() => _FavoutitesListState();
}

class _FavoutitesListState extends State<FavoutitesList> {  
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget row(int index, List data) {
    StatusItemData lineItem = StatusItemData.fromJson(data[index]);
    return StatusItem(item: lineItem);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('我的收藏'),
        centerTitle: true,
      ),
      body: EasyRefreshListView(
        requestUrl: Api.Favourites,
        buildRow: row,
        headerLinkPagination: true,
      )
    );
  }
}