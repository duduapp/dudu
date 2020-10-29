import 'package:dudu/models/json_serializable/article_item.dart';
import 'package:dudu/models/json_serializable/owner_account.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/pages/user_profile/user_profile.dart';
import 'package:dudu/utils/app_navigate.dart';
import 'package:dudu/utils/date_until.dart';
import 'package:dudu/utils/provider_util.dart';
import 'package:dudu/utils/string_until.dart';
import 'package:dudu/utils/view/status_action_util.dart';
import 'package:dudu/widget/status/text_with_emoji.dart';
import 'package:flutter/material.dart';

import '../other/avatar.dart';

class StatusItemAccount extends StatelessWidget {
  final OwnerAccount account;

  final String createdAt;
  final Widget action;
  final bool noNavigateOnClick;
  final StatusItemData statusData;
  final double padding;

  StatusItemAccount(this.account,
      {this.createdAt, this.action, this.statusData,this.noNavigateOnClick = false,this.padding = 8});

  @override
  Widget build(BuildContext context) {
    if (!noNavigateOnClick) {
      return InkWell(
        onTap: noNavigateOnClick
            ? null
            : () {
          if (createdAt == null)
            AppNavigate.push(UserProfile(account,hostUrl: ProviderUtil.hostUrl(context),));
        }, // 用作搜索页时，整个页面可点击
        child: accountWidget(context),
      );
    } else {
      return accountWidget(context);
    }

  }

  Widget accountWidget(BuildContext context) {
    return  Padding(
      padding: EdgeInsets.all(padding),
      child: Row(
        children: <Widget>[
          Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
              child: Avatar(account: account,width: 40,height: 40,navigateToDetail: !noNavigateOnClick,)),
          Expanded(
            child: Container(
              height: 40,
              //ns  margin: EdgeInsets.only(top: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        child: TextWithEmoji(
                          text: StringUtil.displayName(account),
                          emojis: account.emojis,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color:
                              Theme.of(context).textTheme.bodyText1.color),
                        ),
                        flex: 2,
                      ),
                      if (createdAt != null)
                        Flexible(
                          child: Text(DateUntil.dateTime(createdAt),
                              style: TextStyle(
                                  fontSize: 13, color: Theme.of(context).accentColor),
                              overflow: TextOverflow.ellipsis),
                        )
                    ],
                  ),
                  Flexible(
                    child: Text(
                      '@' + account.acct,
                      style: TextStyle(fontSize: 12, color: Theme.of(context).accentColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
            ),
          ),
          if (action != null) action
        ],
      ),
    );
  }
}

class SubStatusItemHeader extends StatelessWidget {
  final StatusItemData data;

  SubStatusItemHeader(this.data);

  @override
  Widget build(BuildContext context) {
    var textSclae = SettingsProvider.getWithCurrentContext('text_scale');
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
//          Expanded(child: Text(StringUtil.displayName(data.account),maxLines: 1,overflow: TextOverflow.ellipsis,)),
//          Expanded(child: Text( '@' + data.account.username,maxLines: 1,overflow: TextOverflow.ellipsis)),
//          Spacer(),

          Expanded(
              child: RichText(
            maxLines: 1,
            textScaleFactor: 1.0 + 0.18 * double.parse(textSclae),
            text: TextSpan(
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[850]),
                children: <InlineSpan>[
                  ...TextWithEmoji.getTextSpans(
                      text: StringUtil.displayName(data.account),
                      emojis: data.account.emojis,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[850])),
                  TextSpan(
                      text: '@' + data.account.username,
                      style: TextStyle(
                          fontSize: 15, color: Theme.of(context).accentColor))
                ]),
            overflow: TextOverflow.ellipsis,
          )),

          Text(DateUntil.dateTime(data.createdAt),
              style: TextStyle(fontSize: 13, color: Theme.of(context).accentColor),
              overflow: TextOverflow.ellipsis)
        ],
      ),
    );
  }
}
