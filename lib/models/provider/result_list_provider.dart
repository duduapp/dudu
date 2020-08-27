import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/models/runtime_config.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/filter_util.dart';
import 'package:dudu/utils/request.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

typedef ResultListDataHandler = Function(dynamic data);
typedef RowBuilder = Function(int idx, List data, ResultListProvider provider);

class ResultListProvider extends ChangeNotifier {
  String requestUrl;
  List<dynamic> list = [];
  final String mapKey;
  final bool offsetPagination; //search 里面的max id和 min id 不能用
  final bool headerLinkPagination;
  final bool enableRefresh;
  final bool enableLoad;
  final bool reverseData;
  bool finishRefresh = false;
  bool finishLoad = false;
  bool noResults = true;
  bool isLoading = false;
  bool enableCache;
  DioError error;
  String nextUrl;
  final bool listenBlockEvent;
  GlobalKey<SliverAnimatedListState> listKey;
  final RowBuilder buildRow;
  Map<String, dynamic> events = {};
  final bool onlyMedia;
  final ResultListDataHandler dataHandler;
  String lastCellId = '0';
  CancelToken token = CancelToken();
  final String tag;
  String lastRequestUrl = '';

  EasyRefreshController refreshController;

  /// map key 的优先级高于 data handler
  ResultListProvider(
      {@required this.requestUrl,
      @required this.buildRow,
      this.mapKey,
      this.offsetPagination,
      this.headerLinkPagination = false,
      this.enableRefresh = true,
      this.enableLoad = true,
      this.reverseData = false,
      this.listenBlockEvent = false,
      this.onlyMedia = false,
      this.dataHandler,
        bool firstRefresh = true,
      bool showLoading = true, // 给list 第一次赋值，刷新后用结果值
        this.enableCache = false,
      this.tag}) {

    if (listenBlockEvent) {
      _addEvent(EventBusKey.blockAccount, (arg) {
        var accountId = arg['account_id'];
        list.removeWhere((element) => element['account']['id'] == accountId);
        notifyListeners();
      });
      _addEvent(EventBusKey.muteAccount, (arg) {
        var accountId = arg['account_id'];

        list.removeWhere((element) => element['account']['id'] == accountId);
        notifyListeners();
      });
    }

    if (firstRefresh)
    refresh(showLoading: showLoading);
  }



  reConstructFilterList() {
    list = _filterData(list);
    notifyListeners();
  }

  _filterData(List data) {
    if (['home','thread'].contains(tag)) {
      return FilterUtil.filterData(data, tag);
    }

    if (tag == 'notifications') {
      return FilterUtil.filterData(data, tag, mapKey: 'status');
    }

    if (['local','federated'].contains(tag)) {
      return FilterUtil.filterData(data, 'public');
    }
    return List.from(data);
  }

  _addEvent(String eventName, EventCallback callback) {
    eventBus.on(eventName, callback);
    events[eventName] = callback;
  }

  Future<void> refresh({bool showLoading = false}) async {
    if (showLoading) {
      error = null;
      isLoading = true;
      notifyListeners();
    }
    bool success = await _startRequest(requestUrl, refresh: true);

    if (success) {
      if (showLoading) {
        isLoading = false;
        notifyListeners();
      }
      if (!enableRefresh) {
        finishRefresh = true;
        // finishLoad = true;
        notifyListeners();
      }
      if (!enableLoad) {
        finishLoad = true;
        notifyListeners();
      }
    }
  }


  Future<void> load() async {
    if (headerLinkPagination != null && headerLinkPagination == true) {
      if (nextUrl != null) {
       await _startRequest(nextUrl);

      }
    } else {
      String appendOffset = "";
      if (offsetPagination != null && offsetPagination) {
        appendOffset = "&offset=${list.length}";
      }
      // get请求中是否已经包含了其他的参数
      if (requestUrl.contains('?')) {
        await _startRequest(requestUrl + '&max_id=$lastCellId$appendOffset');
      } else {
        await _startRequest(requestUrl + '?max_id=$lastCellId$appendOffset');
      }
    }
  }

