import 'package:fastodon/api/accounts_api.dart';
import 'package:fastodon/constant/icon_font.dart';
import 'package:fastodon/models/json_serializable/owner_account.dart';
import 'package:fastodon/models/provider/result_list_provider.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/widget/common/list_row.dart';
import 'package:fastodon/widget/listview/provider_easyrefresh_listview.dart';
import 'package:fastodon/widget/status/status_item_account.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum BlockType { mute, block, hideDomain }

class CommonBlockList extends StatelessWidget {
  final BlockType type;

  CommonBlockList(this.type);

  Widget _buildMuteRow(int idx, List dynamic,ResultListProvider provider) {
    OwnerAccount account = OwnerAccount.fromJson(dynamic[idx]);
    return ListRow(
        child: Container(
            child: StatusItemAccount(
      account,
      action: IconButton(
        icon: Icon(IconFont.volumeUp),
        onPressed: () async{
          var res = await AccountsApi.unMute(account.id);
          if (res != null) {
            provider.removeByIdWithAnimation(account.id);
          }
        },
      ),
    )));
  }

  Widget _buildBlockRow(int idx, List dynamic,ResultListProvider provider) {
    OwnerAccount account = OwnerAccount.fromJson(dynamic[idx]);
    return ListRow(
        child: Container(
            child: StatusItemAccount(
              account,
              action: IconButton(
                icon: Icon(IconFont.clear),
                onPressed: () async{
                  var res = await AccountsApi.unBlock(account.id);
                  if (res != null) {
                    provider.removeByIdWithAnimation(account.id);
                  }
                },
              ),
            )));
  }

  Widget _buildBlockDomainRow(int idx, List dynamic,ResultListProvider provider) {
    return ListRow(
      child: Row(
        children: <Widget>[
          Text(dynamic[idx]),
          Spacer(),
          IconButton(icon: Icon(IconFont.volumeUp),
            onPressed: () async{
              var res = await AccountsApi.unBlockDomain(dynamic[idx]);
              if (res != null) {
                provider.removeByValueWithAnimation(dynamic[idx]);
              }
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
      body: ChangeNotifierProvider<ResultListProvider>(
          create: (context) => ResultListProvider(
            requestUrl: url,
            buildRow: buildRow,
            headerLinkPagination: true

          ),
        builder: (context, snapshot) {
          return ProviderEasyRefreshListView(
            useAnimatedList: true,
       //     triggerRefreshEvent: [refreshEvent],
          );
        }
      ),
    );
  }
}
