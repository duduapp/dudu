// 下拉刷新和上拉加载
import 'package:fastodon/models/json_serializable/owner_account.dart';
import 'package:fastodon/public.dart';
import 'package:flutter/material.dart';

import 'follow_cell.dart';

class FollowerList extends StatefulWidget {
  FollowerList({
    Key key, 
    this.url,
  }) : super(key: key);
  final String url;

  @override
  _FollowerListState createState() => _FollowerListState();
}

class _FollowerListState extends State<FollowerList> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List _dataList = [];
  bool _finishRequest = false;

  @override 
  void initState() {
    super.initState();
    _startRequest(widget.url);
  }

  Future<void> _startRequest(url) async {
    Request.get(url: url).then((data) {
      if(this.mounted) {
        setState(() {
          _dataList = data;
          _finishRequest = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LoadingWidget(
      endLoading: _finishRequest,
      childWidget: RefreshIndicator(
        onRefresh: () => _startRequest(widget.url),
        child: Container(
          padding: EdgeInsets.only(top: 0),
          child: ListView.separated(
            padding: new EdgeInsets.only(top: 0.0),
            itemBuilder: (BuildContext context, int index) {
              OwnerAccount account = OwnerAccount.fromJson(_dataList[index]);
              return FollowCell(item: account);
            },
            itemCount: _dataList.length,
            separatorBuilder: (BuildContext context, int index) {
              return Divider(height: 1.0, color: MyColor.dividerLineColor);
            },
          ),
        )
      )
    );
  }
}