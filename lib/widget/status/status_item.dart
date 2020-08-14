import 'package:cached_network_image/cached_network_image.dart';
import 'package:fastodon/models/json_serializable/article_item.dart';
import 'package:fastodon/models/json_serializable/owner_account.dart';
import 'package:fastodon/pages/status/status_detail.dart';
import 'package:fastodon/pages/user_profile/user_profile.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/utils/view/list_view_util.dart';
import 'package:fastodon/utils/view/status_action_util.dart';
import 'package:fastodon/widget/common/no_splash_ink_well.dart';
import 'package:fastodon/widget/status/status_item_account.dart';
import 'package:fastodon/widget/status/status_item_account_w.dart';
import 'package:fastodon/widget/status/status_item_action_w.dart';
import 'package:fastodon/widget/status/status_item_card.dart';
import 'package:fastodon/widget/status/status_item_content.dart';
import 'package:fastodon/widget/status/status_item_primary_bottom.dart';
import 'package:fastodon/widget/status/text_with_emoji.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart';

import '../other/avatar.dart';
import 'status_item_action.dart';

class StatusItem extends StatelessWidget {
  StatusItem(
      {Key key,
      @required this.item,
      this.refIcon,
      this.refString,
      this.subStatus = false,
      this.refAccount,
      this.primary = false})
      : super(key: key);
  final StatusItemData item;
  final IconData refIcon; // 用户引用status时显示的图标，比如 显示在status上面的（icon,who转嘟了）
  final String refString;
  final OwnerAccount refAccount;
  final bool subStatus;
  final bool primary; // 点击status详情页后该status

  @override
  Widget build(BuildContext context) {
    if (subStatus != null && subStatus) {
      return Column(children: [
        NoSplashInkWell(
          onTap: () => _onStatusClicked(context),
          onLongPress: () =>
              StatusActionUtil.showBottomSheetAction(context, item, subStatus),
          child: Ink(
            color: Theme.of(context).primaryColor,
            padding: EdgeInsets.fromLTRB(15, 8, 15, 0),
            // margin: EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
                  child: Avatar(
                    width: 40,
                    height: 40,
                    account: item.account,
                  ),
                ),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      SubStatusAccountW(status: item),
                      StatusItemContent(item),
                      StatusItemCard(item),
                      StatusItemActionW(
                        status: item,
                        subStatus: subStatus,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        SizedBox(
          height: 8,
        )
      ]);
    } else {
      StatusItemData data = item.reblog ?? item;
      return Column(children: [
        NoSplashInkWell(
          onTap: primary ? null : () => _onStatusClicked(context),
          onLongPress: () =>
              StatusActionUtil.showBottomSheetAction(context, data, subStatus),
          child: Ink(
            color: Theme.of(context).primaryColor,
            padding: EdgeInsets.fromLTRB(15, 8, 15, 0),
            //margin: EdgeInsets.only(bottom: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                refHeader(context),
                StatusItemAccountW(
                  status: data,
                  subStatus: subStatus,
                  primary: primary,
                ),
//                StatusItemAccount(data.account,
//                    createdAt: primary ? null : data.createdAt),
                StatusItemContent(
                  data,
                  primary: primary,
                ),
                StatusItemCard(data),
                // if (primary) StatusItemPrimaryBottom(data),
                StatusItemActionW(
                  status: data,
                  subStatus: subStatus,
                )
//                StatusItemAction(
//                  item: data,
//                  subStatus: subStatus,
//                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 8,
        )
      ]);
    }
  }

  _onStatusClicked(BuildContext context) async {
    var res = await AppNavigate.push(StatusDetail(item.reblog ?? item));
    if (res is Map && res.containsKey('operation')) {
      switch (res['operation']) {
        case 'mute':
          var status = res['status'];
          ListViewUtil.muteUser(context: context, status: status);
          break;
        case 'block':
          var status = res['status'];
          ListViewUtil.blockUser(context: context, status: status);
          break;
        case 'delete':
          var status = res['status'];
          ListViewUtil.deleteStatus(context: context, status: status);
          break;
      }
    }
  }

  Widget refHeader(BuildContext context) {
    IconData icon = refIcon;
    String str = refString;

    if (item.reblog != null) {
      icon = Icons.repeat;
      str = '${StringUtil.displayName(item.account)} 转嘟了';
    }

    return (icon != null && str != null)
        ? InkWell(
            onTap: () => AppNavigate.push(UserProfile(
              accountId: refAccount?.id ?? item.account.id,
            )),
            child: Container(
              padding: EdgeInsets.only(top: 3, bottom: 8),
              child: Row(
                children: <Widget>[
                  Icon(
                    icon,
                    color: Theme.of(context).buttonColor,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  TextWithEmoji(
                    text: str,
                    emojis: refAccount == null
                        ? item.account.emojis
                        : refAccount?.emojis ?? [],
                  )
                ],
              ),
            ),
          )
        : Container();
  }
}
