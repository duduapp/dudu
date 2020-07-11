import 'package:fastodon/utils/request.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ResultListProvider extends ChangeNotifier {
  final String requestUrl;
  List<dynamic> list = [];
  final String mapKey;
  final bool offsetPagination; //search 里面的max id和 min id 不能用
  final bool headerLinkPagination;
  final bool enableRefresh;
  final bool reverseData;
  bool finishRefresh = false;
  bool finishLoad = false;
  bool noResults = false;
  String nextUrl;
  GlobalKey<SliverAnimatedListState> listKey;
  final Function buildRow;

  ResultListProvider(
      {@required this.requestUrl,
      @required this.buildRow,
      this.mapKey,
      this.offsetPagination,
      this.headerLinkPagination = false,
      this.enableRefresh = true,
      this.reverseData = false});

  Future<void> refresh() async {
    await _startRequest(requestUrl, refresh: true);
    if (!enableRefresh) {
      finishRefresh = true;
      finishLoad = true;
      notifyListeners();
    }
  }

  Future<void> load() async {
    if (headerLinkPagination != null && headerLinkPagination == true) {
      if (nextUrl != null) {
        _startRequest(nextUrl);
        nextUrl = null;
      }
    } else {
      String lastCellId = list[list.length - 1]['id'];
      String appendOffset = "";
      if (offsetPagination != null && offsetPagination) {
        appendOffset = "&offset=${list.length}";
      }
      // get请求中是否已经包含了其他的参数
      var since = "max_id";
      if (requestUrl.contains('?')) {
        await _startRequest(requestUrl + '&max_id=$lastCellId$appendOffset');
      } else {
        await _startRequest(requestUrl + '?max_id=$lastCellId$appendOffset');
      }
    }
  }

  Future<void> _startRequest(String url, {bool refresh}) async {
    await Request.get1(url: url).then((response) {
      var data = response.data;
      data = mapKey == null ? data : data[mapKey];
      List combineList = [];
      // 下拉刷新的时候，只需要将新的数组赋值到数据list中
      // 上拉加载的时候，需要将新的数组添加到现有数据list中
      if (refresh == true) {
        combineList = data;
        if (data.length == 0) {
          noResults = true;
        }
      } else {
        combineList = list;
        combineList.addAll(data);
      }

      if (data.length == 0) {
        finishLoad = true;
      } else {
        finishLoad = false;
      }
      if (reverseData && enableRefresh) {
        list = combineList.reversed;
      } else {
        list = combineList;
      }

      if (headerLinkPagination != null && headerLinkPagination == true) {
        if (response.headers.map.containsKey('link')) {
          var link = response.headers['link'][0].split(',');
          if (link.length < 2) {
            finishLoad = true;
          } else {
            nextUrl = link[0].substring(1, link[0].indexOf('>'));
          }
        } else {
          finishLoad = true;
        }
      }
      notifyListeners();
    });
  }

  removeByIdWithAnimation(String id) {
    var idx = _indexOfId(id);
    listKey?.currentState?.removeItem(idx, (context, animation) {
      var copyList = List.from(list);
      list.removeWhere((element) => element['id'] == id);
      return SizeTransition(
        axis: Axis.vertical,
        sizeFactor: animation,
        child: buildRow(idx, copyList),
      );
    });
  }

  update(dynamic data) {
    if (data == null) {
      return;
    }
    var idx = _indexOfId(data['id']);
    if (idx != -1) {
      list[idx] = data;
    }
    notifyListeners();
  }

  addToListWithAnimation(dynamic data) {
    if (data == null) {
      return;
    }
    list.insert(0, data);
    listKey?.currentState?.insertItem(0);
  }

  _indexOfId(String id) {
    return list.indexWhere((element) => element['id'] == id);
  }

  setAnimatedListKey(GlobalKey<SliverAnimatedListState> key) {
    listKey = key;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
