import 'dart:io';

import 'package:dudu/api/accounts_api.dart';
import 'package:dudu/api/search_api.dart';
import 'package:dudu/api/status_api.dart';
import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/l10n/l10n.dart';
import 'package:dudu/models/json_serializable/article_item.dart';
import 'package:dudu/models/json_serializable/owner_account.dart';
import 'package:dudu/models/logined_user.dart';
import 'package:dudu/models/provider/result_list_provider.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/pages/admin/account_action_dialog.dart';
import 'package:dudu/pages/discovery/add_instance.dart';
import 'package:dudu/pages/status/new_status.dart';
import 'package:dudu/pages/user_profile/user_report.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/account_util.dart';
import 'package:dudu/utils/dialog_util.dart';
import 'package:dudu/widget/common/bottom_sheet_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nav_router/nav_router.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import 'list_view_util.dart';

class StatusActionUtil {
  static Future<bool> reblog(
      bool isLiked, StatusItemData status, BuildContext context) async {
    status = await getStatusInLocal(context, status);
    if (status == null) return false;

    status.reblogged = !isLiked;
    status.reblogsCount = status.reblogsCount + (!isLiked ? 1 : -1);

    ResultListProvider provider;
    try {
      provider = Provider.of<ResultListProvider>(context, listen: false);
    } catch (e) {}
    if (provider != null)
      provider.list.forEach((element) {
        if (element['id'] == status.id) {
          element['reblogged'] = !isLiked;
          element['reblogs_count'] =
              element['reblogs_count'] + (!isLiked ? 1 : -1);
        }

        // handle reblog status
        if ((element.containsKey('reblog') &&
            element['reblog'] != null &&
            element['reblog']['id'] == status.id)) {
          element['reblog']['reblogged'] = !isLiked;
          element['reblog']['reblogs_count'] =
              element['reblogs_count'] + (!isLiked ? 1 : -1);
        }
      });
    if (isLiked) {
      ListViewUtil.unreblogStatusInAllProvider(status);
      var res = await StatusApi.unReblog(status.id);
      if (res != null) {
        changeStatusCount(-1);
      }
    } else {
      ListViewUtil.reblogStatusInAllProvider(status);
      var res = StatusApi.reblog(status.id);
      if (res != null) {
        changeStatusCount(1);
      }
    }

    return !isLiked;
  }

  static changeStatusCount([int change = 1]) {
    var count = LoginedUser().account.statusesCount;
    if (count + change >= 0) {
      LoginedUser().account.statusesCount = count + change;
    }
  }

  static changeFollowingCount([int change = 1]) {
    var count = LoginedUser().account.followingCount;
    if (count + change >= 0) {
      LoginedUser().account.followingCount = count + change;
    }
  }

  static Future<bool> favourite(
      bool isLiked, StatusItemData status, BuildContext context) async {
    status = await getStatusInLocal(context, status);
    if (status == null) return false;

    status.favourited = !isLiked;
    status.favouritesCount = status.favouritesCount + (!isLiked ? 1 : -1);

    ResultListProvider provider;
    try {
      provider = Provider.of<ResultListProvider>(context, listen: false);
    } catch (e) {}
    if (provider != null) {
      provider.list.forEach((element) {
        if (element['id'] == status.id) {
          element['favourited'] = !isLiked;
          element['favourites_count'] =
              element['favourites_count'] + (!isLiked ? 1 : -1);
        }
        if ((element.containsKey('reblog') &&
            element['reblog'] != null &&
            element['reblog']['id'] == status.id)) {
          element['reblog']['favourited'] = !isLiked;
          element['reblog']['favourites_count'] =
              element['reblogs_count'] + (!isLiked ? 1 : -1);
        }
      });
    }
    if (isLiked) {
      StatusApi.unfavourite(status.id);
      ListViewUtil.unfavouriteStatusInAllProvider(status);
    } else {
      StatusApi.favourite(status.id);
      ListViewUtil.favouriteStatusInAllProvider(status);
    }
    return !isLiked;
  }

  static updateStatusVote(
      StatusItemData status, dynamic pollJson, BuildContext context) {
    status.poll = Poll.fromJson(pollJson);
    ResultListProvider provider =
        Provider.of<ResultListProvider>(context, listen: false);
    provider.list.forEach((element) {
      if (element['id'] == status.id) {
        element['poll'] = pollJson;
      }
      if ((element.containsKey('reblog') &&
          element['reblog'] != null &&
          element['reblog']['id'] == status.id)) {
        element['reblog']['poll'] = pollJson;
      }
    });
    provider.notify();
    ListViewUtil.handleAllStatuses((e) {
      e['poll'] = pollJson;
    }, ListViewUtil.sameStatusCondition(status));
  }

