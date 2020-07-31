import 'package:fastodon/api/accounts_api.dart';
import 'package:fastodon/api/status_api.dart';
import 'package:fastodon/constant/event_bus_key.dart';
import 'package:fastodon/models/json_serializable/article_item.dart';
import 'package:fastodon/models/json_serializable/owner_account.dart';
import 'package:fastodon/models/provider/result_list_provider.dart';
import 'package:fastodon/models/provider/settings_provider.dart';
import 'package:fastodon/widget/common/list_row.dart';
import 'package:fastodon/widget/status/status_item.dart';
import 'package:fastodon/widget/status/status_item_account.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:provider/provider.dart';

import 'event_bus.dart';

class ListViewUtil {
  static Header getDefaultHeader(BuildContext context) {
    return ClassicalHeader(
        refreshText: '下拉刷新',
        refreshReadyText: '释放刷新',
        refreshingText: '加载中...',
        refreshedText: '',
        refreshFailedText: '刷新失败',
        noMoreText: '没有更多数据',
        infoText: '更新于 %T',
        textColor: Theme.of(context).accentColor);
  }

  static getDefaultFooter(BuildContext context) {
    return ClassicalFooter(
      showInfo: false,
      enableInfiniteLoad: true,
      loadText: '拉动加载',
      loadReadyText: '释放加载',
      loadingText: '加载中...',
      loadedText: '',
      loadFailedText: '加载失败',
      noMoreText: '',
      infoText: '',
    );
  }

  static statusRowFunction() {
    return (int index, List data, ResultListProvider provider) {
      StatusItemData lineItem = StatusItemData.fromJson(data[index]);
      return StatusItem(item: lineItem);
    };
  }

  static accountRowFunction() {
    return (int index, List data, ResultListProvider provider) {
      OwnerAccount account = OwnerAccount.fromJson(data[index]);
      return ListRow(child: StatusItemAccount(account));
    };
  }

  static ResultListDataHandler dataHandlerPrefixIdFunction(String prefix) {
    return (data) {
      data.forEach((e) => e['media_attachments'].forEach((e) => e['id'] = prefix+e['id']));
      return data;
    };
  }

  static removeStatus({BuildContext context,StatusItemData status}) {
    var provider = Provider.of<ResultListProvider>(context, listen: false);
    provider.removeByIdWithAnimation(status.id);
    StatusApi.remove(status.id);
  }

  static blockUser({BuildContext context,StatusItemData status}) async{
    var provider = Provider.of<ResultListProvider>(context, listen: false);
    var res = await AccountsApi.block(status.account.id);

    var statusId = status.id;
    var accountId = status.account.id;
    if (res != null) {
      provider.removeByIdWithAnimation(status.id);
      // 防止和上面的语句冲突
      Future.delayed(Duration(seconds: 2), () {
        eventBus.emit(EventBusKey.blockAccount,
            {'account_id': accountId, 'from_status_id': statusId});
      });
    }
  }

  static muteUser({BuildContext context,StatusItemData status}) async{
    ResultListProvider provider;
    if (context == null) {
      provider = SettingsProvider().statusDetailProviders.last;
      if (provider == null)
        return;
    } else {
      provider = Provider.of<ResultListProvider>(context, listen: false);
    }
    var res = await AccountsApi.mute(status.account.id);

    var statusId = status.id;
    var accountId = status.account.id;
    if (res != null) {
      provider.removeByIdWithAnimation(status.id);
      for (ResultListProvider provider in SettingsProvider().statusDetailProviders) {
        provider.removeWhere((e) => e.isNotEmpty && e['account']['id'] == status.account.id);
      }
      // 防止和上面的语句冲突
      Future.delayed(Duration(seconds: 1), () {
        eventBus.emit(EventBusKey.muteAccount,
            {'account_id': accountId, 'from_status_id': statusId});
      });
    }
  }
}
