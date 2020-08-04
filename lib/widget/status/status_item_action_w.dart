import 'package:fastodon/api/status_api.dart';
import 'package:fastodon/constant/api.dart';
import 'package:fastodon/models/json_serializable/article_item.dart';
import 'package:fastodon/models/provider/result_list_provider.dart';
import 'package:fastodon/pages/status/new_status.dart';
import 'package:fastodon/plugin/event_source.dart';
import 'package:fastodon/utils/app_navigate.dart';
import 'package:fastodon/utils/list_view.dart';
import 'package:fastodon/utils/request.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class StatusItemActionW extends StatelessWidget {
  final StatusItemData status;

  const StatusItemActionW({Key key, this.status}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).accentColor;
    double fontSize = 12;
    return Container(
      margin: EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
          border: Border(
              top: BorderSide(
                  width: 0.5, color: Theme.of(context).dividerColor))),
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GestureDetector(
            onTap: () => AppNavigate.push(NewStatus(replyTo: status)),
            child: Row(
              children: <Widget>[
                Icon(MdiIcons.replyOutline, size: 18, color: color),
                SizedBox(
                  width: 5,
                ),
                Text(
                  '转评',
                  style: TextStyle(fontSize: fontSize, color: color),
                ),
                SizedBox(
                  width: 2,
                ),
                Text(
                    status.repliesCount > 0
                        ? status.repliesCount.toString()
                        : '',
                    style: TextStyle(fontSize: fontSize - 1, color: color))
              ],
            ),
          ),
          if (status.visibility == 'private')
            Icon(
              Icons.lock,
              color: Theme.of(context).splashColor,
              size: 20,
            ),
          if (status.visibility == 'direct')
            Icon(
              Icons.mail,
              color: Theme.of(context).splashColor,
              size: 20,
            ),
          if (status.visibility != 'private' && status.visibility != 'direct')
            LikeButton(
              size: 16,
              likeCountPadding: EdgeInsets.only(top: 0),
              likeCount: status.reblogsCount,
              countBuilder: (int count, bool isLiked, String text) {
                return count <= 0 ? Container():Text(count.toString(),
                        style: TextStyle(
                            fontSize: fontSize - 1, color: isLiked ? Colors.blue[800]: Theme.of(context).accentColor));
              },
              countDecoration: (Widget count,int likeCount) {
                return Row(
                  children: <Widget>[
                    SizedBox(width: 5,),
                    Text(
                      '快转',
                      style: TextStyle(fontSize: fontSize, color: status.reblogged ? Colors.blue[800]: Theme.of(context).accentColor),
                    ),
                    SizedBox(width: 2,),
                    count
                  ],
                );
              },
              likeBuilder: (bool isLiked) {
                status.reblogged = !isLiked;
                return isLiked
                    ? Icon(
                        Icons.repeat_one,
                        color: Colors.blue[800],
                        size: 18,
                      )
                    : Icon(
                        Icons.repeat,
                        color: Theme.of(context).splashColor,
                        size: 18,
                      );
              },
              isLiked: status.reblogged,
              bubblesColor: BubblesColor(
                  dotPrimaryColor: Colors.blue[700],
                  dotSecondaryColor: Colors.blue[300]),
              circleColor: CircleColor(
                  start: Colors.blue[300], end: Colors.blue[700]),
              onTap: _onPressReblog,
            ),
          LikeButton(
            size: 16,
            likeCountPadding: EdgeInsets.only(top: 0),
            likeCount: status.favouritesCount,
            countBuilder: (int count, bool isLiked, String text) {
              return count <= 0 ? Container():Text(count.toString(),
                  style: TextStyle(
                      fontSize: fontSize - 1, color: isLiked ? Colors.yellow[800]:color));
            },
            countDecoration: (Widget count,int likeCount) {



              return Row(
                children: <Widget>[
                  SizedBox(width: 5,),
                  Text(
                    '赞',
                    style: TextStyle(fontSize: fontSize, color: status.favourited ? Colors.yellow[800] :Theme.of(context).accentColor),
                  ),
                  SizedBox(width: 2,),
                  count
                ],
              );
            },
            likeBuilder: (bool isLiked) {

              return isLiked
                  ? Icon(
                MdiIcons.thumbUpOutline,
                color: Colors.yellow[800],
                size: 16,
              )
                  : Icon(
                MdiIcons.thumbUpOutline,
                color: Theme.of(context).splashColor,
                size: 16,
              );
            },
            isLiked: status.favourited,

            onTap:(isLiked) =>  _onPressFavoutite(isLiked),
          ),
        ],
      ),
    );
  }

  Future<bool> _onPressReblog(bool isLiked) async {
    if (isLiked) {
      StatusApi.unReblog(status.id);
      status.reblogged = false;
      status.reblogsCount = status.reblogsCount - 1;
      ListViewUtil.unreblogStatus(status);
    } else {
      StatusApi.reblog(status.id);
      status.reblogged = true;
      status.reblogsCount = status.reblogsCount + 1;
      ListViewUtil.reblogStatus(status);
    }

    return !isLiked;
  }

  Future<bool> _onPressFavoutite(bool isLiked,{BuildContext context}) async {
    requestFavorite(isLiked);
    status.favourited = !isLiked;
    status.favouritesCount = status.favouritesCount + (!isLiked ? 1 : -1);
    return !isLiked;
  }

  requestFavorite(bool isLiked) async {
    var url = !isLiked
        ? Api.FavouritesArticle(status.id)
        : Api.UnFavouritesArticle(status.id);
    try {
      StatusItemData data = StatusItemData.fromJson(
          await Request.post(url: url, showDialog: false));
      if (isLiked) {
        ListViewUtil.unfavouriteStatus(data);
      } else {
        ListViewUtil.favouriteStatus(data);
      }
   //   status.favourited = data.favourited;
    } catch (e) {
      print(e);
    }
  }
}
