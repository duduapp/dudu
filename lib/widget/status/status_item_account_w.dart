import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/models/json_serializable/article_item.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/pages/webview/inner_browser.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/view/status_action_util.dart';
import 'package:dudu/widget/other/avatar.dart';
import 'package:dudu/widget/status/text_with_emoji.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class StatusItemAccountW extends StatelessWidget {
  final StatusItemData status;
  final bool subStatus;
  final bool primary;

  const StatusItemAccountW({Key key, this.status, this.subStatus,this.primary})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var textScale =
    SettingsProvider.getWithCurrentContext('text_scale', listen: true);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Avatar(
          width: 40,
          height: 40,
          account: status.account,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8,bottom: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                RichText(
                  text: TextSpan(children: [
                    ...TextWithEmoji.getTextSpans(
                        text: StringUtil.displayName(status.account),
                        emojis: status.account.emojis,
                        style: TextStyle(
                            fontSize: 13.5,
                            color:
                                Theme.of(context).textTheme.bodyText1.color)),
                    TextSpan(text: " "),
                    TextSpan(
                        text: '@' + status.account.acct,
                        style: TextStyle(
                            color: Theme.of(context).textTheme.bodyText1.color))
                  ]),
                  textScaleFactor: ScreenUtil.scaleFromSetting(textScale),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(
                  height: 3,
                ),
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: primary? DateUntil.absoluteTime(status.createdAt):DateUntil.dateTime(status.createdAt),
                        style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 11)),
                    TextSpan(text: " "),
                    ...fromWidgetSpans(context)
                  ]),
                  textScaleFactor: ScreenUtil.scaleFromSetting(textScale),
                )
              ],
            ),
          ),
        ),
        SizedBox(
          width: 25,
          height: 25,
          child: IconButton(
            onPressed: () {
              StatusActionUtil.showBottomSheetAction(
                  context, status, subStatus);
            },
            focusColor: Colors.red,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            padding: EdgeInsets.all(0),
            icon: Icon(
              IconFont.expandMore,
              color: Theme.of(context).accentColor,
              size: 20,
            ),
          ),
        )
      ],
    );
  }

  List fromWidgetSpans(BuildContext context) {
    List spans = [];
    var appName = status.application?.name;
    var appWebsite = status.application?.website;
    if (appName != null) {
      spans.addAll([
        TextSpan(
            text: '来自',
            style:
                TextStyle(fontSize: 11, color: Theme.of(context).accentColor)),
        TextSpan(text: " ")
      ]);
      if (appWebsite == null) {
        spans.add(TextSpan(
            text: status.application?.name,
            style:
                TextStyle(fontSize: 11, color: Theme.of(context).accentColor)));
      } else {
        spans.add(TextSpan(
            text: status.application?.name,
            recognizer: TapGestureRecognizer()
              ..onTap = () => AppNavigate.push(InnerBrowser(appWebsite)),
            style:
                TextStyle(fontSize: 11, color: Color.fromRGBO(80, 125, 175, 1))));
      }
      return spans;
    } else {
      return [];
    }
  }
}

class SubStatusAccountW extends StatelessWidget {
  final StatusItemData status;

  const SubStatusAccountW({Key key, this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(children: [
          ...TextWithEmoji.getTextSpans(
              text: StringUtil.displayName(status.account),
              emojis: status.account.emojis,
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).accentColor)),
          TextSpan(text: " "),
          TextSpan(
              text: '@' + status.account.acct,
              style:
                  TextStyle(color: Theme.of(context).accentColor))
        ]),
        maxLines: 1,
        overflow: TextOverflow.visible,
      ),
    );
  }
}
