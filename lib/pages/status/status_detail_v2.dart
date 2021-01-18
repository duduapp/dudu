import 'package:dudu/api/status_api.dart';
import 'package:dudu/l10n/l10n.dart';
import 'package:dudu/models/json_serializable/article_item.dart';
import 'package:dudu/models/provider/result_list_provider.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/pages/status/boosted_by.dart';
import 'package:dudu/pages/status/favorite_by.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/i18n_util.dart';
import 'package:dudu/widget/button/text_ink_well.dart';
import 'package:dudu/widget/common/custom_app_bar.dart';
import 'package:dudu/widget/status/status_item.dart';
import 'package:dudu/widget/status/status_item_action_w.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusDetailV2 extends StatefulWidget {
  final StatusItemData data;
  final String hostUrl;
  StatusDetailV2({this.data, this.hostUrl});
  @override
  _StatusDetailV2State createState() => _StatusDetailV2State();
}

class _StatusDetailV2State extends State<StatusDetailV2>
    with SingleTickerProviderStateMixin {
  StatusItemData status;
  List parent = [];
  List detail = [];
  String errorMsg;
  bool fetchedData = false;
  ResultListProvider provider; // fake provider

  _fetchData() async {
    var data =
        await StatusApi.getContext(data: widget.data, hostUrl: widget.hostUrl);
    detail.clear();
    fetchedData = true;
    if (data == null) return;
    if (data.containsKey('error')) {
      errorMsg = data['error'];
      setState(() {});
      return;
    }
    for (var d in data['ancestors']) {
      d['__sub'] = true;
      d['media_attachments'].forEach((e) => e['id'] = "c##" + e['id']);
      parent.insert(0, d);
    }
    // detail.add(status.toJson());
    for (var d in data['descendants']) {
      d['__sub'] = true;

      d['media_attachments'].forEach((e) => e['id'] = "c##" + e['id']);
      detail.add(d);
    }

    if (!mounted) {
      return;
    }

    setState(() {});
  }

  @override
  void initState() {
    //deep copy media attachments, fix hero
    var data = widget.data.toJson();
    status = StatusItemData.fromJson(Map.from(data));
    var copyAttachments = [];
    for (var m in data['media_attachments']) {
      copyAttachments.add(Map<String, dynamic>.from(m));
    }
    status.mediaAttachments = copyAttachments;
    status.mediaAttachments.forEach((e) {
      e['id'] = "c##" + e['id'];
    });

    //  detail = [status.toJson()];
    provider = ResultListProvider(requestUrl: null, buildRow: null);
    SettingsProvider().statusDetailProviders.add(provider);
    _fetchData();
    super.initState();
  }

  @override
  void dispose() {
    SettingsProvider().statusDetailProviders.remove(provider);
    super.dispose();
  }

  Widget _buildParentRow(BuildContext context, int idx) {
    Map row = parent[idx];
    return StatusItem(
      lineDivider: true,
      item: StatusItemData.fromJson(row),
      subStatus: true,
      primary: false,
      topLine: idx != parent.length - 1,
      bottomLine: true,
    );
  }

  Widget _buildChildRow(BuildContext context, int idx) {
    Map row = detail[idx];
    var status = StatusItemData.fromJson(row);
    bool topline = idx != 0 && status.inReplyToId == detail[idx - 1]['id'];
    bool bottomLine = idx != detail.length - 1 &&
        detail[idx + 1]['in_reply_to_id'] == status.id;
    return StatusItem(
      lineDivider: true,
      item: StatusItemData.fromJson(row),
      subStatus: true,
      primary: false,
      topLine: topline,
      bottomLine: bottomLine,
    );
  }

  Widget _buildStatusItem(StatusItemData data, {bool subStatus, bool primary}) {
    return StatusItem(
      lineDivider: true,
      item: data,
      subStatus: subStatus,
      primary: primary,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Key centerKey = ValueKey('second-sliver-list');
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(S.of(context).toot_information),
        toolbarHeight: 45,
      ),
      body: errorMsg != null
          ? Center(
              child: Text(errorMsg == 'Record not found'
                  ? S.of(context).toot_not_found
                  : errorMsg))
          : Column(
              //  alignment: AlignmentDirectional.bottomEnd,
              children: [
                Expanded(
                  child: Scrollbar(
                    child: CustomScrollView(
                      physics: ClampingScrollPhysics(),
                      center: centerKey,
                      slivers: [
                        SliverList(
                          delegate: SliverChildBuilderDelegate(_buildParentRow,
                              childCount: parent.length),
                        ),
                        SliverToBoxAdapter(
                          key: centerKey,
                          child: Column(
                            children: [
                              StatusItem(
                                item: status,
                                primary: true,
                                subStatus: false,
                                lineDivider: true,
                                topLine: status.inReplyToId != null,
                              ),
                              Container(
                                color: Theme.of(context).primaryColor,
                                padding: EdgeInsets.only(left: 15),
                                child: Row(
                                  children: [
                                    if (status.repliesCount != 0)
                                      TextInkWell(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 10, 10, 10),
                                        onTap: () {},
                                        activeColor:
                                            Theme.of(context).accentColor,
                                        text: S
                                            .of(context)
                                            .reply_count(status.repliesCount),
                                      ),
                                    if (status.reblogsCount != 0)
                                      TextInkWell(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 10, 10, 10),
                                          activeColor:
                                              Theme.of(context).accentColor,
                                          onTap: () => AppNavigate.push(
                                              BoostedBy(
                                                  widget.data, widget.hostUrl)),
                                          text: S.of(context).boost_count(
                                              status.reblogsCount)),
                                    if (status.favouritesCount != 0)
                                      TextInkWell(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 10, 10, 10),
                                          activeColor:
                                              Theme.of(context).accentColor,
                                          onTap: () => AppNavigate.push(
                                              FavoriteBy(
                                                  widget.data, widget.hostUrl)),
                                          text: I18nUtil.isZh(context)
                                              ? '${StringUtil.getZanString()} ' +
                                                  (widget.data.favouritesCount
                                                      .toString())
                                              : S.of(context).favorite_count(
                                                  widget.data.favouritesCount)),
                                  ],
                                ),
                              ),
                              // Divider(height: 0.3,),
                              SizedBox(
                                height: 8,
                              )
                            ],
                          ),
                        ),
                        SliverList(
                            delegate: SliverChildBuilderDelegate(
                          _buildChildRow,
                          childCount: detail.length,
                        )),
                        if (!fetchedData)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: CupertinoActivityIndicator(),
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                ),
                MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                      textScaleFactor: ScreenUtil.scaleFromSetting(
                              SettingsProvider().get('text_scale')) +
                          0.1),
                  // fake result list provider
                  child: ChangeNotifierProvider<ResultListProvider>(
                    create: (context) => ResultListProvider(
                        requestUrl: widget.hostUrl ?? '',
                        buildRow: null,
                        firstRefresh: false),
                    child: Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).appBarTheme.color,
                            border: Border(
                                top: BorderSide(
                                    width: 0.5,
                                    color: Theme.of(context).dividerColor))),
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          //   color: Colors.red,
                          alignment: Alignment.topCenter,
                          child: StatusItemActionW(
                            status: widget.data,
                            subStatus: false,
                            showNum: false,
                          ),
                        )),
                  ),
                )
              ],
            ),
    );
  }
}
