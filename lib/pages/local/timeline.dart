import 'package:fastodon/models/article_item.dart';
import 'package:fastodon/widget/article_cell.dart';
import 'package:fastodon/widget/refresh_load_listview.dart';
import 'package:flutter/material.dart';
import 'package:fastodon/public.dart';

import 'local_timeline.dart';
import 'public_timeline.dart';

enum TimelineType {
  home,
  local,
  federated // 跨站
}

class Timeline extends StatefulWidget {
  final TimelineType type;

  Timeline(this.type);

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline>
    with AutomaticKeepAliveClientMixin {
  bool _local = true;
  bool _showTab = false;

  @override
  void initState() {
    super.initState();
    eventBus.on(EventBusKey.LoadLoginMegSuccess, (arg) {
      setState(() {
        _showTab = true;
      });
    });
  }

  @override
  void dispose() {
    eventBus.off(EventBusKey.LoadLoginMegSuccess);
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    var title;
    var url;
    switch (widget.type) {
      case TimelineType.home:
        title = '首页';
        url = Api.HomeTimeLine;
        break;
      case TimelineType.local:
        title = '本站';
        url = Api.LocalTimeLine;
        break;
      case TimelineType.federated:
        title = '跨站';
        url = Api.FederatedTimeLine;
        break;
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColor.mainColor,
        title: Text(title),
        centerTitle: true,
        actions: <Widget>[],
      ),
      body: LoadingWidget(
          childWidget: RefreshLoadListView(
            requestUrl: url,
            buildRow: row,
          ),
          endLoading: _showTab),
    );
  }

  Widget row(int index, List data) {
    ArticleItem lineItem = ArticleItem.fromJson(data[index]);
    return ArticleCell(item: lineItem);
  }
}
