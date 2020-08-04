import 'package:cached_network_image/cached_network_image.dart';
import 'package:fastodon/models/json_serializable/article_item.dart';
import 'package:fastodon/models/json_serializable/owner_account.dart';
import 'package:fastodon/pages/status/status_detail.dart';
import 'package:fastodon/pages/user_profile/user_profile.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/utils/list_view.dart';
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

class StatusItem extends StatefulWidget {
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
  _StatusItemState createState() => _StatusItemState();
}

class _StatusItemState extends State<StatusItem> {

  @override
  Widget build(BuildContext context) {
    if (widget.subStatus != null && widget.subStatus) {
      return InkWell(
        onTap: _onStatusClicked,
        child: Container(
          color: Theme.of(context).primaryColor,
          padding: EdgeInsets.fromLTRB(15, 8, 15, 0),
          margin: EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              InkWell(
               // onTap: _onStatusClicked,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
                  child: Avatar(account: widget.item.account,),
                ),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    SubStatusItemHeader(widget.item),
                    StatusItemContent(widget.item),
                    StatusItemCard(widget.item),
                    StatusItemAction(
                      item: widget.item,
                      subStatus: widget.subStatus,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      );
    } else {
      StatusItemData data = widget.item.reblog ?? widget.item;
      return Column(children: [
        InkWell(
          splashColor: Colors.transparent,
          onTap: _onStatusClicked,
          child: Ink(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(15, 8, 15, 0),
            //margin: EdgeInsets.only(bottom: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                refHeader(),
                StatusItemAccountW(
                  status: data,
                ),
//                StatusItemAccount(data.account,
//                    createdAt: widget.primary ? null : data.createdAt),
                StatusItemContent(
                  data,
                  primary: widget.primary,
                ),
                StatusItemCard(data),
                if (widget.primary) StatusItemPrimaryBottom(data),
                StatusItemActionW(status: data,)
//                StatusItemAction(
//                  item: data,
//                  subStatus: widget.subStatus,
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

  _onStatusClicked() async{
    var res = await AppNavigate.push(StatusDetail(widget.item));
    if (res is Map && res.containsKey('operation')) {
      switch(res['operation']) {
        case 'mute':
          var status = res['status'];
          ListViewUtil.muteUser(context: context,status: status);
          break;
        case 'block':
          var status = res['status'];
          ListViewUtil.blockUser(context: context,status: status);
          break;
        case 'delete':
          var status = res['status'];
          ListViewUtil.deleteStatus(context: context,status: status);
          break;
      }
    }
  }

  Widget refHeader() {
    IconData icon = widget.refIcon;
    String str = widget.refString;

    if (widget.item.reblog != null) {
      icon = Icons.repeat;
      str = '${StringUtil.displayName(widget.item.account)} 转嘟了';
    }

    return (icon != null && str != null)
        ? InkWell(
            onTap: () => AppNavigate.push(UserProfile(
              accountId: widget.refAccount?.id ?? widget.item.account.id,
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
                    emojis: widget.refAccount == null
                        ? widget.item.account.emojis
                        : widget.refAccount?.emojis ?? [],
                  )
                ],
              ),
            ),
          )
        : Container();
  }
}
