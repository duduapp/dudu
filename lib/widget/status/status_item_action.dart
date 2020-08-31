import 'package:dudu/api/status_api.dart';
import 'package:dudu/models/json_serializable/article_item.dart';
import 'package:dudu/models/json_serializable/owner_account.dart';
import 'package:dudu/models/logined_user.dart';
import 'package:dudu/models/provider/result_list_provider.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/pages/status/new_status.dart';
import 'package:dudu/pages/user_profile/user_report.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/dialog_util.dart';
import 'package:dudu/utils/view/list_view_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:like_button/like_button.dart';
import 'package:provider/provider.dart';

class StatusItemAction extends StatefulWidget {
  StatusItemAction({
    this.subStatus,
    Key key,
    this.item,
  }) : super(key: key);
  final StatusItemData item;
  final bool subStatus;

  @override
  _StatusItemActionState createState() => _StatusItemActionState();
}

class _StatusItemActionState extends State<StatusItemAction> {
  @override
  void initState() {
    super.initState();
  }

  Future<bool> _onPressFavoutite(bool isLiked) async {
    requestFavorite(isLiked);

    return !isLiked;
  }

  Future<bool> _onPressReblog(bool isLiked) async {
    if (isLiked)
      StatusApi.unReblog(widget.item.id);
    else
      StatusApi.reblog(widget.item.id);

    return !isLiked;
  }

  Future<bool> _onPressBookmark(bool isLiked) async {
    if (isLiked)
      StatusApi.unBookmark(widget.item.id);
    else
      StatusApi.bookmark(widget.item.id);

    return !isLiked;
  }

  _onPressMute() async {
    var provider = Provider.of<ResultListProvider>(context, listen: false);
    if (SettingsProvider().statusDetailProviders.contains(provider)) {
      // user is in status detail page
      if (widget.subStatus) {
        // 当前页的的字嘟文是否和主嘟文是同一个作者
        var sameAccount = provider.list.firstWhere((element) =>
            element.isNotEmpty &&
            !element.containsKey('__sub') &&
            element['account']['id'] == widget.item.account.id,orElse: () => null);
        if (sameAccount == null)
          ListViewUtil.muteUser(context: context, status: widget.item);
        else
          AppNavigate.pop(param:{
            'operation':'mute',
            'status':widget.item
          });
      } else {
        AppNavigate.pop(param:{
          'operation':'mute',
          'status':widget.item
        });
      }
    } else {
      ListViewUtil.muteUser(context: context, status: widget.item);
    }
  }

  _onPressBlock() async {
    var provider = Provider.of<ResultListProvider>(context, listen: false);
    if (SettingsProvider().statusDetailProviders.contains(provider)) {
      // user is in status detail page
      if (widget.subStatus) {
        // 当前页的的字嘟文是否和主嘟文是同一个作者
        var sameAccount = provider.list.firstWhere((element) =>
        element.isNotEmpty &&
            !element.containsKey('__sub') &&
            element['account']['id'] == widget.item.account.id,orElse: () => null);
        if (sameAccount == null)
          ListViewUtil.muteUser(context: context, status: widget.item);
        else
          AppNavigate.pop(param:{
            'operation':'block',
            'status':widget.item
          });
      } else {
        AppNavigate.pop(param:{
          'operation':'block',
          'status':widget.item
        });
      }
    } else {
      ListViewUtil.muteUser(context: context, status: widget.item);
    }
  }

  _onPressRemove() async {
    var provider = Provider.of<ResultListProvider>(context, listen: false);
    if (SettingsProvider().statusDetailProviders.contains(provider)) {
      // user is in status detail page
      if (widget.subStatus) {
          ListViewUtil.deleteStatus(context: context, status: widget.item);
      } else {
        AppNavigate.pop(param:{
          'operation':'delete',
          'status':widget.item
        });
      }
    } else {
      ListViewUtil.deleteStatus(context: context, status: widget.item);
    }
//    var provider = Provider.of<ResultListProvider>(context, listen: false);
//    provider.removeByIdWithAnimation(widget.item.id);
//    StatusApi.remove(widget.item.id);
  }

