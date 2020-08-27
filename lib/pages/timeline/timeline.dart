import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/models/local_account.dart';
import 'package:dudu/models/provider/result_list_provider.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/pages/login/login.dart';
import 'package:dudu/pages/search/search_page_delegate.dart';
import 'package:dudu/pages/status/new_status.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/view/list_view_util.dart';
import 'package:dudu/widget/listview/provider_easyrefresh_listview.dart';
import 'package:dudu/widget/setting/account_row_top.dart';
import 'package:dudu/widget/timeline/account_switch_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:gzx_dropdown_menu/gzx_dropdown_menu.dart';
import 'package:nav_router/nav_router.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
  GlobalKey _stackKey = GlobalKey();
  GZXDropdownMenuController _menuController = GZXDropdownMenuController();
  ResultListProvider provider;


  @override
  void initState() {
    super.initState();

    var url;
    switch (widget.type) {
      case TimelineType.home:
        url = Api.HomeTimeLine;
        break;
      case TimelineType.local:
        url = Api.LocalTimeLine;
        break;
      case TimelineType.federated:

        url = Api.FederatedTimeLine;
        break;
    }
    provider = ResultListProvider(
        requestUrl: url,
        tag: widget.type.toString().split('.').last,
        buildRow: ListViewUtil.statusRowFunction(),
        listenBlockEvent: false,
        dataHandler: ListViewUtil.dataHandlerPrefixIdFunction(
            widget.type.toString().split('.')[1]));
    switch (widget.type) {
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
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    refreshController.dispose();
    _menuController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var title;
    switch (widget.type) {
      case TimelineType.home:
        title = '首页';
        break;
      case TimelineType.local:
        title = '本站';
        break;
      case TimelineType.federated:
        title = '跨站';
        break;
    }
    return AccountSwitchTimeline(
      provider:  provider,
      listView: ProviderEasyRefreshListView(
        type: widget.type,
        scrollController: _scrollController,
        easyRefreshController: refreshController,
      ),
      title: title,
      actions: [
        IconButton(icon: Icon(IconFont.search),onPressed: () {
                          customSearch.showSearch(
                    context: context, delegate: SearchPageDelegate());
        },),
        IconButton(icon: Icon(IconFont.addCircle),onPressed: () => AppNavigate.push(NewStatus(), routeType: RouterType.material),)
      ],
    );

  }
}
