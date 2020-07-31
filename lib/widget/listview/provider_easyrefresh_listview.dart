// 下拉刷新和上拉加载
import 'package:fastodon/models/provider/result_list_provider.dart';
import 'package:fastodon/models/provider/settings_provider.dart';
import 'package:fastodon/pages/timeline/timeline.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/utils/list_view.dart';
import 'package:fastodon/widget/common/empty_view.dart';
import 'package:fastodon/widget/common/error_view.dart';
import 'package:fastodon/widget/common/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:provider/provider.dart';

class ProviderEasyRefreshListView extends StatefulWidget {
  ProviderEasyRefreshListView(
      {Key key,
      this.type,
      this.emptyWidget,
      this.controller,
      this.header,
      this.usingGrid = false,
      this.scrollController,
      this.cacheExtent,
      this.enableLoad = true,
      this.addToSliverCount = 0,
      this.afterBuild})
      : super(key: key);
  final TimelineType type;

  final Widget emptyWidget;
  final EasyRefreshController controller;
  final Header header;
  final usingGrid;
  final ScrollController scrollController;
  final double cacheExtent;
  final bool enableLoad;// 有时Provider 无法完全使list不load,在刷新后马上jump page 会使页面刷新
  final int addToSliverCount;
  final Function afterBuild;
  @override
  _ProviderEasyRefreshListViewState createState() =>
      _ProviderEasyRefreshListViewState();
}

enum ListStatus {
  // listview处于正常状态
  normal,
  // listview正在加载中
  loadingData,
  // listview已经没有更多的数据了
  noMoreData
}

class _ProviderEasyRefreshListViewState
    extends State<ProviderEasyRefreshListView>
    with AutomaticKeepAliveClientMixin {
  ScrollController _scrollController = ScrollController();

  EasyRefreshController _controller;
  int offset;
  bool noResults = false;
  bool finishLoad = false;
  bool finishRefresh = false;
  String nextUrl; // 用header link 时分页有用
  int textScale = 1;
  Function onTextScaleChanged;

  @override
  void initState() {
    super.initState();

    // _startRequest(widget.requestUrl,refresh: true);
    _controller = widget.controller ?? EasyRefreshController();

    Storage.getInt("mastodon.text_scale").then((value) {
      if (value != null && value != textScale) {
        if (mounted)
          setState(() {
            textScale = value;
          });
      }
    });

    eventBus.on(widget.type, (arg) {
      _scrollController.jumpTo(0);
    });

    onTextScaleChanged = (arg) {
      setState(() {
        textScale = arg;
      });
    };
    eventBus.on(EventBusKey.textScaleChanged, onTextScaleChanged);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Selector<SettingsProvider, String>(
      selector: (_, m) => m.get('text_scale'),
      shouldRebuild: (preCount, nextCount) => preCount != nextCount,
      builder: (context, scale, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaleFactor: 1.0 + 0.18 * double.parse(scale)),
          child:
              Consumer<ResultListProvider>(builder: (context, provider, child) {
                if (widget.afterBuild != null) {
                  WidgetsBinding.instance.addPostFrameCallback(widget.afterBuild);
                }
            GlobalKey<SliverAnimatedListState> listKey =
                GlobalKey<SliverAnimatedListState>();
            provider.setAnimatedListKey(listKey);
            if (provider.error != null) {
              return ErrorView(
                error: provider.error,
                onClickRetry: () async{
                  await provider.refresh(showLoading: true);
                }
              );
            }
            // 初次可能从Provider 里面请求
            return provider.isLoading
                ? LoadingView()
                : EasyRefresh.custom(

                    topBouncing: false,
                    slivers: [
                      !widget.usingGrid
                          ? SliverAnimatedList(

                              key: listKey,
                              initialItemCount: provider.list.length+widget.addToSliverCount,
                              itemBuilder: (context, index, animation) {
                                return SizeTransition(
                                  axis: Axis.vertical,
                                  sizeFactor: animation,
                                  child: provider.buildRow(
                                      index, provider.list, provider),
                                );
                              },
                            )
                          : SliverGrid(
                              delegate:
                                  SliverChildBuilderDelegate((context, idx) {
                                return provider.buildRow(
                                    idx, provider.list, provider);
                              }, childCount: provider.list.length+widget.addToSliverCount),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3),
                            )
                    ],
                    firstRefresh: false, //在NestedScrollView 不用启用这个选项，而且不能设置scroll controller
                    firstRefreshWidget: LoadingView(),
                    header:
                        widget.header ?? ListViewUtil.getDefaultHeader(context),
                    footer: ListViewUtil.getDefaultFooter(context),
                    controller: _controller,

                    scrollController:widget.scrollController,
//                        widget.type == null ? null : _scrollController,
                    onRefresh: provider.finishRefresh ? null : provider.refresh,
                    onLoad: widget.enableLoad ?(provider.finishLoad ? null : provider.load ):null,
                    emptyWidget: provider.noResults && widget.addToSliverCount == 0
                        ? widget.emptyWidget ?? EmptyView()
                        : null,
                    cacheExtent: widget.cacheExtent,
                  );
          }),
        );
      },
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

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
