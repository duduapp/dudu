import 'package:fastodon/models/json_serializable/notificate_item.dart';
import 'package:fastodon/models/provider/result_list_provider.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/widget/listview/provider_easyrefresh_listview.dart';
import 'package:fastodon/widget/status/status_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../../widget/other/follow_cell.dart';

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> with AutomaticKeepAliveClientMixin {
  bool _canLoadWidget = false;
  @override
  bool get wantKeepAlive => true;

  Function loginSuccess;
  @override
  void initState() {
    super.initState();
    loginSuccess = (arg) {
      setState(() {
        _canLoadWidget = true;
      });
    };

    eventBus.on(EventBusKey.LoadLoginMegSuccess, loginSuccess);
  }

  @override
  void dispose() {
    eventBus.off(EventBusKey.LoadLoginMegSuccess,loginSuccess);
    super.dispose();
  }

  Widget row(int index, List data,ResultListProvider provider) {
    NotificateItem item = NotificateItem.fromJson(data[index]);
    if (item.type == 'follow') {
      return FollowCell(
        item: item,
      );
    } else if (item.type == 'favourite') {
      return StatusItem(item: item.status,refIcon: Icons.star, refString:'${StringUtil.displayName(item.account)}收藏了你的嘟文');
    } else if (item.type == 'mention') {
      return StatusItem(
        item: item.status,
      );
    } else if (item.type == 'poll') {
      return StatusItem(item: item.status,refIcon: Icons.poll,refString: '你创建的投票已结束',);

    } else if (item.type == 'reblog') {
      return StatusItem(item: item.status,refIcon: Icons.repeat,refString: '${StringUtil.displayName(item.account)}转嘟了你的嘟文',);
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('通知'),
        centerTitle: true,
      ),
      body: LoadingWidget(
        endLoading: _canLoadWidget,
        childWidget: ChangeNotifierProvider<ResultListProvider>(
          create: (context) => ResultListProvider(
              requestUrl: Api.Notifications,
              buildRow: row,

          ),
          child: ProviderEasyRefreshListView(
          ),
        ),
      )
    );
  }
}