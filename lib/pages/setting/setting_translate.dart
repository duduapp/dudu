import 'package:dudu/l10n/l10n.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/utils/translate_util.dart';
import 'package:dudu/widget/common/custom_app_bar.dart';
import 'package:dudu/widget/setting/setting_cell.dart';
import 'package:flutter/material.dart';

class SettingTranslate extends StatefulWidget {
  @override
  _SettingTranslateState createState() => _SettingTranslateState();
}

class _SettingTranslateState extends State<SettingTranslate> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(S.of(context).translate_setting),
      ),
      body: ListView(
        children: [
          ProviderSettingCell(
              providerKey: 'translate_engine',
              type: SettingType.string,
              options: ['0','1'],
              displayOptions: TranslateUtil.engineName,
              title: S.of(context).translate_engine)
        ],
      ),
    );
  }
}
