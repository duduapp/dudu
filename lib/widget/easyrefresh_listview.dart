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
    this.type
  }) : super(key: key);
  final String requestUrl;
  final Function buildRow;
  final TimelineType type;

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

  @override
  void initState() {
    super.initState();

    _startRequest(widget.requestUrl);

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
    // get请求中是否已经包含了其他的参数
    if (widget.requestUrl.contains('?')) {
      await _startRequest(widget.requestUrl + '&max_id=$lastCellId');
    } else {
      await _startRequest(widget.requestUrl + '?max_id=$lastCellId');
    }
  }

  Future<void> _onRefresh() async{
    await _startRequest(widget.requestUrl,refresh: true);
  }

  Future<void> _startRequest(String url, {bool refresh}) async {
    await Request.get(url: url).then((data) {
      List combineList = [];
      // 下拉刷新的时候，只需要将新的数组赋值到数据list中
      // 上拉加载的时候，需要将新的数组添加到现有数据list中
      if (refresh == true) {
        combineList = data;
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
      header: AppConfig.listviewHeader,
      footer: AppConfig.listviewFooter,
      controller: _controller,
      scrollController: _scrollController,
      onRefresh: _onRefresh,
      onLoad: _onLoad,
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
