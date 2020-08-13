import 'dart:developer';

import 'package:fastodon/api/notification_api.dart';
import 'package:fastodon/models/json_serializable/notificate_item.dart';
import 'package:fastodon/models/logined_user.dart';
import 'package:fastodon/models/provider/result_list_provider.dart';
import 'package:fastodon/models/provider/settings_provider.dart';
import 'package:fastodon/pages/timeline/notification_display_type_dialog.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/utils/dialog_util.dart';
import 'package:fastodon/widget/listview/provider_easyrefresh_listview.dart';
import 'package:fastodon/widget/other/follow_request_cell.dart';
import 'package:fastodon/widget/status/status_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../widget/other/follow_cell.dart';

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications>
    with AutomaticKeepAliveClientMixin {
    ResultListProvider provider;
    RefreshController refreshController = RefreshController(initialRefresh: false);


  List displayType;

  @override
  bool get wantKeepAlive => false;

  Function loginSuccess;
  @override
  void initState() {
    displayType = SettingsProvider().settings['notification_display_type'];
    // parameters will be added in build method
    provider = ResultListProvider(
        requestUrl: Request.buildGetUrl(Api.Notifications, getRequestParams(displayType)),
        buildRow: row,
      tag: 'notifications'
    );
    provider.refreshController = refreshController;
    SettingsProvider().notificationProvider = provider;
        super.initState();
    loginSuccess = (arg) {
    };

    eventBus.on(EventBusKey.LoadLoginMegSuccess, loginSuccess);
  }

  Map getRequestParams(List displayType) {
    var notificationTypes = ['follow', 'favourite', 'reblog', 'mention', 'poll', 'follow_request'];
    notificationTypes.removeWhere((element) => displayType.contains(element));
    return {'exclude_types':notificationTypes};
  }

  @override
  void dispose() {
    eventBus.off(EventBusKey.LoadLoginMegSuccess, loginSuccess);
    super.dispose();
  }

  Widget row(int index, List data, ResultListProvider provider) {
    NotificationItem item = NotificationItem.fromJson(data[index]);
    if (item.type == 'follow') {
      return FollowCell(
        item: item,
      );
    } else if (item.type == 'favourite') {
      return StatusItem(
          item: item.status,
          refIcon: Icons.thumb_up,
          refString: '${StringUtil.displayName(item.account)} 赞了你的嘟文',
          refAccount: item.account,);
    } else if (item.type == 'mention') {
      return StatusItem(
        item: item.status,
      );
    } else if (item.type == 'poll') {
      bool self = item.status.account == LoginedUser().account;
      return StatusItem(
        item: item.status,
        refIcon: Icons.poll,
        refString: '你${self ? '创建' : '参与'}的投票已结束',
      );
    } else if (item.type == 'reblog') {
      return StatusItem(
        item: item.status,
        refIcon: Icons.repeat,
        refString: '${StringUtil.displayName(item.account)} 转嘟了你的嘟文',
        refAccount: item.account,
      );
    } else if (item.type == 'follow_request') {
      return FollowRequestCell(item: item,);
    }else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
        appBar: AppBar(
          title: Text('通知'),
          centerTitle: true,
          actions: <Widget>[
            PopupMenuButton(
              offset: Offset(0, 45),
              icon: Icon(Icons.more_vert),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(value: 'clear', child: new Text('清空')),
                PopupMenuItem<String>(
                    value: 'choose_type', child: new Text('分类'))
              ],
              onSelected: (String value) {
                switch (value) {
                  case 'clear':
                    DialogUtils.showSimpleAlertDialog(context: context,text: '你确定要永远删除通知列表吗',onConfirm: _clearNotification);
                    break;
                  case 'choose_type':
                    showChooseTypeDialog();
                    break;
                }
              },
            )
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ChangeNotifierProvider<ResultListProvider>.value(
                value: provider,
                child: ProviderEasyRefreshListView(
                  refreshController: refreshController,
                ),
              ),
            )
          ],
        ));
  }

  _clearNotification() async{
    await NotificationApi.clear();
    provider.clearData();
  }

  showChooseTypeDialog() async{
    var newDisplayType = await DialogUtils.showRoundedDialog(
        context: context,
        content: NotificationDisplayTypeDialog());
    if (newDisplayType != null) {
      provider.requestUrl = Request.buildGetUrl(
          Api.Notifications, getRequestParams(newDisplayType));
      provider.refresh();
    }
  }
}
