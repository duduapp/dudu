import 'dart:async';

import 'package:dudu/api/status_api.dart';
import 'package:dudu/models/json_serializable/article_item.dart';
import 'package:dudu/models/provider/result_list_provider.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/view/list_view_util.dart';
import 'package:dudu/widget/common/colored_tab_bar.dart';
import 'package:dudu/widget/common/empty_view.dart';
import 'package:dudu/widget/common/measure_size.dart';
import 'package:dudu/widget/listview/provider_easyrefresh_listview.dart';
import 'package:dudu/widget/status/status_item.dart';
import 'package:dudu/widget/status/status_item_action_w.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart'
    as extend;

class StatusDetail extends StatefulWidget {
  final StatusItemData data;
  StatusDetail(this.data);
  @override
  _StatusDetailState createState() => _StatusDetailState();
}

class _StatusDetailState extends State<StatusDetail>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> keys = [];
  int itemPosition = 0;

  List<ResultListProvider> providers = [];
  List<Widget> parentWidgets = [];
  List<dynamic> descendants;
  TabController _tabController;

  double _sliverExpandHeight = 10000;
  bool _getSliverExpandHeight = false;

  _fetchData() async {
    var data = await StatusApi.getContext(widget.data.id);
    if (data != null) {
      parentWidgets.clear();
      for (var d in data['ancestors']) {
        d['__sub'] = true;

        d['media_attachments'].forEach((e) => e['id'] = "c_" + e['id']);
        parentWidgets.add(_buildStatusItem(
          StatusItemData.fromJson(d),
          subStatus: true,
        ));
      }

      parentWidgets
          .add(_buildStatusItem(widget.data, primary: true, subStatus: false));

      parentWidgets.add(Container(
        height: 38,
        color: Theme.of(context).scaffoldBackgroundColor,
      ));

      itemPosition = data['ancestors'].length;
      for (var d in data['descendants']) {
        d['media_attachments'].forEach((e) => e['id'] = "c_" + e['id']);
        d['__sub'] = true;
      }
      descendants = data['descendants'];
      var primaryJson = widget.data.toJson();
      primaryJson['__visible'] = false;
      descendants.add(primaryJson);
      providers[0].setData(descendants,updateNoResults: descendants.length > 1);

      setState(() {
        _getSliverExpandHeight = false;
        _sliverExpandHeight = 10000;
      });
    }
  }

  @override
  void initState() {
    //deep copy media attachments
    var data = widget.data.toJson();
    var copyAttachments = [];
    for (var m in data['media_attachments']) {
      copyAttachments.add(Map<String, dynamic>.from(m));
    }
    data['media_attachments'] = copyAttachments;
    data['media_attachments'].forEach((e) => e['id'] = "c_" + e['id']);

    _tabController = TabController(length: 3, vsync: this);

    providers.addAll([
      ResultListProvider(
          enableRefresh: false,
          enableLoad: false,
          firstRefresh: false,
          buildRow: _buildRow),
      ResultListProvider(
          requestUrl: '${StatusApi.url}/${widget.data.id}/reblogged_by',
          enableRefresh: false,
          enableLoad: false,
          firstRefresh: false,
          buildRow: ListViewUtil.accountRowFunction()),
      ResultListProvider(
          requestUrl: '${StatusApi.url}/${widget.data.id}/favourited_by',
          enableRefresh: false,
          enableLoad: false,
          firstRefresh: false,
          buildRow: ListViewUtil.accountRowFunction())
    ]);
    SettingsProvider().statusDetailProviders.add(providers[0]);
    _fetchData();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    SettingsProvider().statusDetailProviders.remove(providers[0]);
    super.dispose();
  }

  Widget _buildRow(int idx, List data, ResultListProvider provider) {
    var row = data[idx];
    if (row.containsKey('__visible') && !row['__visible']) {
      return Container();
    }
    return _buildStatusItem(
      StatusItemData.fromJson(row),
      subStatus: true,
    );
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
      RenderBox renderBox =
          keys[itemPosition].currentContext.findRenderObject();
      itemHeight = renderBox.size.height;
    } catch (e) {
      // print(e);
    }

    _scrollController.animateTo(ancestorsHeight,
        duration: Duration(milliseconds: 500), curve: Curves.easeInOutSine);
    return;
  }

  Widget _statusContent() {
    return Container(
      color: null,
      child: MeasureSize(
        onChange: (size) {
          if (!_getSliverExpandHeight) {
            if (size.height == 0) return;
            setState(() {
              _getSliverExpandHeight = true;
              _sliverExpandHeight = size.height;
              _afterLayout('');
            });
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: parentWidgets,
        ),
      ),
    );
  }

  Widget contentView() {
    return TabBarView(
      controller: _tabController,
      children: [
        extend.NestedScrollViewInnerScrollPositionKeyWidget(
          Key('tab0'),
          ChangeNotifierProvider<ResultListProvider>.value(
            value: providers[0],
            child: ProviderEasyRefreshListView(
              firstRefresh: false,
              enableLoad: false,
              emptyView: EmptyViewWithHeight(text: '还没有转评',),
            ),
          ),
        ),
        extend.NestedScrollViewInnerScrollPositionKeyWidget(
          Key('tab1'),
          ChangeNotifierProvider<ResultListProvider>.value(
            value: providers[1],
            child: ProviderEasyRefreshListView(
              firstRefresh: true,
              emptyView: EmptyViewWithHeight(text: '还没有转嘟',),
            ),
          ),
        ),
        extend.NestedScrollViewInnerScrollPositionKeyWidget(
          Key('tab2'),
          ChangeNotifierProvider<ResultListProvider>.value(
            value: providers[2],
            child: ProviderEasyRefreshListView(
              firstRefresh: true,
              emptyView: EmptyViewWithHeight(text: '还没有点赞',),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('嘟文信息'),
        toolbarHeight: 50,
      ),
      body: Column(
        //  alignment: AlignmentDirectional.bottomEnd,
        children: [
          Expanded(
            child: extend.NestedScrollViewRefreshIndicator(
              onRefresh: () async {
                await _fetchData();
                if (_tabController.index != 0) {
                  providers[_tabController.index].refresh(showLoading: true);
                }
                return;
              },
              child: extend.NestedScrollView(
                controller: _scrollController,
                innerScrollPositionKeyBuilder: () {
                  return Key('tab${_tabController.index}');
                },
                headerSliverBuilder: (context, bool) {
                  return [
                    SliverAppBar(
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      toolbarHeight: 0,
                      flexibleSpace: !_getSliverExpandHeight
                          ? _statusContent()
                          : FlexibleSpaceBar(
                              collapseMode: CollapseMode.pin,
                              background: _statusContent(),
                            ),
                      expandedHeight: _sliverExpandHeight,
                      pinned: true,
                      floating: false,
                      snap: false,
                      bottom: ColoredTabBar(
                        color: Theme.of(context).primaryColor,
                        height: 38,
                        tabBar: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            color: Theme.of(context).primaryColor,
                            child: Column(
                              children: [
                                TabBar(
                                  labelColor: Theme.of(context).buttonColor,
                                  unselectedLabelColor:
                                      Theme.of(context).accentColor,
                                  labelStyle: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal),
                                  isScrollable: false,
                                  indicatorColor: Theme.of(context).buttonColor,
                                  indicator: UnderlineTabIndicator(
                                      borderSide: BorderSide(
                                          width: 1.0,
                                          color: Theme.of(context).buttonColor),
                                      insets: EdgeInsets.symmetric(
                                          horizontal:
                                              ScreenUtil.width(context) / 9)),
                                  tabs: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        '转评 ' +
                                            widget.data.repliesCount.toString(),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        '转嘟 ' +
                                            widget.data.reblogsCount.toString(),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        '赞 ' +
                                            widget.data.favouritesCount
                                                .toString(),
                                      ),
                                    ),
                                  ],
                                  onTap: (index) {
                                    setState(() {});
                                  },
                                  controller: _tabController,
                                ),
                                Divider(
                                  height: 0,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ];
                },
                body: contentView(),
              ),
            ),
          ),
          Container(
              decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(
                          width: 0.5, color: Theme.of(context).dividerColor))),
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: SafeArea(
                  child: StatusItemActionW(
                status: widget.data,
                subStatus: false,
                showNum: false,
              )))
        ],
      ),
    );
  }
}
