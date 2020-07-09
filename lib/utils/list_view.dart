import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

class ListViewUtil {

  static Header getDefaultHeader(BuildContext context) {
    return ClassicalHeader(
      refreshText: '下拉刷新',
      refreshReadyText: '释放刷新',
      refreshingText: '加载中...',
      refreshedText: '',
      refreshFailedText: '刷新失败',
      noMoreText: '没有更多数据',
      infoText: '更新于 %T',
      textColor: Theme.of(context).accentColor
    );
  }

  static getDefaultFooter(BuildContext context) {
    return ClassicalFooter(
      showInfo: false,
      enableInfiniteLoad: true,
      loadText: '拉动加载',
      loadReadyText: '释放加载',
      loadingText: '加载中...',
      loadedText: '',
      loadFailedText: '加载失败',
      noMoreText: '',
      infoText: '',
    );
  }

}