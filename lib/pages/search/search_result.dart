import 'package:dudu/api/search_api.dart';
import 'package:dudu/models/json_serializable/article_item.dart';
import 'package:dudu/models/json_serializable/owner_account.dart';
import 'package:dudu/models/provider/result_list_provider.dart';
import 'package:dudu/pages/timeline/hashtag_timeline.dart';
import 'package:dudu/public.dart';
import 'package:dudu/widget/common/list_row.dart';
import 'package:dudu/widget/listview/provider_easyrefresh_listview.dart';
import 'package:dudu/widget/status/status_item.dart';
import 'package:dudu/widget/status/status_item_account.dart';
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
        return ListRow(
          child: StatusItemAccount(account),
          padding: 0,
        );

      case SearchType.statuses:
        var status = StatusItemData.fromJson(data[idx]);
        return StatusItem(
          item: status,
        );

      case SearchType.hashtags:
        return ListRow(
          padding: 0,
          child: InkWell(
            onTap: () => AppNavigate.push(HashtagTimeline(data[idx]['name'])),
            child: Padding(
              padding: const EdgeInsets.all(12.5),
              child:
                  Text('#' + data[idx]['name'], style: TextStyle(fontSize: 14)),
            ),
          ),
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
