import 'package:dudu/l10n/l10n.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/models/task/check_new_task.dart';
import 'package:dudu/utils/i18n_util.dart';
import 'package:dudu/widget/common/custom_app_bar.dart';
import 'package:dudu/widget/setting/setting_cell.dart';
import 'package:flutter/material.dart';

class SettingContent extends StatefulWidget {
  @override
  _SettingContentState createState() => _SettingContentState();
}

class _SettingContentState extends State<SettingContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(S.of(context).display_setting),
      ),
      body: ListView(
        children: [
          if (I18nUtil.isZh(context))
            ProviderSettingCell(
              providerKey: 'zan_or_shoucang',
              title: S.of(context).like_favorite_switch,
              options: ['0', '1'],
              displayOptions: [
                S.of(context).currently_showing_likes,
                S.of(context).currently_showing_favorites
              ],
              type: SettingType.string,
            ),
          ProviderSettingCell(
            providerKey: 'red_dot_notfication',
            type: SettingType.bool,
            title: S.of(context).red_dot_notfication,
            onPressed: (value){
              if (value) {
                CheckNewTask.start();
              } else {
                CheckNewTask.stop();
              }
            },
          )
        ],
      ),
    );
  }
}
