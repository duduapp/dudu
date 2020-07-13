// 下拉刷新和上拉加载
import 'package:fastodon/models/provider/result_list_provider.dart';
import 'package:fastodon/pages/timeline/timeline.dart';
import 'package:fastodon/utils/list_view.dart';
import 'package:fastodon/widget/common/empty_view.dart';
import 'package:fastodon/widget/common/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fastodon/public.dart';
import 'package:provider/provider.dart';

class ProviderEasyRefreshNestedListView extends StatefulWidget {
  ProviderEasyRefreshNestedListView({
    Key key,
    this.type,
    this.emptyWidget,
    this.controller,
    this.header,
  }) : super(key: key);
  final TimelineType type;

  final Widget emptyWidget;
  final EasyRefreshController controller;
  final Header header;

  @override
  _ProviderEasyRefreshNestedListViewState createState() =>
      _ProviderEasyRefreshNestedListViewState();
}

enum ListStatus {
  // listview处于正常状态
  normal,
  // listview正在加载中
  loadingData,
  // listview已经没有更多的数据了
  noMoreData
}

class _ProviderEasyRefreshNestedListViewState
    extends State<ProviderEasyRefreshNestedListView> {
  ScrollController _scrollController = ScrollController();

  EasyRefreshController _controller;
  int offset;
  bool noResults = false;
  bool finishLoad = false;
  bool finishRefresh = false;
  String nextUrl; // 用header link 时分页有用
  int textScale = 1;
  Function onTextScaleChanged;

  final GlobalKey<SliverAnimatedListState> listKey =
      GlobalKey<SliverAnimatedListState>();

  @override
  void initState() {
    super.initState();

    // _startRequest(widget.requestUrl,refresh: true);
    _controller = widget.controller ?? EasyRefreshController();

    Storage.getInt("mastodon.text_scale").then((value) {
      if (value != null && value != textScale) {
        setState(() {
          textScale = value;
        });
      }
    });

    eventBus.on(widget.type, (arg) {
      _scrollController.jumpTo(0);
    });

    eventBus.on(EventBusKey.muteAccount, (arg) {
      _removeByAccountId(arg['account_id']);
    });

    eventBus.on(EventBusKey.blockAccount, (arg) {
      _removeByAccountId(arg['account_id']);
    });

    onTextScaleChanged = (arg) {
      setState(() {
        textScale = arg;
      });
    };
    eventBus.on(EventBusKey.textScaleChanged, onTextScaleChanged);
  }

  _removeByAccountId(String accountId) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaleFactor: 1.0 + 0.18 * textScale),
      child: Consumer<ResultListProvider>(builder: (context, provider, child) {
        GlobalKey<SliverAnimatedListState> listKey =
            GlobalKey<SliverAnimatedListState>();
        provider.setAnimatedListKey(listKey);
        return EasyRefresh(
          child: ListView.builder(
            itemBuilder: (context, idx) {
              return provider.buildRow(idx, provider.list, provider);
            },
            itemCount: provider.list.length,
          ),
 //         firstRefresh: true,
//          firstRefreshWidget: LoadingView(),
//          header: widget.header ?? ListViewUtil.getDefaultHeader(context),
//          footer: ListViewUtil.getDefaultFooter(context),
          controller: _controller,
          scrollController: _scrollController,
          onRefresh: provider.finishRefresh ? null : provider.refresh,
          onLoad: provider.finishLoad ? null : provider.load,
//          emptyWidget: provider.noResults ? widget.emptyWidget ?? EmptyView() : null,
        );
      }),
    );
  }

  @override
  void dispose() {
    eventBus.off(widget.type);
    eventBus.off(EventBusKey.muteAccount);
    eventBus.off(EventBusKey.blockAccount);

    eventBus.off(EventBusKey.textScaleChanged, onTextScaleChanged);
    super.dispose();
  }
}
