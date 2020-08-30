import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/models/task/notification_task.dart';
import 'package:dudu/widget/common/custom_app_bar.dart';
import 'package:dudu/widget/setting/setting_cell.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingNotification extends StatefulWidget {
  @override
  _SettingNotificationState createState() => _SettingNotificationState();
}

class _SettingNotificationState extends State<SettingNotification> {
  bool enableNotification = true;

  @override
  void initState() {
    // TODO: implement initState
    SettingsProvider provider =
        Provider.of<SettingsProvider>(context, listen: false);
    enableNotification = provider.get('show_notifications');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text('新消息通知'),
      ),
      body: Column(
        children: <Widget>[
          ProviderSettingCell(
            providerKey: 'show_notifications',
            title: '新消息通知',
            type: SettingType.bool,
            onPressed: (value) {
              setState(() {
                enableNotification = value;
              });
              if (value) {
                NotificationTask.enable();
              } else {
                NotificationTask.disable();
              }
            },
          ),
          SizedBox(
            height: 10,
          ),
          if (enableNotification) ...[
            ProviderSettingCell(
              providerKey: 'show_notifications.reblog',
              title: '转嘟',
              type: SettingType.bool,
            ),
            ProviderSettingCell(
              providerKey: 'show_notifications.favourite',
              title: '收藏',
              type: SettingType.bool,
            ),
            ProviderSettingCell(
              providerKey: 'show_notifications.follow_request',
              title: '关注请求',
              type: SettingType.bool,
            ),
            ProviderSettingCell(
              providerKey: 'show_notifications.follow',
              title: '关注',
              type: SettingType.bool,
            ),
            ProviderSettingCell(
              providerKey: 'show_notifications.mention',
              title: '提及',
              type: SettingType.bool,
            ),
            ProviderSettingCell(
              providerKey: 'show_notifications.poll',
              title: '投票',
              type: SettingType.bool,
            )
          ]
        ],
      ),
    );
  }
}
