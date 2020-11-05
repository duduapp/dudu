import 'package:dudu/api/notification_api.dart';
import 'package:dudu/api/timeline_api.dart';
import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/models/json_serializable/notificate_item.dart';
import 'package:dudu/models/logined_user.dart';
import 'package:dudu/models/provider/result_list_provider.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/pages/timeline/notification_display_type_dialog.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/dialog_util.dart';
import 'package:dudu/widget/listview/provider_easyrefresh_listview.dart';
import 'package:dudu/widget/other/follow_request_cell.dart';
import 'package:dudu/widget/status/status_item.dart';
import 'package:dudu/widget/timeline/account_switch_timeline.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../widget/other/follow_cell.dart';

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications>
    with AutomaticKeepAliveClientMixin {
    ResultListProvider provider;
    RefreshController refreshController = RefreshController();


  List displayType;

  @override
  bool get wantKeepAlive => false;

  Function loginSuccess;
  @override
  void initState() {
    displayType = SettingsProvider().settings['notification_display_type'];
    // parameters will be added in build method
    provider = ResultListProvider(
        requestUrl: Request.buildGetUrl(TimelineApi.notification, getRequestParams(displayType)),
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
          refIcon: IconFont.thumbUp,
          refString: '${StringUtil.displayName(item.account)} 收藏了你的嘟文',
          refAccount: item.account,);
    } else if (item.type == 'mention') {
      return StatusItem(
        item: item.status,
      );
    } else if (item.type == 'poll') {
      bool self = item.status.account == LoginedUser().account;
      return StatusItem(
        item: item.status,
        refIcon: IconFont.vote,
        refString: '你${self ? '创建' : '参与'}的投票已结束',
      );
    } else if (item.type == 'reblog') {
      return StatusItem(
        item: item.status,
        refIcon: IconFont.reblog,
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
    return AccountSwitchTimeline(
      provider: provider,
      title: '消息',
      listView: ProviderEasyRefreshListView(
        refreshController: refreshController,
      ),
      actions: [
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
                DialogUtils.showSimpleAlertDialog(context: context,text: '你确定要永远删除消息列表吗',onConfirm: _clearNotification);
                break;
              case 'choose_type':
                showChooseTypeDialog();
                break;
            }
          },
        )
      ],
    );

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
          TimelineApi.notification, getRequestParams(newDisplayType));
      provider.refresh();
    }
  }
}
