// 下拉刷新和上拉加载
import 'package:fastodon/pages/timeline/timeline.dart';
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
    this.emptyWidget
  }) : super(key: key);
  final String requestUrl;
  final Function buildRow;
  final TimelineType type;
  final String mapKey; // 返回的结果是map,而且key 是 mapKey
  final bool offsetPagination; //search 里面的max id和 min id 不能用
  final Widget emptyWidget;

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
  EasyRefreshController _controller = EasyRefreshController();
  int offset;
  bool noResults = false;

  @override
  void initState() {
    super.initState();

    _startRequest(widget.requestUrl,refresh: true);

    eventBus.on(widget.type, (arg) {
        _scrollController.jumpTo(0);
    });

    eventBus.on(EventBusKey.muteAccount,(arg){
      _removeByAccountId(arg['account_id']);

    });
    
    eventBus.on(EventBusKey.blockAccount,(arg) {
      _removeByAccountId(arg['account_id']);
    });
  }
  
  _removeByAccountId(String accountId) {
    setState(() {
      _dataList.removeWhere((element) => element['account']['id'] == accountId);
    });
  }

  Future<void> _onLoad() async{
    String lastCellId = _dataList[_dataList.length - 1]['id'];
    String appendOffset = "";
    if (widget.offsetPagination != null && widget.offsetPagination == true) {
      appendOffset = "&offset=${_dataList.length}";
    }
    // get请求中是否已经包含了其他的参数
    if (widget.requestUrl.contains('?')) {
      await _startRequest(widget.requestUrl + '&max_id=$lastCellId$appendOffset');
    } else {
      await _startRequest(widget.requestUrl + '?max_id=$lastCellId$appendOffset');
    }
  }

  Future<void> _onRefresh() async{
    await _startRequest(widget.requestUrl,refresh: true);
  }

  Future<void> _startRequest(String url, {bool refresh}) async {
    await Request.get(url: url).then((data) {
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
          _controller.finishLoad(noMore: true,success: true);
        } else {
          _controller.resetLoadState();
        }
        _dataList = combineList;
       // _controller.resetLoadState();
      });
    });
  }



  Widget buildRow(int index) {
      return widget.buildRow(index, _dataList);
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh.custom(
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
      firstRefreshWidget: Center(child: SizedBox(child: CircularProgressIndicator(),width: 50,height: 50,),),
      header: AppConfig.listviewHeader,
      footer: AppConfig.listviewFooter,
      controller: _controller,
      scrollController: _scrollController,
      onRefresh: _onRefresh,
      onLoad: _onLoad,
      emptyWidget: noResults ? widget.emptyWidget :null,
    );

  }

  @override
  void dispose() {
    eventBus.off(widget.type);
    eventBus.off(EventBusKey.muteAccount);
    eventBus.off(EventBusKey.blockAccount);
    super.dispose();
  }
}
