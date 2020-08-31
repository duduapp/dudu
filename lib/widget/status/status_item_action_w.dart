import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/models/json_serializable/article_item.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/pages/status/new_status.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/app_navigate.dart';
import 'package:dudu/utils/view/status_action_util.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

class StatusItemActionW extends StatelessWidget {
  final StatusItemData status;
  final bool subStatus;
  final bool showNum;

  const StatusItemActionW({Key key, this.status, this.subStatus, this.showNum = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var textScale =
    SettingsProvider.getWithCurrentContext('text_scale', listen: true);
    Color color = Theme.of(context).accentColor;
    double fontSize = 12 ;
    double iconSize = 16 * ScreenUtil.scaleFromSetting(textScale) ;
    return InkWell(
      highlightColor: Colors.transparent,
      onTap: () {},
      child: Container(
        margin: EdgeInsets.only(top: subStatus ? 0 :0),
        decoration: BoxDecoration(
            border: (subStatus || !showNum) ? null : Border(
                top: BorderSide(
                    width: 0.5, color: Theme.of(context).dividerColor))) ,
        padding:  EdgeInsets.fromLTRB(subStatus ? 0 :20,0,subStatus ? 0 :20,0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (subStatus)
              ...[
                Text(DateUntil.absoluteTime(status.createdAt),style: TextStyle(fontSize: 12,color: Theme.of(context).accentColor),),

                Spacer()
              ],

            GestureDetector(
              onTap: () => AppNavigate.push(NewStatus(replyTo: status)),
              child: Padding(
                padding: EdgeInsets.all(subStatus ? 4.0 : 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(IconFont.forward, size: iconSize, color: color),
                    SizedBox(
                      width: 3,
                    ),
                    Text(
                      subStatus ? '':'转评',
                      style: TextStyle(fontSize: fontSize, color: color),
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Text(
                        (status.repliesCount <= 0 || !showNum)
                            ? '' : status.repliesCount.toString(),
                        style: TextStyle(fontSize: fontSize - 1, color: color),
                    textAlign: TextAlign.center,)
                  ],
                ),
              ),
            ),
            SizedBox(width: 10,),
            if (status.visibility == 'private')
              Icon(
                IconFont.lock,
                color: Theme.of(context).accentColor,
                size: 20,
              ),
            if (status.visibility == 'direct')
              Icon(
                IconFont.message,
                color: Theme.of(context).accentColor,
                size: 20,
              ),
            if (status.visibility != 'private' && status.visibility != 'direct')
              Padding(
                padding: EdgeInsets.all(subStatus ? 4.0 :8.0),
                child: LikeButton(
                  size: 20 * ScreenUtil.scaleFromSetting(textScale),

                  likeCountPadding: EdgeInsets.zero,
                  likeCount: status.reblogsCount,
                  countBuilder: (int count, bool isLiked, String text) {
                    return (count <= 0 || !showNum)
                        ? Container()
                        : Text(count.toString(),
                            style: TextStyle(
                                fontSize: fontSize - 1,
                                color: isLiked
                                    ? Colors.blue[800]
                                    : Theme.of(context).accentColor));
                  },
                  countDecoration: (Widget count, int likeCount) {
                    return Row(
                      children: <Widget>[
                        SizedBox(width: 3,),
                        Text(
                          subStatus ? '' :'转嘟',
                          style: TextStyle(
                              fontSize: fontSize ,


                              color: status.reblogged
                                  ? Colors.blue[800]
                                  : Theme.of(context).accentColor),
                        ),
                        SizedBox(
                          width: 2,
                        ),
                        count
                      ],
                    );
                  },
                  likeBuilder: (bool isLiked) {
                    return isLiked
                        ? Icon(
                            IconFont.reblog,
                            color: Colors.blue[800],
                            size: iconSize,
                          )
                        : Icon(
                            IconFont.reblog,
                            color: Theme.of(context).accentColor,
                            size: iconSize,
                          );
                  },
                  isLiked: status.reblogged,
                  bubblesColor: BubblesColor(
                      dotPrimaryColor: Colors.blue[700],
                      dotSecondaryColor: Colors.blue[300]),
                  circleColor:
                      CircleColor(start: Colors.blue[300], end: Colors.blue[700]),
                  onTap: (isLiked) => StatusActionUtil.reblog(isLiked, status,context),
                ),
              ),
            SizedBox(width: 10,),
            Padding(
              padding: EdgeInsets.all(subStatus? 4.0 :8.0),
              child: LikeButton(
                size: 20 * ScreenUtil.scaleFromSetting(textScale),
                likeCountPadding: EdgeInsets.zero,
                likeCount: status.favouritesCount,
                countBuilder: (int count, bool isLiked, String text) {
                  return (count <= 0 || !showNum)
                      ? Container()
                      : Text(count.toString(),
                          style: TextStyle(
                              fontSize: fontSize - 1,
                              color: isLiked ? Colors.yellow[800] : color));
                },
                countDecoration: (Widget count, int likeCount) {
                  return Row(
                    children: <Widget>[
                      SizedBox(width: 3,),
                      Text(
                        subStatus ? '':'赞',
                        style: TextStyle(
                            fontSize: fontSize,
                            color: status.favourited
                                ? Colors.yellow[800]
                                : Theme.of(context).accentColor),
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      count
                    ],
                  );
                },
                likeBuilder: (bool isLiked) {
                  return isLiked
                      ? Icon(
                          IconFont.thumbUp,
                          color: Colors.yellow[800],
                          size: iconSize,
                        )
                      : Icon(
                          IconFont.thumbUp,
                          color: Theme.of(context).accentColor,
                          size: iconSize,
                        );
                },
                isLiked: status.favourited,
                onTap: (isLiked) => StatusActionUtil.favourite(isLiked, status ,context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

