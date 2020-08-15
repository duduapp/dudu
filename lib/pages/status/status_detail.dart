import 'dart:async';

import 'package:dudu/api/status_api.dart';
import 'package:dudu/models/json_serializable/article_item.dart';
import 'package:dudu/models/provider/result_list_provider.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/view/list_view_util.dart';
import 'package:dudu/widget/listview/provider_easyrefresh_listview.dart';
import 'package:dudu/widget/status/status_item.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:provider/provider.dart';

class StatusDetail extends StatefulWidget {
  final StatusItemData data;
  StatusDetail(this.data);
  @override
  _StatusDetailState createState() => _StatusDetailState();
}

class _StatusDetailState extends State<StatusDetail> {

  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> keys = [];
  int itemPosition = 0;
  StatusItemData status;
  ResultListProvider provider;
  OverlayEntry overlayEntry;
  bool overlayRemoved = true;
  AppBar appBar;

  @override
  void initState() {
    //deep copy media attachments
    var data = widget.data.toJson();
    var copyAttachments = [];
    for (var m in data['media_attachments']) {
      copyAttachments.add(Map<String,dynamic>.from(m));
    }
    data['media_attachments'] = copyAttachments;
    data['media_attachments'].forEach((e) => e['id'] = "c_" + e['id']);

    _scrollController.addListener(() {
      _removeOverlay();
    });

    status = StatusItemData.fromJson(data);
    super.initState();
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  _removeOverlay() {
    if (!overlayRemoved) {
      overlayEntry?.remove();
      overlayRemoved = true;
    }
  }

  Widget _buildRow(int idx, List data, ResultListProvider provider) {
    var row = data[idx];

    if (row.containsKey('__sub')) {
      return _buildStatusItem(
        StatusItemData.fromJson(row),
        subStatus: true,
      );
    } else {
      return _buildStatusItem(status, primary: true, subStatus: false);
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

  _afterLayout(_) {
    double ancestorsHeight = 0;
    double itemHeight = 0;
    double descendantsHeight = 0;
    for (int i = 0; i < itemPosition; i++) {
      try {
        RenderBox renderBox = keys[i].currentContext.findRenderObject();
        ancestorsHeight += renderBox.size.height;
      } catch (e) {
        // print(e);
      }
    }

    try {
      RenderBox renderBox = keys[itemPosition].currentContext.findRenderObject();
      itemHeight =  renderBox.size.height;
    } catch (e) {
      // print(e);
    }

    for (int i = itemPosition + 1; i < keys.length; i++) {
      try {
        RenderBox renderBox = keys[i].currentContext.findRenderObject();
        descendantsHeight += renderBox.size.height;
      } catch (e) {
        // print(e);
      }
    }

    if (ancestorsHeight + itemHeight + descendantsHeight < ScreenUtil.heightWithoutAppBar(context)) {
      if (ancestorsHeight > 0) {
        _insertOverlay(itemHeight, ancestorsHeight + ScreenUtil.appBarAndStatusBarHeight(context));
      }
      return;
    } else if (itemHeight + descendantsHeight < ScreenUtil.heightWithoutAppBar(context)){
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      _insertOverlay(itemHeight, ScreenUtil.height(context) - descendantsHeight - itemHeight);

    } else {
      if (ancestorsHeight > 0) {
        _insertOverlay(itemHeight, ScreenUtil.height(context) - descendantsHeight - itemHeight);
      }
      _scrollController.jumpTo(ancestorsHeight);
    }
  }

  _insertOverlay(double height,double top) {
    overlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
        width: ScreenUtil.width(context),
        height: height - 8,
        top: top,
        child: Container(
          color: Colors.red.withOpacity(0.15),
        ),
      );
    });

    Overlay.of(context).insert(overlayEntry);
    overlayRemoved = false;
    Future.delayed(Duration(milliseconds: 1000),() {
      _removeOverlay();
    });
  }

  @override
  Widget build(BuildContext context) {
    var scale = SettingsProvider.getWithCurrentContext('text_scale');
    appBar = AppBar(
      title: Text('嘟文'),
      centerTitle: false,
    );
    return Scaffold(
      appBar: appBar,
      body: MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaleFactor: 1.0 + 0.18 * double.parse(scale)),
        child: ChangeNotifierProvider<ResultListProvider>(
          create: (context) {
            var provider = ResultListProvider(
                requestUrl: '${StatusApi.url}/${widget.data.id}/context',
                tag: 'thread',
                buildRow: _buildRow,
                //    holderList: [widget.data.toJson()],
                enableLoad: false,
                dataHandler: (data) {
                  List res = [];
                  for (var d in data['ancestors']) {
                    d['__sub'] = true;

                    d['media_attachments']
                        .forEach((e) => e['id'] = "c_" + e['id']);
                    res.add(d);
                  }
                  //  res.add();
                  res.add(widget.data.toJson());
                  itemPosition = data['ancestors'].length;
                  for (var d in data['descendants']) {
                    d['__sub'] = true;
                    d['media_attachments']
                        .forEach((e) => e['id'] = "c_" + e['id']);
                    res.add(d);
                  }

                  return res;
                });
            SettingsProvider.getCurrentContextProvider()
                .statusDetailProviders
                .add(provider);
            this.provider = provider;
            return provider;
          },
          builder: (context, snapshot) {
            return ProviderEasyRefreshListView(
              scrollController: _scrollController,
              cacheExtent: 10000,
              enableLoad: false,
              showLoading: false,
              afterBuild: _afterLayout,
            );
          },
        ),
      ),
    );
  }
}
