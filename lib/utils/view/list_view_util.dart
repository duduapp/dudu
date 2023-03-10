import 'package:dudu/l10n/l10n.dart';
import 'package:dudu/api/accounts_api.dart';
import 'package:dudu/api/status_api.dart';
import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/models/http/request_manager.dart';
import 'package:dudu/models/json_serializable/article_item.dart';
import 'package:dudu/models/json_serializable/notificate_item.dart';
import 'package:dudu/models/json_serializable/owner_account.dart';
import 'package:dudu/models/logined_user.dart';
import 'package:dudu/models/provider/result_list_provider.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/dialog_util.dart';
import 'package:dudu/utils/i18n_util.dart';
import 'package:dudu/utils/view/status_action_util.dart';
import 'package:dudu/widget/common/list_row.dart';
import 'package:dudu/widget/other/follow_cell.dart';
import 'package:dudu/widget/other/follow_request_cell.dart';
import 'package:dudu/widget/status/status_item.dart';
import 'package:dudu/widget/status/status_item_account.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart';
import 'package:provider/provider.dart';

import '../compute_util.dart';
import '../string_until.dart';

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
      return ListRow(
        child: StatusItemAccount(account),
        padding: 0,
      );
    };
  }

  static notificationRowFunction() {
    return (int index, List data, ResultListProvider provider) {
      return Builder(builder: (context) {
        var isZh = I18nUtil.isZh(context);
        NotificationItem item = NotificationItem.fromJson(data[index]);
        if (item.type == 'follow') {
          return FollowCell(
            item: item,
          );
        } else if (item.type == 'favourite') {
          return StatusItem(
            item: item.status,
            refIcon: isZh
                ? (SettingsProvider().get('zan_or_shoucang') == '0'
                    ? IconFont.thumbUp
                    : IconFont.favorite)
                : IconFont.favorite,
            refString: isZh
                ? ('${StringUtil.displayName(item.account)} ${SettingsProvider().get('zan_or_shoucang') == '0' ? '???' : S.of(context).favorites}???????????????')
                : S
                    .of(context)
                    .favorited_your_toot(StringUtil.displayName(item.account)),
            refAccount: item.account,
          );
        } else if (item.type == 'mention') {
          return StatusItem(
            item: item.status,
          );
        } else if (item.type == 'poll') {
          bool self = item.status.account == LoginedUser().account;
          return StatusItem(
            item: item.status,
            refIcon: IconFont.vote,
            refString: self ? S.of(context).poll_your_created_ended : S.of(context).poll_your_voted_ended,
          );
        } else if (item.type == 'reblog') {
          return StatusItem(
            item: item.status,
            refIcon: IconFont.reblog,
            refString: S.of(context).boot_your_tool(StringUtil.displayName(item.account)),
            refAccount: item.account,
          );
        } else if (item.type == 'follow_request') {
          return FollowRequestCell(
            item: item,
          );
        } else {
          return Container();
        }
      });
    };
  }

  static ResultListDataHandler dataHandlerPrefixIdFunction(String prefix) {
    return (data) {
      data.forEach((e) {
        if (e.containsKey('media_attachments'))
          e['media_attachments'].forEach((e) => e['id'] = prefix + e['id']);
      });
      return data;
    };
  }

  static deleteStatus({BuildContext context, StatusItemData status}) async {
    ResultListProvider provider;
    try {
      provider = Provider.of<ResultListProvider>(context, listen: false);
    } catch (e) {
      provider = SettingsProvider().statusDetailProviders.last;
    }
    if (provider.tag == 'conversation') {
      provider.removeWhere((e) => e['last_status']['id'] == status.id);
    } else {
      provider.removeByIdWithAnimation(status.id);
    }
    var res = await StatusApi.remove(status.id);
    if (res != null) {
      _removeStatusFromProviderByStatusId(status.id);
    }
    return res;
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
    var accountLocal =
        await StatusActionUtil.getAccountInLocal(context, status.account);
    if (accountLocal == null) return;
    var accountId = accountLocal.id;
    AccountsApi.block(accountId);

    provider.removeByIdWithAnimation(status.id);
    // ??????????????????????????????
    Future.delayed(Duration(seconds: 1), () {
      removeStatusFromProvider(accountId);
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
    var accountLocal =
        await StatusActionUtil.getAccountInLocal(context, status.account);
    if (accountLocal == null) return;
    var accountId = accountLocal.id;
    AccountsApi.mute(accountId);

    // if (res != null) {
    provider.removeByIdWithAnimation(status.id);

    // ??????????????????????????????
    await Future.delayed(Duration(seconds: 1), () {
      removeStatusFromProvider(accountId);
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
    return (e) =>
        e['id'] == data.id ||
        (e['reblog'] != null && e['reblog']['id'] == data.id);
  }

  static handleAllStatuses(handle(dynamic e), bool test(dynamic e)) {
    for (ResultListProvider provider in getRootProviders()) {
      if (provider != null)
        for (var row in provider.list.where(test)) {
          handle(row);
        }
    }

    // notification?????????status
    List notificationStatus = [];
    for (var row in SettingsProvider().notificationProvider.list) {
      if (row['status'] != null) {
        notificationStatus.add(row['status']);
      }
    }
    for (var row in notificationStatus.where(test)) {
      handle(row);
    }

    for (ResultListProvider provider
        in SettingsProvider().statusDetailProviders) {
      for (var row in provider.list.where(test)) {
        handle(row);
      }
    }
  }

  static removeStatusFromProvider(String accountId) {
    for (ResultListProvider provider
        in SettingsProvider().statusDetailProviders) {
      provider
          .removeWhere((e) => e.isNotEmpty && e['account']['id'] == accountId);
    }

    for (ResultListProvider provider in getRootProviders()) {
      provider.removeWhere((e) =>
          (e.containsKey('reblog') &&
              e['reblog'] != null &&
              e['reblog'].containsKey('account') &&
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
      provider?.removeWhere((e) =>
          (e.containsKey('reblog') &&
              e['reblog'] != null &&
              e['reblog'].containsKey('id') &&
              e['reblog']['id'] == statusId) ||
          e['id'] == statusId ||
          (e.containsKey('status') &&
              e['status'] != null &&
              e['status']['id'] == statusId));
    }
  }

  static bool loginnedAndPrompt(BuildContext context) {
    if (LoginedUser().account == null ||
        LoginedUser().host.startsWith('https://help.dudu.today')) {
      DialogUtils.showSimpleAlertDialog(
          text: S.of(context).you_need_to_log_in_to_perform_this_operation,
          confirmText: S.of(context).go_to_login,
          onConfirm: () {
            AppNavigate.popToRoot();
          });
      return false;
    }
    return true;
  }
}
