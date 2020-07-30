import 'dart:async';

import 'package:fastodon/api/status_api.dart';
import 'package:fastodon/models/json_serializable/article_item.dart';
import 'package:fastodon/models/provider/result_list_provider.dart';
import 'package:fastodon/models/provider/settings_provider.dart';
import 'package:fastodon/utils/list_view.dart';
import 'package:fastodon/widget/listview/provider_easyrefresh_listview.dart';
import 'package:fastodon/widget/status/status_item.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:provider/provider.dart';

class StatusDetail extends StatefulWidget {
  final StatusItemData data;
  StatusDetail(this.data);
  @override
  _StatusDetailState createState() => _StatusDetailState();
}

class _StatusDetailState extends State<StatusDetail> {
  Map _data = {};
  final ScrollController _scrollController = ScrollController();
  final EasyRefreshController _controller = EasyRefreshController();
  final List<GlobalKey> keys = [];
  int itemPosition = 0;

  @override
  void initState() {
    //getData();
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    super.initState();
  }

  getData() async {
    var _res = await StatusApi.getContext(widget.data.id);
    keys.clear();
    setState(() {
      _data = _res;
    });
  }

  Widget _buildRow(int idx, List data, ResultListProvider provider) {
    if (data.length > 1 && (idx == data.length - 1)) {

      _afterLayout("_");


    }

    if (idx < itemPosition) {
      return _buildStatusItem(StatusItemData.fromJson(data[idx]),
          subStatus: true);
    } else if (idx == itemPosition) {
      return _buildStatusItem(widget.data, primary: true);
    } else {
      return _buildStatusItem(
        StatusItemData.fromJson(data[idx]),
        subStatus: true,
      );
    }
  }

  Widget _buildStatusItem(StatusItemData data, {bool subStatus, bool primary}) {
    var gk = GlobalKey();
    keys.add(gk);
    return Container(
      key: gk,
      child: StatusItem(
        item: data,
        subStatus: subStatus,
        primary: primary,
      ),
    );
  }

  Future<void> _onRefresh() async {
    await getData();
  }

  get childCount {
    if (_data.length == 0) {
      return 1;
    } else {
      return _data['ancestors'].length + _data['descendants'].length + 1;
    }
  }

  _afterLayout(_) {
    double totalHeight = 0;
    for (int i = 0; i <= itemPosition; i++) {
      try {
        RenderBox renderBox = keys[i].currentContext.findRenderObject();
        totalHeight += renderBox.size.height;
      } catch (e) {}
    }
    if (totalHeight == 0) {
      return;
    }
    _scrollController.jumpTo(totalHeight - 50);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    var scale = SettingsProvider.getWithCurrentContext('text_scale');
    return Scaffold(
      appBar: AppBar(
        title: Text('嘟文'),
        centerTitle: false,
      ),
      body: MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaleFactor: 1.0 + 0.18 * double.parse(scale)),
        child: ChangeNotifierProvider<ResultListProvider>(
          create: (context) => ResultListProvider(
              requestUrl: '${StatusApi.url}/${widget.data.id}/context',
              buildRow: _buildRow,
          //    holderList: [widget.data.toJson()],
              showLoading: false,
              enableLoad: false,
              dataHandler: (data) {
                List res = [];
                for (var d in data['ancestors']) {
                  res.add(d);
                }
                res.add(widget.data.toJson());
                itemPosition = data['ancestors'].length;
                for (var d in data['descendants']) {
                  res.add(d);
                }
//                data['ancestors'].forEach((d) => res.add(d));
//
//                data['descendants'].forEach((d) => res.add(d));
                return res;
              }
          ),
          builder: (context, snapshot) {
            return ProviderEasyRefreshListView(
              scrollController: _scrollController,
              cacheExtent: 10000,
            );
          },
        ),
//        child: EasyRefresh.custom(
//          cacheExtent: 10000,
//          slivers: [
//
//            SliverList(
//              delegate: SliverChildBuilderDelegate(
//                      (context,idx) {
//                    return _buildRow(idx);
//                  },
//                  childCount: childCount
//              ),
//            )
//          ],
//          header: ListViewUtil.getDefaultHeader(context),
//          footer: null,
//          controller: _controller,
//          scrollController: _scrollController,
//          onRefresh: _onRefresh,
//          onLoad: null,
//        ),
      ),
    );
  }
}
