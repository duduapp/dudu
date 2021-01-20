import 'package:dudu/l10n/l10n.dart';
// 下拉刷新和上拉加载
import 'package:dudu/models/provider/result_list_provider.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/pages/timeline/timeline.dart';
import 'package:dudu/public.dart';
import 'package:dudu/widget/common/empty_view.dart';
import 'package:dudu/widget/common/error_view.dart';
import 'package:dudu/widget/common/loading_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// animatedlist 无法保存位置
/// customscrollview + sliveranimatedlist 性能有问题
/// 所以性能相关的地方用listview,其它地方可以用animatedlist
class ProviderEasyRefreshListView extends StatefulWidget {
  ProviderEasyRefreshListView(
      {Key key,
      this.type,
      this.emptyWidget,
      this.usingGrid = false,
      this.gridDelegate,
      this.scrollController,
      this.cacheExtent,
      this.enableLoad = true,
      this.addToSliverCount = 0,
      this.afterBuild,
      this.firstRefresh = false,
      this.useAnimatedList = false,
      this.showLoading = true,
      this.emptyView,
      this.loadingView})
      : super(key: key);
  final TimelineType type;

  final Widget emptyWidget;
  final usingGrid;
  final ScrollController scrollController;
  final double cacheExtent;
  final bool enableLoad; // 有时Provider 无法完全使list不load,在刷新后马上jump page 会使页面刷新
  final int addToSliverCount;
  final Function afterBuild;
  final bool useAnimatedList;
  final bool firstRefresh;
  final bool showLoading;
  final Widget emptyView;
  final Widget loadingView;
  final SliverGridDelegate gridDelegate;
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

  int offset;
  bool noResults = false;
  bool finishLoad = false;
  bool finishRefresh = false;
  bool firstRefreshed = false;
  String nextUrl; // 用header link 时分页有用
  int textScale = 1;
  Function onTextScaleChanged;
  int requestLoadSize = 0;

  RefreshController _refreshController;

  @override
  void initState() {
    super.initState();

    setState(() {
      textScale = Storage.getInt("mastodon.text_scale");
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

            GlobalKey<SliverAnimatedListState> listKey;
            if (widget.useAnimatedList) {
              listKey = GlobalKey<SliverAnimatedListState>();
              provider.setAnimatedListKey(listKey);
            }
            if (provider.error != null) {
              return ErrorView(
                  error: provider.error,
                  onClickRetry: () async {
                    await provider.refresh(showLoading: true);
                  });
            }

            if (provider.finishLoad) {
              _refreshController.loadNoData();
            }

            if (!firstRefreshed && widget.firstRefresh) {
              firstRefreshed = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                provider.refresh(showLoading: true);
              });
            }

            // 初次可能从Provider 里面请求
            return (provider.isLoading && widget.showLoading)
                ? widget.loadingView ?? LoadingView()
                : NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification notification) {
                      double progress = notification.metrics.maxScrollExtent -
                          notification.metrics.pixels;
                      if (progress < 2000 && provider.enableLoad) {
                        requestLoadSize = provider.list.length;
                        provider.load();

                        //
                      }
                    },
                    child: Scrollbar(
                      child: SmartRefresher(
                        physics: ClampingScrollPhysics(),
                        primary: widget.scrollController == null ? true : false,
                        controller: provider.refreshController,
                        header: ClassicHeader(
                          releaseText: S.of(context).release_refresh,
                          refreshingText: S.of(context).loading,
                          completeText: S.of(context).complete_refresh,
                          idleText: S.of(context).pull_down_to_refresh,
                          releaseIcon: Icon(
                            Icons.arrow_upward,
                            color: Colors.grey,
                          ),
                          refreshingIcon: CupertinoActivityIndicator(),
                          textStyle: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).accentColor),
                        ),
                        footer: ClassicFooter(
                          loadingText: S.of(context).loading,
                          loadingIcon: null,
                          idleText: S.of(context).loading,
                          idleIcon: null, // 自动加载，所以显示这个
                          canLoadingText: S.of(context).release_load_more,
                          noDataText: '',
                        ),
                        enablePullDown: provider.enableRefresh
                            ? (provider.finishRefresh
                                ? false
                                : (provider.isLoading && !widget.showLoading)
                                    ? false
                                    : true)
                            : false,
                        enablePullUp: provider.enableLoad
                            ? (provider.finishLoad ? false : true)
                            : false,
                        scrollController: widget.scrollController,
                        cacheExtent: widget.cacheExtent ?? null,
                        onRefresh: () async {
                          await provider.refresh();
                          provider.refreshController.refreshCompleted();
                        },
                        onLoading: () async {
                          await provider.load();
                          provider.refreshController.loadComplete();
                        },
                        child: provider.noResults
                            ? (widget.emptyView ?? EmptyView())
                            : widget.useAnimatedList
                                ? CustomScrollView(
                                    slivers: [
                                      SliverAnimatedList(
                                        key: listKey,
                                        initialItemCount: provider.list.length +
                                            widget.addToSliverCount,
                                        itemBuilder:
                                            (context, index, animation) {
                                          return SizeTransition(
                                            axis: Axis.vertical,
                                            sizeFactor: animation,
                                            child: provider.buildRow(
                                                index, provider.list, provider),
                                          );
                                        },
                                      )
                                    ],
                                  )
                                : widget.usingGrid
                                    ? GridView.builder(
                                        itemBuilder: (context, idx) {
                                          return provider.buildRow(
                                              idx, provider.list, provider);
                                        },
                                        itemCount: provider.list.length +
                                            widget.addToSliverCount,
                                        gridDelegate: widget.gridDelegate)
                                    : ListView.builder(
                                        //      key: listKey,
                                        itemCount: provider.list.length +
                                            widget.addToSliverCount,
                                        itemBuilder: (context, index) {
                                          return provider.buildRow(
                                              index, provider.list, provider);
                                        },
                                      ),
                      ),
                    ));
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
  bool get wantKeepAlive => true;
}