  static showAdminAccountActionDialog(
      BuildContext context, StatusItemData data) {
    DialogUtils.showRoundedDialog(
        context: context, content: AccountActionDialog(data.account));
  }

  static showBottomSheetAction(
      BuildContext context, StatusItemData data, bool subStatus) {
    OwnerAccount myAccount = LoginedUser().account;
    BuildContext modalContext = context;

    bool mentioned = false;
    for (var row in data.mentions) {
      if (row['acct'] == myAccount.acct) {
        mentioned = true;
      }
    }

    ResultListProvider provider;
    try {
      provider = Provider.of<ResultListProvider>(context, listen: false);
    } catch (e) {}

    DialogUtils.showBottomSheet(context: modalContext, widgets: [
      BottomSheetItem(
        icon: IconFont.bookmark,
        text: (data.bookmarked == null || !data.bookmarked)
            ? S.of(context).add_bookmark
            : S.of(context).delete_bookmark,
        onTap: () => onPressBookmark(modalContext, data),
      ),
      Divider(indent: 60, height: 0),
      if (mentioned) ...[
        BottomSheetItem(
          icon: IconFont.volumeOff,
          text: (data.muted == null || !data.muted)
              ? S.of(context).hide_this_conversation
              : S.of(context).unhide_the_conversation,
          subText: S.of(context).after_hiding,
          onTap: () {
            _onPressMuteConversation(data);
          },
        ),
        Divider(indent: 60, height: 0),
      ],
      BottomSheetItem(
        icon: IconFont.link,
        text: S.of(context).share_link,
        onTap: () {
          Share.share(data.url);
        },
      ),
      Divider(indent: 60, height: 0),
      BottomSheetItem(
        icon: IconFont.copy,
        text: S.of(context).share_toot,
        onTap: () {
          Share.share(StringUtil.removeAllHtmlTags(data.content));
        },
      ),
      if (Platform.isAndroid) ...[
        Divider(indent: 60, height: 0),
        BottomSheetItem(
          icon: IconFont.copy,
          text: S.of(context).copy_the_beep,
          onTap: () {
            Clipboard.setData(new ClipboardData(
                text: StringUtil.removeAllHtmlTags(data.content)));
            DialogUtils.toastFinishedInfo(
                S.of(context).dumb_text_has_been_copied);
          },
        )
      ],
      if (myAccount != null && myAccount.id != data.account.id) ...[
        if (sameInstance(context)) ...[
          Divider(indent: 60, height: 0),
          BottomSheetItem(
            icon: IconFont.report,
            text: S.of(context).complaint,
            onTap: () async {
              var accountLocal =
                  await getAccountInLocal(modalContext, data.account);
              if (accountLocal == null) return;
              AppNavigate.push(UserReport(
                account: accountLocal,
                fromStatusId: data.id,
              ));
            },
          ),
          Divider(indent: 60, height: 0),
          BottomSheetItem(
            icon: IconFont.follow,
            text: S.of(context).follow_user('@' + data.account.acct),
            onTap: () async {
              var res = await AccountsApi.follow(data.account.id);
              if (res != null)
                DialogUtils.toastFinishedInfo(
                    S.of(context).followed_or_sent_a_follow_request);
            },
          )
        ],
        Divider(
          indent: 60,
          height: 0,
        ),
        BottomSheetItem(
          icon: IconFont.volumeOff,
          text: S.of(context).hide_user(data.account.username),
          subText: S.of(context).hiding_description,
          onTap: () {
            DialogUtils.showSimpleAlertDialog(
                context: context,
                text: S
                    .of(context)
                    .are_you_sure_to_hide_users('@' + data.account.username),
                onConfirm: () => _onPressMute(modalContext, data, subStatus));
          },
        ),
        Divider(indent: 60, height: 0),
        BottomSheetItem(
          onTap: () {
            DialogUtils.showSimpleAlertDialog(
                context: context,
                text: S
                    .of(context)
                    .are_you_sure_to_block_users('@' + data.account.username),
                onConfirm: () => _onPressBlock(modalContext, data, subStatus));
          },
          icon: IconFont.block,
          text: S.of(context).block_user('@' + data.account.username),
          subText: S.of(context).blocking_description,
        ),
        if (data.account.acct.contains('@')) ...[
          Divider(indent: 60, height: 0),
          BottomSheetItem(
            icon: IconFont.www,
            text: S
                .of(context)
                .hide_instance(StringUtil.accountDomain(data.account)),
            subText: S.of(context).hiding_instance_description,
            onTap: () => DialogUtils.showSimpleAlertDialog(
                context: context,
                text: S.of(context).hide_instance_confirm(
                    StringUtil.accountDomain(data.account)),
                onConfirm: () {
                  AccountsApi.blockDomain(
                      StringUtil.accountDomain(data.account));
                },
                popFirst: false),
          ),
          Divider(indent: 60, height: 0),
          BottomSheetItem(
            icon: IconFont.favorite,
            text: S
                .of(context)
                .collection_example(StringUtil.accountDomain(data.account)),
            subText:
                S.of(context).the_instance_will_be_saved_in_your_discover_menu,
            onTap: () async {
              var res = await DialogUtils.showRoundedDialog(
                  context: context,
                  content: AddInstance(StringUtil.accountDomain(data.account)));
              if (res != null) {
                DialogUtils.toastFinishedInfo(
                    S.of(context).added_instance_successfully);
              }
            },
          ),
          Divider(
            indent: 60,
            height: 0,
          )
        ],
        if (LoginedUser().isAdmin &&
            data.account.url.contains(LoginedUser().host))
          BottomSheetItem(
            onTap: () {
              showAdminAccountActionDialog(context, data);
            },
            icon: IconFont.block,
            text: S.of(context).administrator_operate_the_account,
          ),
      ],
      if (myAccount != null && myAccount.id == data.account.id) ...[
        if (data.visibility == 'public' || data.visibility == 'unlisted')
          BottomSheetItem(
            icon: Icons.vertical_align_top,
            text: data.pinned == null || !data.pinned
                ? S.of(context).top
                : S.of(context).unpink,
            onTap: () => onPressPin(data),
          ),
        BottomSheetItem(
          icon: IconFont.delete,
          text: S.of(context).delete,
          color: Colors.red,
          onTap: () {
            DialogUtils.showSimpleAlertDialog(
                context: context,
                text: S.of(context).are_you_sure_you_want_to_delete_this_beep,
                onConfirm: () {
                  _onPressRemove(modalContext, data, subStatus);
                });
          },
        ),
        BottomSheetItem(
          icon: IconFont.edit,
          text: S.of(context).delete_and_re_edit,
          color: Colors.red,
          onTap: () {
            _onPressRemove(modalContext, data, subStatus);
            AppNavigate.push(NewStatus(
              scheduleInfo: data.toJson(),
            ));
          },
        )
      ],
      Container(
        height: 8,
        color: Theme.of(context).backgroundColor,
      ),
    ]);
  }

