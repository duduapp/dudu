import 'package:fastodon/api/search_api.dart';
import 'package:fastodon/models/article_item.dart';
import 'package:fastodon/models/owner_account.dart';
import 'package:fastodon/models/provider/result_list_provider.dart';
import 'package:fastodon/pages/timeline/hashtag_timeline.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/widget/common/list_row.dart';
import 'package:fastodon/widget/listview/easyrefresh_listview.dart';
import 'package:fastodon/widget/listview/provider_easyrefresh_listview.dart';
import 'package:fastodon/widget/status/status_item.dart';
import 'package:fastodon/widget/status/status_item_account.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchResult extends StatefulWidget {
  final SearchType type;
  final String query;

  SearchResult(this.type, this.query);
  @override
  _SearchResultState createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult>
    with AutomaticKeepAliveClientMixin<SearchResult> {
  Widget buildRow(int idx, List data, ResultListProvider provider) {
    switch (widget.type) {
      case SearchType.accounts:
        var account = OwnerAccount.fromJson(data[idx]);
        return ListRow(child: StatusItemAccount(account));

      case SearchType.statuses:
        var status = StatusItemData.fromJson(data[idx]);
        return StatusItem(
          item: status,
        );

      case SearchType.hashtags:
        return InkWell(
          onTap: () =>
              AppNavigate.push(context, HashtagTimeline(data[idx]['name'])),
          child: ListRow(child: Text('#' + data[idx]['name'], style: TextStyle(fontSize: 18)),padding: 18,),
        );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ChangeNotifierProvider<ResultListProvider>(
      create: (context) => ResultListProvider(
          requestUrl: SearchApi.getUrl(widget.type, widget.query),
          buildRow: buildRow,
          offsetPagination: true,
          mapKey: widget.type.toString().split('.')[1]),
      child: ProviderEasyRefreshListView(),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
