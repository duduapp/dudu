import 'package:dudu/l10n/l10n.dart';
import 'package:dudu/api/accounts_api.dart';
import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/models/json_serializable/owner_account.dart';
import 'package:dudu/models/provider/result_list_provider.dart';
import 'package:dudu/public.dart';
import 'package:dudu/widget/common/custom_app_bar.dart';
import 'package:dudu/widget/common/list_row.dart';
import 'package:dudu/widget/listview/provider_easyrefresh_listview.dart';
import 'package:dudu/widget/status/status_item_account.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum BlockType { mute, block, hideDomain }

class CommonBlockList extends StatelessWidget {
  final BlockType type;

  CommonBlockList(this.type);

  Widget _buildMuteRow(int idx, List dynamic,ResultListProvider provider) {
    OwnerAccount account = OwnerAccount.fromJson(dynamic[idx]);
    return ListRow(
      padding: 0,
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
        padding: 0,
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
      padding: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 0, 4),
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
        title = S.of(context).hidden_user;
        url = AccountsApi.muteUrl;
        buildRow = _buildMuteRow;
        refreshEvent = EventBusKey.userUnmuted;
        break;
      case BlockType.block:
        title = S.of(context).blocked_user;
        url = AccountsApi.blockUrl;
        buildRow = _buildBlockRow;
        refreshEvent = EventBusKey.userUnblocked;
        break;
      case BlockType.hideDomain:
        title = S.of(context).hidden_instance;
        url = AccountsApi.blockDomainUrl;
        buildRow = _buildBlockDomainRow;
        refreshEvent = EventBusKey.domainUnblocked;
        break;
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(title),
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
