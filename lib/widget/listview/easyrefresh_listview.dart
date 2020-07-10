// 下拉刷新和上拉加载
import 'package:fastodon/pages/timeline/timeline.dart';
import 'package:fastodon/utils/list_view.dart';
import 'package:fastodon/widget/common/empty_view.dart';
import 'package:fastodon/widget/common/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fastodon/public.dart';

class EasyRefreshListView extends StatefulWidget {
  EasyRefreshListView({
    Key key,
    @required this.requestUrl,
    @required this.buildRow,
    this.type,
    this.mapKey,
    this.offsetPagination,
    this.emptyWidget,
    this.headerLinkPagination = false,
    this.controller,
    this.header,
    this.triggerRefreshEvent = const [],
    this.enableRefresh = true,
    this.reverseData = false
  }) : super(key: key);
  final String requestUrl;
  final Function buildRow;
  final TimelineType type;
  final String mapKey; // 返回的结果是map,而且key 是 mapKey
  final bool offsetPagination; //search 里面的max id和 min id 不能用
  final bool headerLinkPagination; // 用返回的Header link来分分页
  final Widget emptyWidget;
  final EasyRefreshController controller;
  final Header header;
  final List<String> triggerRefreshEvent;
  final bool enableRefresh;// 不影响第一次刷新，请求成功后不会再刷新
  final bool reverseData; // 必须和enableRefresh 一起使用

  @override
  _EasyRefreshListViewState createState() => _EasyRefreshListViewState();
}

enum ListStatus {
  // listview处于正常状态
  normal,
  // listview正在加载中
  loadingData,
  // listview已经没有更多的数据了
  noMoreData
}

class _EasyRefreshListViewState extends State<EasyRefreshListView> {
  ScrollController _scrollController = ScrollController();
  List _dataList = [];
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

    Storage.getInt("mastodon.text_scale").then((value){
      if (value != null && value != textScale) {
        setState(() {
          textScale = value;
        });
      }
    });

    eventBus.on(widget.type, (arg) {
        _scrollController.jumpTo(0);
    });

    eventBus.on(EventBusKey.muteAccount,(arg){
      _removeByAccountId(arg['account_id']);

    });
    
    eventBus.on(EventBusKey.blockAccount,(arg) {
      _removeByAccountId(arg['account_id']);
    });

    onTextScaleChanged = (arg) {setState(() {
      textScale = arg;
    }); };
    eventBus.on(EventBusKey.textScaleChanged, onTextScaleChanged);


    for (var event in widget.triggerRefreshEvent) {
      eventBus.on(event, (arg) {
        _onRefresh();
      });
    }
  }
  
  _removeByAccountId(String accountId) {
    setState(() {
      _dataList.removeWhere((element) => element['account']['id'] == accountId);
    });
  }

  Future<void> _onLoad() async{
    if (widget.headerLinkPagination != null && widget.headerLinkPagination == true) {
      if (nextUrl != null) {
        _startRequest(nextUrl);
        nextUrl = null;
      }
    } else {
      String lastCellId = _dataList[_dataList.length - 1]['id'];
      String appendOffset = "";
      if (widget.offsetPagination != null && widget.offsetPagination == true) {
        appendOffset = "&offset=${_dataList.length}";
      }
      // get请求中是否已经包含了其他的参数
      var since = "max_id";
      if (widget.requestUrl.contains('?')) {
        await _startRequest(
            widget.requestUrl + '&max_id=$lastCellId$appendOffset');
      } else {
        await _startRequest(
            widget.requestUrl + '?max_id=$lastCellId$appendOffset');
      }
    }
  }

  Future<void> _onRefresh() async{
    await _startRequest(widget.requestUrl,refresh: true);
    if (!widget.enableRefresh) {
      setState(() {
        finishRefresh = true;
        finishLoad = true;
      });
    }
  }

  Future<void> _startRequest(String url, {bool refresh}) async {
    await Request.get1(url: url).then((response) {
      var data = response.data;
      data = widget.mapKey == null ? data : data[widget.mapKey];
      List combineList = [];
      // 下拉刷新的时候，只需要将新的数组赋值到数据list中
      // 上拉加载的时候，需要将新的数组添加到现有数据list中
      if (refresh == true) {
        combineList = data;
        if (data.length == 0) {
          noResults = true;
        }
      } else {
        combineList = _dataList;
        combineList.addAll(data);
      }
      setState(() {
        if (data.length == 0) {
          _finishLoad();
        } else {
          _resetState();

        }
        if (widget.reverseData && widget.enableRefresh) {
          _dataList = combineList.reversed;
        } else {
          _dataList = combineList;
        }
       // _controller.resetLoadState();
      });

      if (widget.headerLinkPagination != null && widget.headerLinkPagination == true) {
        var link = response.headers['link'][0].split(',');
        if (link.length < 2) {
          _finishLoad();
        } else {
          nextUrl = link[0].substring(1,link[0].indexOf('>'));
        }
      }

    });
  }

  _finishLoad() {
    setState(() {
      _controller.finishLoad(noMore: true,success: true);
      finishLoad = true;
    });
  }

  _resetState() {
    _controller.resetLoadState();
    setState(() {
      finishLoad = false;
    });
  }



  Widget buildRow(int index) {
      return widget.buildRow(index, _dataList);
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0+0.18*textScale),
      child: EasyRefresh.custom(
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
                (context,index) {
                  return widget.buildRow(index, _dataList);
                },
              childCount: _dataList.length
            ),
          )
        ],
        firstRefresh: true,
        firstRefreshWidget: LoadingView(),
        header: widget.header ?? ListViewUtil.getDefaultHeader(context),
        footer: ListViewUtil.getDefaultFooter(context),
        controller: _controller,
        scrollController: _scrollController,
        onRefresh: finishRefresh ? null : _onRefresh,
        onLoad: finishLoad ? null :_onLoad,
        emptyWidget: noResults ? widget.emptyWidget ?? EmptyView() :null,
      ),
    );

  }

  @override
  void dispose() {
    eventBus.off(widget.type);
    eventBus.off(EventBusKey.muteAccount);
    eventBus.off(EventBusKey.blockAccount);
    for (var event in widget.triggerRefreshEvent) {
      eventBus.off(event);
    }
    eventBus.off(EventBusKey.textScaleChanged,onTextScaleChanged);
    super.dispose();
  }
}
