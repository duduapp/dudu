import 'package:dudu/models/provider/settings_provider.dart';
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
      appBar: CustomAppBar(title: Text('显示设置'),),
      body: ListView(
        children: [
          ProviderSettingCell(
            providerKey: 'zan_or_shoucang',
            title: '赞/收藏 切换',
            options: ['0', '1'],
            displayOptions: ['当前显示赞', '当前显示收藏'],
            type: SettingType.string,
          )
        ],
      ),
    );
  }
}
