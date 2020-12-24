import 'package:dudu/l10n/l10n.dart';
import 'dart:async';
import 'dart:convert';

import 'package:dudu/models/logined_user.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/plugin/event_source.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/compute_util.dart';
import 'package:dudu/utils/i18n_util.dart';
import 'package:dudu/utils/notification_util.dart';
import 'package:flutter/foundation.dart';
import 'package:nav_router/nav_router.dart';

import '../json_serializable/notificate_item.dart';

class NotificationTask {
  static StreamSubscription userNotificationEvents;
  static EventSource events;

  static enable() async {
    userNotificationEvents?.cancel();
    events?.close();
    var settings = SettingsProvider().settings;
    if (!settings['show_notifications']) return;
    //NotificationUtil.init();

    LoginedUser user = LoginedUser();
    events = EventSource(Uri.parse(user.getHost() + '/api/v1/streaming/user'),
        headers: {'Authorization': user.getToken()});
    userNotificationEvents = events.events.listen((MessageEvent message) async {
      if (message.name == 'notification') {
        NotificationItem item = NotificationItem.fromJson(
            (await compute(parseJsonString, message.data)) as Map);

        if (settings['show_notifications'] == true &&
            settings['show_notifications.${item.type}'] == true) {
          String title = '';
          String body = '';
          switch (item.type) {
            case 'reblog':
              title = S
                  .of(navGK.currentState.overlay.context)
                  .boot_your_tool(StringUtil.displayName(item.account));
              body = StringUtil.removeAllHtmlTags(item.status.content);
              break;
            case 'favourite':
              title = I18nUtil.isZh(navGK.currentState.overlay.context)
                  ? ('${StringUtil.displayName(item.account)}${StringUtil.getZanString()}了你的嘟嘟')
                  : S
                      .of(navGK.currentState.overlay.context)
                      .favorited_your_toot(
                          StringUtil.displayName(item.account));
              body = StringUtil.removeAllHtmlTags(item.status.content);
              break;
            case 'follow':
              title = S.of(navGK.currentState.overlay.context).started_following_you(StringUtil.displayName(item.account));
              break;
            case 'mention':
              title = S.of(navGK.currentState.overlay.context).mentions_you(StringUtil.displayName(item.account));
              body = StringUtil.removeAllHtmlTags(item.status.content);
              break;
            case 'poll':
              title = S
                  .of(navGK.currentState.overlay.context)
                  .the_poll_you_initiated_or_participated_in_has_been_completed;
              body = StringUtil.removeAllHtmlTags(item.status.content);
              break;
            case 'follow_request':
              title = S.of(navGK.currentState.overlay.context).request_to_follow_you(StringUtil.displayName(item.account));
              break;
          }
          NotificationUtil.show(
              title: title, body: body, payload: message.data);
        }
      }
    });
  }

  static disable() {
    userNotificationEvents?.cancel();
  }
}
