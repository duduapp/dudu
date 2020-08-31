import 'package:dudu/api/accounts_api.dart';
import 'package:dudu/api/status_api.dart';
import 'package:dudu/models/json_serializable/article_item.dart';
import 'package:dudu/models/json_serializable/owner_account.dart';
import 'package:dudu/models/provider/result_list_provider.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/widget/common/list_row.dart';
import 'package:dudu/widget/status/status_item.dart';
import 'package:dudu/widget/status/status_item_account.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListViewUtil {
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
      data.forEach((e) =>
          e['media_attachments'].forEach((e) => e['id'] = prefix + e['id']));
      return data;
    };
  }

  static deleteStatus({BuildContext context, StatusItemData status}) async{
    var provider = Provider.of<ResultListProvider>(context, listen: false);
    if (provider.tag == 'conversation') {
      provider.removeWhere((e) => e['last_status']['id'] == status.id);
    } else {
      provider.removeByIdWithAnimation(status.id);
    }
    var res = await StatusApi.remove(status.id);
    if (res != null) {
      Future.delayed(Duration(seconds: 1), () {
        _removeStatusFromProviderByStatusId(status.id);
      });
    }
  }

  static blockUser({BuildContext context, StatusItemData status}) async {
    ResultListProvider provider;
    if (context == null) {
      provider = SettingsProvider().statusDetailProviders.last;
      if (provider == null) return;
    } else {
      try {
        provider = Provider.of<ResultListProvider>(context, listen: false);
      } catch (e) {
        provider = SettingsProvider().statusDetailProviders.last;
      }
    }
    var accountId = status.account.id;
    AccountsApi.block(accountId);


    provider.removeByIdWithAnimation(status.id);
    // 防止和上面的语句冲突
    Future.delayed(Duration(seconds: 1), () {
      _removeStatusFromProvider(accountId);
    });

  }

  static muteUser({BuildContext context, StatusItemData status}) async {
    ResultListProvider provider;
    if (context == null) {
      provider = SettingsProvider().statusDetailProviders.last;
      if (provider == null) return;
    } else {
      try {
        provider = Provider.of<ResultListProvider>(context, listen: false);
      } catch (e) {
        provider = SettingsProvider().statusDetailProviders.last;
      }
    }
    var accountId = status.account.id;
    AccountsApi.mute(accountId);

   // if (res != null) {
      provider.removeByIdWithAnimation(status.id);

      // 防止和上面的语句冲突
      await Future.delayed(Duration(seconds: 1), () {
        _removeStatusFromProvider(accountId);
      });
   // }
  }

  static reblogStatusInAllProvider(StatusItemData data) {
    handleAllStatuses((e) {
      e['reblogged'] = true;
      e['reblogs_count'] = e['reblogs_count'] + 1;
    }, sameStatusCondition(data));
  }

  static unreblogStatusInAllProvider(StatusItemData data) {
    handleAllStatuses((e) {
      e['reblogged'] = false;
      e['reblogs_count'] = e['reblogs_count'] - 1;
    }, sameStatusCondition(data));
  }

  static favouriteStatusInAllProvider(StatusItemData data) {
    handleAllStatuses((e) {
      e['favourited'] = true;
      e['favourites_count'] = e['favourites_count'] + 1;
    }, sameStatusCondition(data));
  }

  static unfavouriteStatusInAllProvider(StatusItemData data) {
    handleAllStatuses((e) {
      e['favourited'] = false;
      e['favourites_count'] = e['favourites_count'] - 1;
    }, sameStatusCondition(data));
  }

  static sameStatusCondition(StatusItemData data) {
    return (e) => e['id'] == data.id || (e['reblog'] != null && e['reblog']['id'] == data.id);
  }

  static handleAllStatuses(handle(dynamic e),bool test(dynamic e)) {
    for (ResultListProvider provider in getRootProviders()) {
      for (var row in provider.list.where(test)){
          handle(row);
      }
    }

    // notification会包裹status
    List notificationStatus = [];
    for (var row in SettingsProvider().notificationProvider.list) {
      if (row['status'] != null) {
        notificationStatus.add(row['status']);
      }
    }
    for (var row in notificationStatus.where(test)) {
      handle(row);
    }

    for (ResultListProvider provider in SettingsProvider().statusDetailProviders) {
      for (var row in provider.list.where(test)){
        handle(row);
      }
    }
  }

  static _removeStatusFromProvider(String accountId) {
    for (ResultListProvider provider
    in SettingsProvider().statusDetailProviders) {
      provider.removeWhere(
              (e) => e.isNotEmpty && e['account']['id'] == accountId);
    }

    for (ResultListProvider provider in getRootProviders()) {
      provider.removeWhere((e) =>
          (e.containsKey('reblog') && e['reblog'] != null && e['reblog'].containsKey('account') &&
              e['reblog']['account']['id'] == accountId) ||
          e['account']['id'] == accountId);
    }
  }

  static List getRootProviders() {
    return [
      SettingsProvider().localProvider,
      SettingsProvider().homeProvider,
      SettingsProvider().federatedProvider,
    //  SettingsProvider().notificationProvider
    ];
  }

  static _removeStatusFromProviderByStatusId(String statusId) {
    for (ResultListProvider provider in [
      SettingsProvider().localProvider,
      SettingsProvider().homeProvider,
      SettingsProvider().federatedProvider,
      SettingsProvider().notificationProvider
    ]) {
      provider.removeWhere((e) =>
      (e.containsKey('reblog') && e['reblog'] != null && e['reblog'].containsKey('id') &&
          e['reblog']['id'] == statusId) ||
          e['id'] == statusId);
    }
  }
}
