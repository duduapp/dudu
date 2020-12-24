import 'package:dudu/l10n/l10n.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/public.dart';
import 'package:flutter/material.dart';

class NotificationDisplayTypeDialog extends StatefulWidget {
  @override
  _NotificationDisplayTypeDialogState createState() =>
      _NotificationDisplayTypeDialogState();
}

class _NotificationDisplayTypeDialogState
    extends State<NotificationDisplayTypeDialog> {
  List displayType;

  @override
  void initState() {
    displayType =
        SettingsProvider.getWithCurrentContext('notification_display_type');
    super.initState();
  }

  Widget typeRow(String text, String keyInProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(text),
        Checkbox(
          onChanged: (value) {
            if (value) {
              displayType.remove(keyInProvider);
              displayType.add(keyInProvider);
            } else {
              displayType.remove(keyInProvider);
            }
            setState(() {});
          },
          value: displayType.contains(keyInProvider),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 250,
        padding: EdgeInsets.fromLTRB(15,15,15,0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            typeRow(S.of(context).mention, 'mention'),
            typeRow(S.of(context).turn_to, 'reblog'),
            typeRow(SettingsProvider().get('zan_or_shoucang') == '0' ? '赞':S.of(context).favorites, 'favourite'),
            typeRow(S.of(context).attention, 'follow'),
            typeRow(S.of(context).follow_request, 'follow_request'),
            typeRow(S.of(context).vote, 'poll'),
            Divider(thickness: 0,),
            InkWell(
              onTap: () {
                SettingsProvider.updateWithCurrentContext('notification_display_type', displayType);
                AppNavigate.pop(param: displayType);
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(bottom: 10,top: 5),
                child: Center(
                  child: Text(
                    S.of(context).determine,
                    style: TextStyle(color: Theme.of(context).buttonColor),
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
