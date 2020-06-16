import 'package:fastodon/api/search_api.dart';
import 'package:fastodon/models/article_item.dart';
import 'package:fastodon/models/owner_account.dart';
import 'package:fastodon/pages/timeline/hashtag_timeline.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/widget/listview/easyrefresh_listview.dart';
import 'package:fastodon/widget/status/status_item.dart';
import 'package:fastodon/widget/status/status_item_account.dart';
import 'package:flutter/material.dart';

class SearchResult extends StatefulWidget {
  final SearchType type;
  final String query;

  SearchResult(this.type, this.query);
  @override
  _SearchResultState createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> with AutomaticKeepAliveClientMixin<SearchResult>{
  Widget buildRow(int idx, List data) {
    switch (widget.type) {
      case SearchType.accounts:
        var account = OwnerAccount.fromJson(data[idx]);
        return Container(
            padding: EdgeInsets.fromLTRB(8, 0, 0, 8),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: Colors.grey[300]

                    )
                ),),
            child: StatusItemAccount(account));

      case SearchType.statuses:
        var status = StatusItemData.fromJson(data[idx]);
        return StatusItem(
          item: status,
        );

      case SearchType.hashtags:
        return InkWell(
          onTap: () => AppNavigate.push(context, HashtagTimeline(data[idx]['name'])),
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
                border: Border(
                    bottom:
                        BorderSide(color: Colors.grey[300]))),
            child: Text('#' + data[idx]['name'], style: TextStyle(fontSize: 16)),
          ),
        );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return EasyRefreshListView(
      requestUrl: SearchApi.getUrl(widget.type, widget.query),
      buildRow: buildRow,
      mapKey: widget.type.toString().split('.')[1],
      offsetPagination: true,
      emptyWidget: Center(child: Text('没找到结果')),

    );
  }

  @override
  bool get wantKeepAlive => true;
}