  static _onPressRemove(
      BuildContext context, StatusItemData data, bool subStatus) async {
    ResultListProvider provider;
    try {
      provider = Provider.of<ResultListProvider>(context, listen: false);
    } catch (e) {
      provider = SettingsProvider().statusDetailProviders.last;
    }
    if (SettingsProvider().statusDetailProviders.contains(provider)) {
      // user is in status detail page
      if (subStatus) {
        var res =
            await ListViewUtil.deleteStatus(context: context, status: data);
        if (res != null) {
          changeStatusCount(-1);
        }
      } else {
        AppNavigate.pop(param: {'operation': 'delete', 'status': data});
      }
    } else {
      var res = await ListViewUtil.deleteStatus(context: context, status: data);
      if (res != null) {
        changeStatusCount(-1);
      }
    }
//    var provider = Provider.of<ResultListProvider>(context, listen: false);
//    provider.removeByIdWithAnimation(widget.item.id);
//    StatusApi.remove(widget.item.id);
  }

  static onPressBookmark(BuildContext context, StatusItemData data) async {
    data = await getStatusInLocal(context, data);
    if (data == null) {
      //DialogUtils.toastFinishedInfo(S.of(context).failed_to_add_bookmark);
      return;
    }
    if (!data.bookmarked) {
      StatusApi.bookmark(data.id);
      DialogUtils.toastFinishedInfo(S.of(context).bookmarked);
    } else {
      StatusApi.unBookmark(data.id);
      DialogUtils.toastFinishedInfo(S.of(context).bookmark_deleted);
    }
    data.bookmarked = !data.bookmarked;
    ListViewUtil.handleAllStatuses((e) => e['bookmarked'] = data.bookmarked,
        ListViewUtil.sameStatusCondition(data));
  }

