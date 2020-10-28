

import 'dart:convert';

import 'package:dudu/models/json_serializable/notificate_item.dart';
import 'package:dudu/pages/status/status_detail.dart';
import 'package:dudu/public.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationUtil {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  static init() async{
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid = AndroidInitializationSettings('ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }



  static Future  onDidReceiveLocalNotification(int id, String title, String body, String payload) {

  }

  static Future selectNotification(String payload) async {
    if (payload != null) {
      NotificationItem item = NotificationItem.fromJson(json.decode(payload));
      if (item.type == 'mention' || item.type == 'poll') {
        AppNavigate.push(StatusDetail(item.status,false));
      }
    }
  }

  static show({String title,String body,String payload}) {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'channel0', '通知通道', '',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
     flutterLocalNotificationsPlugin.show(
        0, title, body, platformChannelSpecifics,
        payload: payload);
  }

}