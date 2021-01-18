import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/l10n/l10n.dart';
import 'package:dudu/models/json_serializable/article_item.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/pages/status/new_status.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/app_navigate.dart';
import 'package:dudu/utils/i18n_util.dart';
import 'package:dudu/utils/view/status_action_util.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:nav_router/nav_router.dart';
import 'package:provider/provider.dart';

class StatusItemActionW extends StatelessWidget {
  final StatusItemData status;
  final bool subStatus;
  final bool showNum;
  static String zan = S.of(navGK.currentState.overlay.context).awesome;
  static String shoucang = S.of(navGK.currentState.overlay.context).favorites;

  const StatusItemActionW(
      {Key key, this.status, this.subStatus, this.showNum = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String textScale =
        context.select<SettingsProvider, String>((m) => m.get('text_scale'));
    String zan_or_shoucang = context
        .select<SettingsProvider, String>((m) => m.get('zan_or_shoucang'));
    bool isZh = I18nUtil.isZh(context);
    var zan_icon = isZh
        ? (zan_or_shoucang == '0' ? IconFont.thumbUp : IconFont.favorite)
        : IconFont.favorite;
    var zan_text = isZh
        ? (zan_or_shoucang == '0' ? zan : shoucang)
        : S.of(context).favorites;

    Color color = Theme.of(context).accentColor;
    double fontSize = 12;
    double iconSize = 16 * ScreenUtil.scaleFromSetting(textScale);
    return InkWell(
      highlightColor: Colors.transparent,
      onTap: () {},
      child: Container(
        margin: EdgeInsets.only(top: subStatus ? 0 : 0),
        decoration: BoxDecoration(
            border: (subStatus || !showNum)
                ? null
                : Border(
                    top: BorderSide(
                        width: 0, color: Theme.of(context).backgroundColor))),
        padding:
            EdgeInsets.fromLTRB(subStatus ? 0 : 20, 0, subStatus ? 0 : 20, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (subStatus) ...[
              Text(
                DateUntil.absoluteTime(status.createdAt),
                style: TextStyle(
                    fontSize: 12, color: Theme.of(context).accentColor),
              ),
              Spacer()
            ],
            InkWell(
              onTap: () async {
                var realStatus =
                    await StatusActionUtil.getStatusInLocal(context, status);
                if (realStatus == null) return;
                AppNavigate.push(NewStatus(replyTo: realStatus));
              },
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
                      subStatus ? '' : S.of(context).review,
                      style: TextStyle(fontSize: fontSize, color: color),
                    ),
                    Text(
                      (status.repliesCount <= 0 || !showNum)
                          ? ''
                          : status.repliesCount.toString(),
                      style: TextStyle(fontSize: fontSize - 1, color: color),
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
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
              LikeButton(
                padding: EdgeInsets.all(subStatus ? 4.0 : 8.0),
                size: 20 * ScreenUtil.scaleFromSetting(textScale),
                likeCountPadding: EdgeInsets.zero,
                likeCount: status.reblogsCount,
                countBuilder: (int count, bool isLiked, String text) {
                  return (count <= 0 || !showNum)
                      ? Container()
                      : Text(text,
                          style: TextStyle(
                              fontSize: fontSize - 1,
                              color: isLiked != null && isLiked
                                  ? Colors.blue[800]
                                  : Theme.of(context).accentColor));
                },
                countDecoration: (Widget count, int likeCount) {
                  return Row(
                    children: <Widget>[
                      SizedBox(
                        width: 3,
                      ),
                      Text(
                        subStatus ? '' : S.of(context).turn_to,
                        style: TextStyle(
                            fontSize: fontSize,
                            color: status.reblogged != null && status.reblogged
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
                  return isLiked != null && isLiked
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
                isLiked: status.reblogged == null ? false : status.reblogged,
                bubblesColor: BubblesColor(
                    dotPrimaryColor: Colors.blue[700],
                    dotSecondaryColor: Colors.blue[300]),
                circleColor:
                    CircleColor(start: Colors.blue[300], end: Colors.blue[700]),
                onTap: (isLiked) =>
                    StatusActionUtil.reblog(isLiked, status, context),
              ),
            SizedBox(
              width: 10,
            ),
            LikeButton(
              padding: EdgeInsets.all(subStatus ? 4.0 : 8.0),
              size: 20 * ScreenUtil.scaleFromSetting(textScale),
              likeCountPadding: EdgeInsets.zero,
              likeCount: status.favouritesCount,
              countBuilder: (int count, bool isLiked, String text) {
                return (count <= 0 || !showNum)
                    ? Container()
                    : Text(text,
                        style: TextStyle(
                            fontSize: fontSize - 1,
                            color: isLiked != null && isLiked
                                ? Colors.yellow[800]
                                : color));
              },
              countDecoration: (Widget count, int likeCount) {
                return Row(
                  children: <Widget>[
                    SizedBox(
                      width: 3,
                    ),
                    Text(
                      subStatus ? '' : zan_text,
                      style: TextStyle(
                          fontSize: fontSize,
                          color: status.favourited != null && status.favourited
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
                        zan_icon,
                        color: Colors.yellow[800],
                        size: iconSize,
                      )
                    : Icon(
                        zan_icon,
                        color: Theme.of(context).accentColor,
                        size: iconSize,
                      );
              },
              isLiked: status.favourited ?? false,
              onTap: (isLiked) =>
                  StatusActionUtil.favourite(isLiked, status, context),
            ),
          ],
        ),
      ),
    );
  }
}
