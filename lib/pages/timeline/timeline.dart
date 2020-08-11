import 'package:fastodon/constant/icon_font.dart';
import 'package:fastodon/models/provider/result_list_provider.dart';
import 'package:fastodon/models/provider/settings_provider.dart';
import 'package:fastodon/pages/search/search_page_delegate.dart';
import 'package:fastodon/pages/status/new_status.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/utils/view/list_view_util.dart';
import 'package:fastodon/widget/listview/provider_easyrefresh_listview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
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

class _TimelineState extends State<Timeline> {
  ScrollController _scrollController = ScrollController();
  EasyRefreshController refreshController = EasyRefreshController();

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
            onTap: () => _scrollController.jumpTo(0),
          ),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              splashColor: Colors.transparent,
              icon: Icon(IconFont.search,size: 25,),
              onPressed: () {
                customSearch.showSearch(
                    context: context, delegate: SearchPageDelegate());
              },
            ),
            IconButton(
              splashColor: Colors.transparent,
              icon: Icon(Icons.add_circle,color: Theme.of(context).buttonColor,),
              onPressed: () {
                AppNavigate.push(NewStatus(), routeType: RouterType.material);
              },
            )
          ],
        ),
      ),
      body: ChangeNotifierProvider<ResultListProvider>(create: (context) {
        var provider = ResultListProvider(
            requestUrl: url,
            tag: widget.type.toString().split('.').last,
            buildRow: ListViewUtil.statusRowFunction(),
            listenBlockEvent: true,
            dataHandler: ListViewUtil.dataHandlerPrefixIdFunction(
                widget.type.toString().split('.')[1]));
        switch(widget.type) {
          case TimelineType.home:
            SettingsProvider().homeProvider = provider;
            break;
          case TimelineType.local:
            SettingsProvider().localProvider = provider;
            break;
          case TimelineType.federated:
            SettingsProvider().federatedProvider = provider;
            break; 
        }
        provider.refreshController = refreshController;
        return provider;
      }, builder: (context, snapshot) {
        return ProviderEasyRefreshListView(
          type: widget.type,
          scrollController: _scrollController,
          controller: refreshController,
        );
      }),
    );
  }
}