  static onPressPin(StatusItemData data) {
    if (data.pinned != null && data.pinned) {
      StatusApi.unpin(data.id);
      DialogUtils.toastFinishedInfo(
          S.of(navGK.currentState.overlay.context).unpinned);
    } else {
      StatusApi.pin(data.id);
      DialogUtils.toastFinishedInfo(
          S.of(navGK.currentState.overlay.context).pinned);
    }
    data.pinned = !data.pinned;
    ListViewUtil.handleAllStatuses((e) => e['pinned'] = data.pinned,
        ListViewUtil.sameStatusCondition(data));
  }

  static _onPressMuteConversation(StatusItemData data) {
    if (data.muted) {
      StatusApi.numuteConversation(data.id);
      DialogUtils.toastFinishedInfo(
          S.of(navGK.currentState.overlay.context).conversation_unhide);
    } else {
      StatusApi.muteConversation(data.id);
      DialogUtils.toastFinishedInfo(
          S.of(navGK.currentState.overlay.context).conversation_hidden);
    }
    data.muted = !data.muted;
    ListViewUtil.handleAllStatuses(
        (e) => e['muted'] = data.muted, ListViewUtil.sameStatusCondition(data));
  }

  static _onPressBlock(
      BuildContext context, StatusItemData data, bool subStatus) async {
    var provider;
    try {
      provider = Provider.of<ResultListProvider>(context, listen: false);
    } catch (e) {
      // status detail page
      provider = SettingsProvider().statusDetailProviders.last;
    }
    if (SettingsProvider().statusDetailProviders.contains(provider)) {
      // user is in status detail page
      if (subStatus) {
        // 当前页的的字嘟文是否和主嘟文是同一个作者
        var sameAccount = provider.list.firstWhere(
            (element) =>
                element.isNotEmpty &&
                !element.containsKey('__sub') &&
                element['account']['id'] == data.account.id,
            orElse: () => null);
        if (sameAccount == null)
          ListViewUtil.blockUser(context: context, status: data);
        else
          AppNavigate.pop(param: {'operation': 'block', 'status': data});
      } else {
        AppNavigate.pop(param: {'operation': 'block', 'status': data});
      }
    } else {
      ListViewUtil.blockUser(context: context, status: data);
    }
  }

  static _onPressMute(
      BuildContext context, StatusItemData data, bool subStatus) async {
    var provider;
    try {
      provider = Provider.of<ResultListProvider>(context, listen: false);
    } catch (e) {
      // status detail page
      provider = SettingsProvider().statusDetailProviders.last;
    }

    if (SettingsProvider().statusDetailProviders.contains(provider)) {
      // user is in status detail page
      if (subStatus) {
        // 当前页的的字嘟文是否和主嘟文是同一个作者
        var sameAccount = provider.list.firstWhere(
            (element) =>
                element.isNotEmpty &&
                !element.containsKey('__sub') &&
                element['account']['id'] == data.account.id,
            orElse: () => null);
        if (sameAccount == null)
          ListViewUtil.muteUser(context: context, status: data);
        else
          AppNavigate.pop(param: {'operation': 'mute', 'status': data});
      } else {
        AppNavigate.pop(param: {'operation': 'mute', 'status': data});
      }
    } else {
      ListViewUtil.muteUser(context: context, status: data);
    }
  }

  static bool sameInstance(BuildContext context) {
    ResultListProvider provider;
    try {
      provider = Provider.of<ResultListProvider>(context, listen: false);
    } catch (e) {
      return false;
    }

    if (provider.requestUrl.startsWith('https://')) {
      return false;
    }
    return true;
  }

  static bool isLocalStatus(StatusItemData data) {
    if (data.url.startsWith(LoginedUser().host)) {
      return true;
    }
    return false;
  }

  static Future<StatusItemData> getStatusInLocal(
      BuildContext context, StatusItemData status) async {
    if (!isLocalStatus(status) && !sameInstance(context)) {
      if (!ListViewUtil.loginnedAndPrompt(context)) return null;
      var statusLocal = await SearchApi.resolveStatus(status.url);
      if (statusLocal == null) {
        DialogUtils.toastErrorInfo(S.of(context).an_error_occurred);
        return null;
      }
      return statusLocal;
    } else {
      return status;
    }
  }

  static Future<OwnerAccount> getAccountInLocal(
      BuildContext context, OwnerAccount account) async {
    if (context != null && !sameInstance(context) ||
        !AccountUtil.sameInstance(account.url)) {
      if (!ListViewUtil.loginnedAndPrompt(context)) return null;
      var statusLocal = await SearchApi.resolveAccount(account.url);
      if (statusLocal == null) {
        DialogUtils.toastErrorInfo(S.of(context).an_error_occurred);
        return null;
      }
      return statusLocal;
    } else {
      return account;
    }
  }
}
