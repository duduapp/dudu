// 下拉刷新和上拉加载
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fastodon/public.dart';

class RefreshLoadListView extends StatefulWidget {
  RefreshLoadListView({
    Key key, 
    @required this.requestUrl,
    @required this.buildRow,
  }) : super(key: key);
  final String requestUrl;
  final Function buildRow;

  @override
  _RefreshLoadListViewState createState() => _RefreshLoadListViewState();
}

enum ListStatus {
  normal,
  loadingData,
  noMoreData
}

class _RefreshLoadListViewState extends State<RefreshLoadListView> {
  ScrollController _scrollController = ScrollController();
  List _dataList = [];
  bool _finishRequest = false;
  ListStatus _listStatus = ListStatus.normal;

  @override 
  void initState() {
    super.initState();
    _startRequest(widget.requestUrl);

    _scrollController.addListener(() {
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent && _listStatus != ListStatus.noMoreData) {
        setState(() {
          _listStatus = ListStatus.loadingData;
        });
        String lastCellId = _dataList[_dataList.length - 1]['id'];
        if (widget.requestUrl.contains('?')) {
          _startRequest(widget.requestUrl + '&max_id=$lastCellId');
        } else {
          _startRequest(widget.requestUrl + '?max_id=$lastCellId');
        }
      }
    });
  }

  Future<void> _startRequest(String url, {bool refresh}) async {
    Request.get(url: url, callBack: (List data) {
      List combineList = [];
      if (refresh == true) {
        combineList = data;
      } else {
        combineList = _dataList;
        combineList.addAll(data);
      }
      setState(() {
        _dataList = combineList;
        _finishRequest = true;
        if (data.length == 0) {
          _listStatus = ListStatus.noMoreData;
        } else {
          _listStatus = ListStatus.normal;
        }
      });
    });
  }

  Widget buildFooter() {
    if (_listStatus == ListStatus.normal) {
      return Container();
    } else if (_listStatus == ListStatus.loadingData) {
      return Container(
        height: 40,
        child: Center(
          child: SpinKitThreeBounce(
            color: MyColor.mainColor,
            size: 23,
          ),
        ),
      );
    } else if (_listStatus == ListStatus.noMoreData) {
      return Container(
        height: 40,
        child: Center(
          child: Text('没有更多数据了'),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget buildRow(int index) {
    if (index == _dataList.length - 1) {
      return Column(
        children: <Widget>[
          widget.buildRow(index, _dataList),
          buildFooter(),
        ],
      );
    } else {
      return widget.buildRow(index, _dataList);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _startRequest(widget.requestUrl, refresh: true),
      child: LoadingWidget(
        endLoading: _finishRequest,
        childWidget: ListView.separated(
          controller: _scrollController,
          itemBuilder: (BuildContext context, int index) {
            return buildRow(index);
          },
          itemCount: _dataList.length,
          separatorBuilder: (BuildContext context, int index) {
            return Divider(height: 1.0, color: MyColor.dividerLineColor);
          },
        ),
      )
    );
  }
}