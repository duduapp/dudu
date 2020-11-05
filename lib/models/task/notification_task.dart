import 'dart:async';
import 'dart:convert';

import 'package:dudu/models/logined_user.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/plugin/event_source.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/notification_util.dart';

import '../json_serializable/notificate_item.dart';

class NotificationTask {
  static StreamSubscription userNotificationEvents;

  static enable() async {
    userNotificationEvents?.cancel();
    var settings = SettingsProvider().settings;
    if (!settings['show_notifications']) return;
    //NotificationUtil.init();

    LoginedUser user = LoginedUser();
    final events = EventSource(
        Uri.parse(user.getHost() + '/api/v1/streaming/user'),
        headers: {'Authorization': user.getToken()});
    userNotificationEvents = events.events.listen((MessageEvent message) {
      if (message.name == 'notification') {
        NotificationItem item =
            NotificationItem.fromJson(json.decode(message.data));


        if (settings['show_notifications'] == true && settings['show_notifications.${item.type}'] == true) {
          String title = '';
          String body = '';
          switch(item.type) {
            case 'reblog':
              title = '${StringUtil.displayName(item.account)}转发了你的嘟嘟';
              body = StringUtil.removeAllHtmlTags(item.status.content);
              break;
            case 'favourite':
              title = '${StringUtil.displayName(item.account)}收藏了你的嘟嘟';
              body = StringUtil.removeAllHtmlTags(item.status.content);
              break;
            case 'follow':
              title = '${StringUtil.displayName(item.account)}开始关注你了';
              break;
            case 'mention':
              title = '${StringUtil.displayName(item.account)}提到你了';
              body = StringUtil.removeAllHtmlTags(item.status.content);
              break;
            case 'poll':
              title = '你发起或参与的投票已经完成了';
              body = StringUtil.removeAllHtmlTags(item.status.content);
              break;
            case 'follow_request':
              title = '${StringUtil.displayName(item.account)}请求关注你';
              break;
          }
          NotificationUtil.show(title: title,body: body,payload: message.data);
        }
      }
    });
  }
  
  static disable() {
    userNotificationEvents?.cancel();
  }
}
