import 'package:fastodon/models/article_item.dart';
import 'package:fastodon/models/provider/result_list_provider.dart';
import 'package:fastodon/pages/search/search_page_delegate.dart';
import 'package:fastodon/pages/status/new_status.dart';
import 'package:fastodon/utils/list_view.dart';
import 'package:fastodon/widget/listview/easyrefresh_listview.dart';
import 'package:fastodon/widget/listview/provider_easyrefresh_listview.dart';
import 'package:fastodon/widget/status/status_item.dart';
import 'package:fastodon/widget/listview/refresh_load_listview.dart';
import 'package:flutter/material.dart';
import 'package:fastodon/public.dart';
import 'package:nav_router/nav_router.dart';
import 'package:provider/provider.dart';

import '../../widget/other/search.dart' as customSearch;

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

  Function loginSuccess;
  @override
  void initState() {
    loginSuccess = (arg) {
      setState(() {
        _showTab = true;
      });
    };
    eventBus.on(
        EventBusKey.LoadLoginMegSuccess,loginSuccess
    );
    super.initState();

  }

  @override
  void dispose() {
    eventBus.off(EventBusKey.LoadLoginMegSuccess,loginSuccess);
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
          title: InkWell(
            child: Text(title),
            onTap: () => eventBus.emit(widget.type),
          ),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                customSearch.showSearch(
                    context: context, delegate: SearchPageDelegate());
              },
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                AppNavigate.push(context, NewStatus(),routeType: RouterType.material);
              },
            )
          ],
        ),
      ),
      body: LoadingWidget(
          childWidget: ChangeNotifierProvider<ResultListProvider>(
              create: (context) => ResultListProvider(
                requestUrl: url,
                buildRow: ListViewUtil.statusRowFunction(),
                listenBlockEvent: true,
                dataHandler: ListViewUtil.dataHandlerPrefixIdFunction(widget.type.toString().split('.')[1])
              ),
            builder: (context, snapshot) {
              return ProviderEasyRefreshListView(
                type: widget.type,
              );
            }
          ),
          endLoading: _showTab),
    );
  }


}
