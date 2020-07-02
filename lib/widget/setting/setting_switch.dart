import 'package:fastodon/api/accounts_api.dart';
import 'package:fastodon/models/my_account.dart';
import 'package:flutter/material.dart';

enum SettingSwitchType {
  sensitive,
  showMedia,
  showSensitive,
  expandSpoilers
}

class SettingSwitch extends StatefulWidget {
  final MyAccount myAccount;
  final SettingSwitchType type;

  SettingSwitch(this.myAccount,this.type);

  @override
  _SettingSwitchState createState() => _SettingSwitchState();
}

class _SettingSwitchState extends State<SettingSwitch> {
  bool value;

  @override
  void initState() {
    super.initState();
    switch(widget.type) {
      case SettingSwitchType.sensitive:
        value = widget.myAccount.account.source.sensitive;
        break;
      case SettingSwitchType.showMedia:
        value = widget.myAccount.preferences.showMedia;
        break;
      case SettingSwitchType.showSensitive:
        value = widget.myAccount.preferences.showSensitive;
        break;
      case SettingSwitchType.expandSpoilers:
        value = widget.myAccount.preferences.expandSpoilers;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: _onChanged,
    );
  }

  _onChanged(bool value) {
    setState(() {
      this.value = value;
    });
    switch(widget.type) {
      case SettingSwitchType.sensitive:
        var params = {
          'source':{
            'sensitive' : value
          }
        };
        AccountsApi.updateCredentials(params);

        break;
      case SettingSwitchType.showMedia:
        widget.myAccount.preferences.setShowMedia(value);
        break;
      case SettingSwitchType.showSensitive:
        widget.myAccount.preferences.setShowSensitive(value);
        break;
      case SettingSwitchType.expandSpoilers:
        widget.myAccount.preferences.setExpandSpoilers(value);
        break;
    }
  }
}
