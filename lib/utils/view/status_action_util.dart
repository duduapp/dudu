import 'package:dudu/api/status_api.dart';
import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/models/json_serializable/article_item.dart';
import 'package:dudu/models/json_serializable/owner_account.dart';
import 'package:dudu/models/logined_user.dart';
import 'package:dudu/models/provider/result_list_provider.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/models/runtime_config.dart';
import 'package:dudu/pages/user_profile/user_report.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/dialog_util.dart';
import 'package:dudu/widget/common/bottom_sheet_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nav_router/nav_router.dart';
import 'package:provider/provider.dart';

import 'list_view_util.dart';

class StatusActionUtil {
  static Future<bool> reblog(
      bool isLiked, StatusItemData status, BuildContext context) async {
    status.reblogged = !isLiked;
    status.reblogsCount = status.reblogsCount + (!isLiked ? 1 : -1);

    ResultListProvider provider =
        Provider.of<ResultListProvider>(context, listen: false);
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
      StatusApi.unReblog(status.id);
      ListViewUtil.unreblogStatusInAllProvider(status);
    } else {
      StatusApi.reblog(status.id);
      ListViewUtil.reblogStatusInAllProvider(status);
    }

    return !isLiked;
  }

  static Future<bool> favourite(
      bool isLiked, StatusItemData status, BuildContext context) async {
    status.favourited = !isLiked;
    status.favouritesCount = status.favouritesCount + (!isLiked ? 1 : -1);
    ResultListProvider provider =
        Provider.of<ResultListProvider>(context, listen: false);
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
    if (isLiked) {
      StatusApi.unfavourite(status.id);
      ListViewUtil.unfavouriteStatusInAllProvider(status);
    } else {
      StatusApi.favourite(status.id);
      ListViewUtil.favouriteStatusInAllProvider(status);
    }
    return !isLiked;
  }

  static updateStatusVote(StatusItemData status,dynamic pollJson,BuildContext context) {
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


  static showBottomSheetAction(
      BuildContext context, StatusItemData data, bool subStatus) {
    OwnerAccount myAccount = LoginedUser().account;
    BuildContext modalContext = context;
    ResultListProvider provider =
        Provider.of<ResultListProvider>(context, listen: false);
    bool mentioned = false;
    for (var row in data.mentions) {
      if (row['acct'] == myAccount.acct) {
        mentioned = true;
      }
    }
    showModalBottomSheet(
        context: modalContext,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              BottomSheetItem(
                icon: IconFont.bookmark,
                text: data.bookmarked ? '删除书签' : '添加书签',
                onTap: () => onPressBookmark(data),
              ),
              Divider(indent: 60, height: 0),
              if (mentioned) ...[
                BottomSheetItem(
                  icon: IconFont.volumeOff,
                  text: data.muted ? '取消隐藏该对话' : '隐藏该对话',
                  subText: '隐藏后将不会从该对话中接收到通知',
                  onTap: () {
                    AppNavigate.pop();
                    _onPressMuteConversation(data);
                  },
                ),
                Divider(indent: 60, height: 0),
              ],
              BottomSheetItem(
                icon: IconFont.link,
                text: '复制链接',
                onTap: () {
                  AppNavigate.pop();
                  Clipboard.setData(new ClipboardData(text: data.url));
                  DialogUtils.toastFinishedInfo('链接已复制');
                },
              ),
              Divider(indent: 60, height: 0),
              BottomSheetItem(
                icon: IconFont.copy,
                text: '复制嘟文',
                onTap: () {
                  AppNavigate.pop();
                  Clipboard.setData(new ClipboardData(
                      text: StringUtil.removeAllHtmlTags(data.content)));
                  DialogUtils.toastFinishedInfo('嘟文已复制');
                },
              ),
              Divider(indent: 60, height: 0),
              if (myAccount.id != data.account.id) ...[
                BottomSheetItem(
                  icon: IconFont.volumeOff,
                  text: '隐藏 @' + data.account.username,
                  subText: '隐藏后该用户的嘟文将不会显示在你的时间轴中',
                  onTap: () {
                    AppNavigate.pop();
                    DialogUtils.showSimpleAlertDialog(
                        context: context,
                        text: '你确定要隐藏用户 @' + data.account.username + '吗?',
                        onConfirm: () =>
                            _onPressMute(modalContext, data, subStatus));
                  },
                ),
                Divider(indent: 60, height: 0),
                BottomSheetItem(
                  onTap: () {
                    AppNavigate.pop();
                    DialogUtils.showSimpleAlertDialog(
                        context: context,
                        text: '你确定要屏蔽用户 @' + data.account.username + '吗?',
                        onConfirm: () =>
                            _onPressBlock(modalContext, data, subStatus));
                  },
                  icon: IconFont.block,
                  text: '屏蔽 @' + data.account.username,
                  subText: '屏蔽后该用户将无法看到你发的嘟文',
                ),
                Divider(
                  indent: 60,
                  height: 0,
                ),
                BottomSheetItem(
                  icon: IconFont.report,
                  text: '举报 ',
                  onTap: () {
                    AppNavigate.pop();
                    AppNavigate.push(UserReport(
                      account: data.account,
                      fromStatusId: data.id,
                    ));
                  },
                ),
              ] else ...[
                BottomSheetItem(
                  icon: IconFont.delete,
                  text: '删除',
                  color: Colors.red,
                  onTap: () {
                    AppNavigate.pop();
                    DialogUtils.showSimpleAlertDialog(
                        context: context,
                        text: '确定要删除这条嘟嘟吗?',
                        onConfirm: () {
                          _onPressRemove(modalContext, data, subStatus);
                        });
                  },
                )
              ],
              Container(
                height: 8,
                color: Theme.of(context).backgroundColor,
              ),
              BottomSheetCancelItem()
            ],
          );
        });
  }

  static _onPressRemove(
      BuildContext context, StatusItemData data, bool subStatus) async {
    var provider = Provider.of<ResultListProvider>(context, listen: false);
    if (SettingsProvider().statusDetailProviders.contains(provider)) {
      // user is in status detail page
      if (subStatus) {
        ListViewUtil.deleteStatus(context: context, status: data);
      } else {
        AppNavigate.pop(param: {'operation': 'delete', 'status': data});
      }
    } else {
      ListViewUtil.deleteStatus(context: context, status: data);
    }
//    var provider = Provider.of<ResultListProvider>(context, listen: false);
//    provider.removeByIdWithAnimation(widget.item.id);
//    StatusApi.remove(widget.item.id);
  }

  static onPressBookmark(StatusItemData data) async {
    AppNavigate.pop();
    if (!data.bookmarked) {
      StatusApi.bookmark(data.id);
      DialogUtils.toastFinishedInfo('已添加书签');
    } else {
      StatusApi.unBookmark(data.id);
      DialogUtils.toastFinishedInfo('已删除书签');
    }
    data.bookmarked = !data.bookmarked;
    ListViewUtil.handleAllStatuses((e) => e['bookmarked'] = data.bookmarked,
        ListViewUtil.sameStatusCondition(data));
  }

  static _onPressMuteConversation(StatusItemData data) {
    if (data.muted) {
      StatusApi.numuteConversation(data.id);
      DialogUtils.toastFinishedInfo('已取消隐藏对话');
    } else {
      StatusApi.muteConversation(data.id);
      DialogUtils.toastFinishedInfo('已隐藏对话');
    }
    data.muted = !data.muted;
    ListViewUtil.handleAllStatuses(
        (e) => e['muted'] = data.muted, ListViewUtil.sameStatusCondition(data));
  }

  static _onPressBlock(
      BuildContext context, StatusItemData data, bool subStatus) async {
    var provider = Provider.of<ResultListProvider>(context, listen: false);
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
    var provider = Provider.of<ResultListProvider>(context, listen: false);
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
}
