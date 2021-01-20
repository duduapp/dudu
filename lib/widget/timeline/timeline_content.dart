import 'package:dudu/models/provider/result_list_provider.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/utils/view/list_view_util.dart';
import 'package:dudu/widget/listview/provider_easyrefresh_listview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TimelineContent extends StatefulWidget {
  final String url;
  final String tag;
  final RowBuilder rowBuilder;
  final bool prefixId; // solve hero problem
  final ResultListProvider provider;

  TimelineContent(
      {this.url,
      this.tag,
      this.rowBuilder,
      this.prefixId = true,
      this.provider});
  @override
  _TimelineContentState createState() => _TimelineContentState();
}

class _TimelineContentState extends State<TimelineContent> {
  ScrollController _scrollController;
  ResultListProvider provider;

  @override
  void initState() {
    getProvider();
    super.initState();
  }

  getProvider() async {
    bool sameInstance = !widget.url.startsWith('https://');
    provider = widget.provider ??
        ResultListProvider(
            firstRefresh: sameInstance ? false : true,
            requestUrl: widget.url,
            tag: widget.tag,
            buildRow: widget.rowBuilder ?? ListViewUtil.statusRowFunction(),
            listenBlockEvent: false,
            dataHandler: widget.prefixId
                ? ListViewUtil.dataHandlerPrefixIdFunction(widget.tag + "##")
                : null);
    if (sameInstance) {
      switch (widget.tag) {
        case 'home':
          SettingsProvider().setHomeProvider(provider);
          break;
        case 'local':
          SettingsProvider().setLocalProvider(provider);
          break;
        case 'federated':
          SettingsProvider().setFederatedProvider(provider);
          break;
        case 'notifications':
          SettingsProvider().setNotificationProvider(provider);
      }

      _scrollController = ScrollController(
          initialScrollOffset: await provider.getCachePosition());
      provider.scrollController = _scrollController;
      await provider.loadCacheDataOrRefresh();
    } else {
      _scrollController = ScrollController();
      provider.scrollController = _scrollController;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return provider == null
        ? Container()
        : ChangeNotifierProvider<ResultListProvider>.value(
            value: provider,
            builder: (context, snap) {
              return ProviderEasyRefreshListView(
                scrollController: _scrollController,
              );
            });
  }
}