  Future<bool> _startRequest(String url, {bool refresh = false}) async {
    // 防止重复请求
    if (url == lastRequestUrl && !refresh) {
      return false;
    } else {
      lastRequestUrl = url;
    }



    var response;
    try {
      response = await Request.get(
          url: url, returnAll: true, cancelToken: token,enableCache: enableCache);
    } catch (e) {
      return false;
    }

    //只有列表为空时，才显示错误，为了更好的用户体验
    if (response == null && list.isEmpty) {
      error = RuntimeConfig.error;
      if (error is DioError) {
        if (error.type == DioErrorType.CANCEL) {
          return false;
        }
      }
      notifyListeners();
      return false;
    } else if (response is DioError) {
      return false;
    } else if (response == null){
      return false;
    }else{
      error = null;
    }
    var data = response.data;

    if (mapKey != null) {
      data = data[mapKey];
    }

    if (dataHandler != null) {
      data = dataHandler(data);
    }

    if (data.length > 0 && data[data.length - 1].isNotEmpty && !headerLinkPagination) {
      lastCellId = data[data.length - 1]['id'];
    }

    // 下拉刷新的时候，只需要将新的数组赋值到数据list中
    // 上拉加载的时候，需要将新的数组添加到现有数据list中
    if (refresh == true) {
      list = _filterData(data);
      if (data.length == 0) {
        noResults = true;
      } else {
        noResults = false;
      }
    } else {
      list.addAll(_filterData(data));
    }

    if (data.length == 0) {
      finishLoad = true;
    } else {
      finishLoad = false;
    }
    if (reverseData && enableRefresh) {
      list = _filterData(list.reversed);
    }

    if (headerLinkPagination != null && headerLinkPagination == true) {
      if (response.headers.map.containsKey('link')) {
        var link = response.headers['link'][0].split(',');
        if (link.length < 2) {
          finishLoad = true;
          nextUrl = null;
        } else {
          nextUrl = link[0].substring(1, link[0].indexOf('>'));
        }
      } else {
        finishLoad = true;
      }
    }
    notifyListeners();

    return true;
  }



  removeByIdWithAnimation(String id) {
    var idx = _indexOfId(id);
    if (idx == -1) {
      return;
    }

    if (listKey != null) {
      listKey?.currentState?.removeItem(idx, (context, animation) {
        var copyList = List.from(list);
        list.removeWhere((element) => element is Map && element['id'] == id);
        return SizeTransition(
          axis: Axis.vertical,
          sizeFactor: animation,
          child: buildRow(idx, copyList, this),
        );
      });
    } else {
      list.removeWhere((element) => element is Map && element['id'] == id);
      notifyListeners();
    }
  }

  removeWhere(Function where) {
    list.removeWhere(where);
    notifyListeners();
  }

  removeByValueWithAnimation(dynamic value) {
    var idx = list.indexOf(value);
    if (listKey != null) {
      listKey?.currentState?.removeItem(idx, (context, animation) {
        var copyList = List.from(list);
        list.remove(value);
        return SizeTransition(
          axis: Axis.vertical,
          sizeFactor: animation,
          child: buildRow(idx, copyList, this),
        );
      });
    } else {
      list.remove(value);
      notifyListeners();
    }
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
    if (noResults) {
      noResults = false;
      notifyListeners();
    }
    list.insert(0, data);
    if (listKey != null)
    listKey?.currentState?.insertItem(0);
    else
      notifyListeners();
  }

  _indexOfId(String id) {
    return list.indexWhere((element) => element is Map && element['id'] == id);
  }

  setAnimatedListKey(GlobalKey<SliverAnimatedListState> key) {
    listKey = key;
  }

  clearData() {
    list.clear();
    noResults = true;
    notifyListeners();
  }

  notify() {
    notifyListeners();
  }

  setData(List listData,{bool updateNoResults = true}) {
    if (updateNoResults)
      noResults = false;
    list = _filterData(listData);
    notifyListeners();
  }

  @override
  void dispose() {
    token.cancel('canceld');
    events.forEach((key, value) {
      eventBus.off(key, value);
    });
    SettingsProvider.getCurrentContextProvider().statusDetailProviders.remove(this);
    super.dispose();
  }
}
