import 'package:dudu/l10n/l10n.dart';
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
        title: Text(S.of(context).new_message_notification),
      ),
      body: Column(
        children: <Widget>[
          ProviderSettingCell(
            providerKey: 'show_notifications',
            title: S.of(context).new_message_notification,
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
              title: S.of(context).turn_to,
              type: SettingType.bool,
            ),
            ProviderSettingCell(
              providerKey: 'show_notifications.favourite',
              title: S.of(context).favorites,
              type: SettingType.bool,
            ),
            ProviderSettingCell(
              providerKey: 'show_notifications.follow_request',
              title: S.of(context).follow_request,
              type: SettingType.bool,
            ),
            ProviderSettingCell(
              providerKey: 'show_notifications.follow',
              title: S.of(context).follow,
              type: SettingType.bool,
            ),
            ProviderSettingCell(
              providerKey: 'show_notifications.mention',
              title: S.of(context).mention,
              type: SettingType.bool,
            ),
            ProviderSettingCell(
              providerKey: 'show_notifications.poll',
              title: S.of(context).vote,
              type: SettingType.bool,
            )
          ]
        ],
      ),
    );
  }
}
