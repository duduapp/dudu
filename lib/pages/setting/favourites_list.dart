import 'package:dudu/l10n/l10n.dart';
import 'package:dudu/models/provider/result_list_provider.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/i18n_util.dart';
import 'package:dudu/utils/view/list_view_util.dart';
import 'package:dudu/widget/common/custom_app_bar.dart';
import 'package:dudu/widget/listview/provider_easyrefresh_listview.dart';
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
    var isZh = I18nUtil.isZh(context);
    var title = isZh ? StringUtil.getZanString() : S.of(context).favorites;
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(title),
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