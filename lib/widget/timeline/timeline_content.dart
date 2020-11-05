import 'package:dudu/models/provider/result_list_provider.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/utils/view/list_view_util.dart';
import 'package:dudu/widget/listview/provider_easyrefresh_listview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TimelineContent extends StatefulWidget {
  final String url;
  final String tag;
  final RowBuilder rowBuilder;
  final bool prefixId; // solve hero problem

  TimelineContent({this.url, this.tag,this.rowBuilder,this.prefixId = true});
  @override
  _TimelineContentState createState() => _TimelineContentState();
}

class _TimelineContentState extends State<TimelineContent> {
  ScrollController _scrollController = ScrollController();
  RefreshController _refreshController = RefreshController();
  ResultListProvider provider;

  @override
  void initState() {
    bool sameInstance = !widget.url.startsWith('https://');
    provider = ResultListProvider(
        firstRefresh: sameInstance ?false :true,
        requestUrl: widget.url,
        tag: widget.tag,
        buildRow: widget.rowBuilder ?? ListViewUtil.statusRowFunction(),
        listenBlockEvent: false,
        dataHandler:
             widget.prefixId ? ListViewUtil.dataHandlerPrefixIdFunction(widget.tag + "##"): null) ;
    if (sameInstance) {
      switch (widget.tag) {
        case 'home':
          SettingsProvider().homeProvider = provider;
          break;
        case 'local':
          SettingsProvider().localProvider = provider;
          break;
        case 'federated':
          SettingsProvider().federatedProvider = provider;
          break;
      }
      provider.refreshController = _refreshController;
      provider.scrollController = _scrollController;
      provider.loadCacheDataOrRefresh();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.checkCachePosition();
      });
    }



    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _refreshController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ResultListProvider>.value(
        value: provider,
        builder: (context, snapshot) {
          return ProviderEasyRefreshListView(
            scrollController: _scrollController,
            refreshController: _refreshController,
          );
        });
  }
}
