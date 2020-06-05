import 'package:flutter_easyrefresh/easy_refresh.dart';

class AppConfig {
  static String ClientName = 'masfto';
  static String RedirectUris = 'https://mah93.github.io';
  static String Scopes = 'read write follow push';

  static ClassicalHeader listviewHeader =  ClassicalHeader(
    refreshText: '下拉刷新',
    refreshReadyText: '释放刷新',
    refreshingText: '加载中...',
    refreshedText: '',
    refreshFailedText: '刷新失败',
    noMoreText: '没有更多数据',
    infoText: '更新于 %T',
  );

  static ClassicalFooter listviewFooter = ClassicalFooter(
  enableInfiniteLoad: true,
  loadText: '拉动加载',
  loadReadyText: '释放加载',
  loadingText: '加载中...',
  loadedText: '',
  loadFailedText: '加载失败',
  noMoreText: '没有更多数据了',
  infoText: '',
  );
}
