import 'package:fastodon/models/provider/result_list_provider.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/utils/view/list_view_util.dart';
import 'package:fastodon/widget/listview/provider_easyrefresh_listview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavouritesList extends StatefulWidget {
  @override
  _FavouritesListState createState() => _FavouritesListState();
}

class _FavouritesListState extends State<FavouritesList> {  
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('我的赞'),
        centerTitle: false,
      ),
      body: ChangeNotifierProvider<ResultListProvider>(
          create: (context) => ResultListProvider(
              requestUrl: Api.Favourites,
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