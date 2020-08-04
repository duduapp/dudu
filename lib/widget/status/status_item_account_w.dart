import 'package:fastodon/models/json_serializable/article_item.dart';
import 'package:fastodon/models/json_serializable/owner_account.dart';
import 'package:fastodon/pages/webview/inner_browser.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/utils/view/status_action_util.dart';
import 'package:fastodon/widget/other/avatar.dart';
import 'package:fastodon/widget/status/text_with_emoji.dart';
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
                            fontSize: 16,
                            color:
                                Theme.of(context).textTheme.bodyText1.color)),
                    TextSpan(text: " "),
                    TextSpan(
                        text: '@' + status.account.acct,
                        style: TextStyle(
                            color: Theme.of(context).textTheme.bodyText1.color))
                  ]),
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
                            fontSize: 12)),
                    TextSpan(text: " "),
                    ...fromWidgetSpans(context)
                  ]),
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
              Icons.expand_more,
              color: Theme.of(context).accentColor,
              size: 30,
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
                TextStyle(fontSize: 12, color: Theme.of(context).accentColor)),
        TextSpan(text: " ")
      ]);
      if (appWebsite == null) {
        spans.add(TextSpan(
            text: status.application?.name,
            style:
                TextStyle(fontSize: 12, color: Theme.of(context).accentColor)));
      } else {
        spans.add(TextSpan(
            text: status.application?.name,
            recognizer: TapGestureRecognizer()
              ..onTap = () => AppNavigate.push(InnerBrowser(appWebsite)),
            style:
                TextStyle(fontSize: 12, color: Theme.of(context).buttonColor)));
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
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
