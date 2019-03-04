import 'package:flutter/material.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/widget/article_list.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {  
  bool _canLoadWidget = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // 隐藏登录弹出页
    eventBus.on(EventBusKey.StorageSuccess, (arg) {
      setState(() {
        _canLoadWidget = true;
      });
    });
  }

  @override
  void dispose() {
    eventBus.off(EventBusKey.StorageSuccess);
    super.dispose();
  }

  Widget loadWidget() {
    if (_canLoadWidget == false) {
      return Center(
        child: Text('登录'),
      );
    } else {
      return ArticleList(
        timelineHost: Api.HomeTimeLine,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('首页'),
        backgroundColor: MyColor.mainColor,
      ),
      body: loadWidget()
    );
  }
}