  requestFavorite(bool isLiked) async {
    var url = !isLiked
        ? Api.FavouritesArticle(widget.item.id)
        : Api.UnFavouritesArticle(widget.item.id);
    try {
      StatusItemData data = StatusItemData.fromJson(
          await Request.post(url: url, showDialog: false));
      widget.item.favourited = data.favourited;
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    OwnerAccount myAccount = LoginedUser().account;
    var splashColor = Theme.of(context).accentColor;
    return Container(
      height: 38,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          InkWell(
            onTap: () {
              AppNavigate.push(NewStatus(replyTo: widget.item));
            },
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.reply,
                  color: splashColor,
                  size: 20,
                ),
                SizedBox(width: 3),
                Text(
                  '${widget.item.repliesCount}',
                  style: TextStyle(color: splashColor, fontSize: 12),
                ),
              ],
            ),
          ),
          Spacer(),
          Row(children: [
            if (widget.item.visibility == 'private')
              Icon(
                Icons.lock,
                color: splashColor,
                size: 20,
              ),
            if (widget.item.visibility == 'direct')
              Icon(
                Icons.mail,
                color: splashColor,
                size: 20,
              ),
            if (widget.item.visibility != 'private' &&
                widget.item.visibility != 'direct') ...[
              LikeButton(
                likeBuilder: (bool isLiked) {
                  return isLiked
                      ? Icon(
                          Icons.repeat_one,
                          color: Colors.blue[800],
                        )
                      : Icon(
                          Icons.repeat,
                          color: splashColor,
                          size: 20,
                        );
                },
                isLiked: widget.item.reblogged,
                bubblesColor: BubblesColor(
                    dotPrimaryColor: Colors.blue[700],
                    dotSecondaryColor: Colors.blue[300]),
                circleColor:
                    CircleColor(start: Colors.blue[300], end: Colors.blue[700]),
                onTap: _onPressReblog,
              ),
              Text('${widget.item.reblogsCount}',
                  style: TextStyle(color: splashColor, fontSize: 12))
            ]
          ]),
          Spacer(),
          LikeButton(
            likeBuilder: (bool isLiked) {
              return isLiked
                  ? Icon(
                      Icons.star,
                      color: Colors.yellow[800],
                    )
                  : Icon(
                      Icons.star_border,
                      color: splashColor,
                      size: 20,
                    );
            },
            isLiked: widget.item.favourited,
            onTap: _onPressFavoutite,
          ),
          Spacer(
            flex: 1,
          ),
          LikeButton(
            likeBuilder: (bool isLiked) {
              return isLiked
                  ? Icon(Icons.bookmark, color: Colors.green[800])
                  : Icon(
                      Icons.bookmark_border,
                      color: splashColor,
                      size: 20,
                    );
            },
            isLiked: widget.item.bookmarked,
            bubblesColor: BubblesColor(
                dotPrimaryColor: Colors.green[700],
                dotSecondaryColor: Colors.green[300]),
            circleColor:
                CircleColor(start: Colors.green[300], end: Colors.green[700]),
            onTap: _onPressBookmark,
          ),
          Spacer(),
          PopupMenuButton(
            offset: Offset(0, 35),
            icon: Icon(
              Icons.more_horiz,
              color: splashColor,
              size: 20,
            ),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(value: 'copy_url', child: new Text('复制链接')),
              PopupMenuItem<String>(
                  value: 'copy_content', child: new Text('复制嘟文')),
              PopupMenuItem<String>(value: 'hide', child: new Text('隐藏')),
              PopupMenuItem<String>(value: 'block', child: new Text('屏蔽')),
              if (myAccount == widget.item.account)
                PopupMenuItem<String>(value: 'remove', child: new Text('删除')),
              if (myAccount != widget.item.account)
                PopupMenuItem<String>(value: 'report', child: new Text('举报'))
            ],
            onSelected: (String value) {
              switch (value) {
                case 'copy_url':
                  Clipboard.setData(new ClipboardData(text: widget.item.url));
                  break;
                case 'copy_content':
                  Clipboard.setData(new ClipboardData(
                      text: StringUtil.removeAllHtmlTags(widget.item.content)));
                  break;
                case 'hide':
                  DialogUtils.showSimpleAlertDialog(
                      context: context,
                      text: '确定要隐藏@${widget.item.account.acct}吗',
                      onConfirm: _onPressMute);
                  break;
                case "block":
                  DialogUtils.showSimpleAlertDialog(
                      context: context,
                      text: '确定要屏蔽${widget.item.account.acct}吗',
                      onConfirm: _onPressBlock);
                  break;
                case 'remove':
                  DialogUtils.showSimpleAlertDialog(
                      context: context,
                      text: '确定要删除这条嘟嘟吗?',
                      onConfirm: _onPressRemove);
                  break;
                case 'report':
                  AppNavigate.push(UserReport(
                    account: widget.item.account,
                    fromStatusId: widget.item.id,
                  ));
                  break;
              }
            },
          )
        ],
      ),
    );
  }
}
