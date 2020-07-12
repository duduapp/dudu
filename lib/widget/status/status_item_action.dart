import 'package:fastodon/api/accounts_api.dart';
import 'package:fastodon/api/status_api.dart';
import 'package:fastodon/models/provider/result_list_provider.dart';
import 'package:fastodon/pages/status/new_status.dart';
import 'package:fastodon/utils/dialog_util.dart';
import 'package:flutter/material.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/models/article_item.dart';
import 'package:flutter/services.dart';
import 'package:like_button/like_button.dart';
import 'package:provider/provider.dart';

class StatusItemAction extends StatefulWidget {
  StatusItemAction({
    Key key,
    this.item,
  }) : super(key: key);
  final StatusItemData item;

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

  _onPressHide() async {
    AppNavigate.pop(context);
    var provider = Provider.of<ResultListProvider>(context, listen: false);
    var res = await AccountsApi.mute(widget.item.account.id);

    var statusId = widget.item.id;
    var accountId = widget.item.account.id;
    if (res != null) {
      provider.removeByIdWithAnimation(widget.item.id);
      // 防止和上面的语句冲突
      Future.delayed(Duration(seconds: 1), () {
        eventBus.emit(EventBusKey.muteAccount,
            {'account_id': accountId, 'from_status_id': statusId});
      });
    }
  }

  _onPressBlock() async {
    AppNavigate.pop(context);
    var provider = Provider.of<ResultListProvider>(context, listen: false);
    var res = await AccountsApi.block(widget.item.account.id);
    ;

    var statusId = widget.item.id;
    var accountId = widget.item.account.id;
    if (res != null) {
      provider.removeByIdWithAnimation(widget.item.id);
      // 防止和上面的语句冲突
      Future.delayed(Duration(seconds: 2), () {
        eventBus.emit(EventBusKey.blockAccount,
            {'account_id': accountId, 'from_status_id': statusId});
      });
    }
  }

  requestFavorite(bool isLiked) async {
    var url = !isLiked
        ? Api.FavouritesArticle(widget.item.id)
        : Api.UnFavouritesArticle(widget.item.id);
    try {
      StatusItemData data =
          StatusItemData.fromJson(await Request.post(url: url));
      widget.item.favourited = data.favourited;
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    var buttonColor = Theme.of(context).splashColor;
    return Container(
      height: 38,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          InkWell(
            onTap: () {
              AppNavigate.push(context, NewStatus(replyTo: widget.item));
            },
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.reply,
                  color: buttonColor,
                  size: 20,
                ),
                SizedBox(width: 3),
                Text(
                  '${widget.item.repliesCount}',
                  style: TextStyle(color: buttonColor, fontSize: 12),
                ),
              ],
            ),
          ),
          Spacer(),
          Row(children: [
            LikeButton(
              likeBuilder: (bool isLiked) {
                return isLiked
                    ? Icon(
                        Icons.repeat_one,
                        color: Colors.blue[800],
                      )
                    : Icon(
                        Icons.repeat,
                        color: buttonColor,
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
                style: TextStyle(color: buttonColor, fontSize: 12))
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
                      color: buttonColor,
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
                      color: buttonColor,
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
              color: buttonColor,
              size: 20,
            ),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              new PopupMenuItem<String>(
                  value: 'copy_url', child: new Text('复制链接')),
              new PopupMenuItem<String>(
                  value: 'copy_content', child: new Text('复制嘟文')),
              new PopupMenuItem<String>(value: 'hide', child: new Text('隐藏')),
              new PopupMenuItem<String>(value: 'block', child: new Text('屏蔽'))
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
                      onConfirm: _onPressHide);
                  break;
                case "block":
                  DialogUtils.showSimpleAlertDialog(
                      context: context,
                      text: '确定要屏蔽${widget.item.account.acct}吗',
                      onConfirm: _onPressBlock);
              }
            },
          )
        ],
      ),
    );
  }
}
