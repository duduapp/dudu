import 'package:fastodon/api/accounts_api.dart';
import 'package:fastodon/models/owner_account.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/widget/common/list_row.dart';
import 'package:fastodon/widget/listview/easyrefresh_listview.dart';
import 'package:fastodon/widget/status/status_item_account.dart';
import 'package:flutter/material.dart';

enum BlockType { mute, block, hideDomain }

class CommonBlockList extends StatelessWidget {
  final BlockType type;

  CommonBlockList(this.type);

  Widget _buildMuteRow(int idx, List dynamic) {
    OwnerAccount account = OwnerAccount.fromJson(dynamic[idx]);
    return ListRow(
        child: Container(
            child: StatusItemAccount(
      account,
      action: IconButton(
        icon: Icon(Icons.volume_up),
        onPressed: () async{
          await AccountsApi.unMute(account.id);
          eventBus.emit(EventBusKey.userUnmuted);
        },
      ),
    )));
  }

  Widget _buildBlockRow(int idx, List dynamic) {
    OwnerAccount account = OwnerAccount.fromJson(dynamic[idx]);
    return ListRow(
        child: Container(
            child: StatusItemAccount(
              account,
              action: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () async{
                  await AccountsApi.unBlock(account.id);
                  eventBus.emit(EventBusKey.userUnblocked);
                },
              ),
            )));
  }

  Widget _buildBlockDomainRow(int idx, List dynamic) {
    return ListRow(
      child: Row(
        children: <Widget>[
          Text(dynamic[idx]),
          Spacer(),
          IconButton(icon: Icon(Icons.volume_up),
            onPressed: () async{
              await AccountsApi.unBlockDomain(dynamic[idx]);
              eventBus.emit(EventBusKey.domainUnblocked);
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var title;
    var url;
    Function buildRow;
    var refreshEvent;
    switch (type) {
      case BlockType.mute:
        title = '被隐藏的用户';
        url = AccountsApi.muteUrl;
        buildRow = _buildMuteRow;
        refreshEvent = EventBusKey.userUnmuted;
        break;
      case BlockType.block:
        title = '被屏蔽的用户';
        url = AccountsApi.blockUrl;
        buildRow = _buildBlockRow;
        refreshEvent = EventBusKey.userUnblocked;
        break;
      case BlockType.hideDomain:
        title = '隐藏域名';
        url = AccountsApi.blockDomainUrl;
        buildRow = _buildBlockDomainRow;
        refreshEvent = EventBusKey.domainUnblocked;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: false,
      ),
      body: EasyRefreshListView(
        requestUrl: url,
        buildRow: buildRow,
        triggerRefreshEvent: [refreshEvent],
      ),
    );
  }
}
