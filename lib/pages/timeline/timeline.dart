import 'package:fastodon/models/article_item.dart';
import 'package:fastodon/pages/home/new_article.dart';
import 'package:fastodon/widget/easyrefresh_listview.dart';
import 'package:fastodon/widget/status/status_item.dart';
import 'package:fastodon/widget/refresh_load_listview.dart';
import 'package:flutter/material.dart';
import 'package:fastodon/public.dart';



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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40.0),
        child: AppBar(
          title: InkWell(child: Text(title),onTap: () => eventBus.emit(widget.type),),
          centerTitle: true,
          actions: <Widget>[
            IconButton(icon: Icon(Icons.search),onPressed: (){},),
            IconButton(icon: Icon(Icons.add),onPressed: (){AppNavigate.push(context, NewArticle());},)
          ],
        ),
      ),
      body: Container(
        color: Theme.of(context).backgroundColor,
        child: LoadingWidget(
            childWidget: EasyRefreshListView(
              requestUrl: url,
              buildRow: row,
              type: widget.type,
            ),
            endLoading: _showTab),
      ),
    );
  }

  Widget row(int index, List data) {
    StatusItemData lineItem = StatusItemData.fromJson(data[index]);
    return StatusItem(item: lineItem);
  }
}
