import 'package:fastodon/api/accounts_api.dart';
import 'package:fastodon/models/logined_user.dart';
import 'package:fastodon/models/provider/settings_provider.dart';
import 'package:fastodon/pages/setting/common_block_list.dart';
import 'package:fastodon/pages/setting/filter/common_filter_list.dart';
import 'package:fastodon/pages/setting/setting_notification.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/widget/setting/setting_cell.dart';
import 'package:flutter/material.dart';

class AccountSetting extends StatefulWidget {
  @override
  _AccountSettingState createState() => _AccountSettingState();
}

class _AccountSettingState extends State<AccountSetting> {
  @override
  void initState() {
    super.initState();
    LoginedUser().requestPreference();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('账号设置'),
        centerTitle: false,
      ),
      body: ListView(
        children: <Widget>[
          SettingCell(
            leftIcon: Icon(Icons.notifications),
            title: '通知设置',
            onPress: () => AppNavigate.push(context, SettingNotification()),
          ),
          SettingCell(
            leftIcon: Icon(Icons.volume_off),
            title: '被隐藏的用户',
            onPress: () =>
                AppNavigate.push(context, CommonBlockList(BlockType.mute)),
          ),
          SettingCell(
            leftIcon: Icon(Icons.block),
            title: '被屏蔽的用户',
            onPress: () =>
                AppNavigate.push(context, CommonBlockList(BlockType.block)),
          ),
          SettingCell(
            leftIcon: Icon(Icons.volume_off),
            title: '隐藏域名',
            onPress: () => AppNavigate.push(
                context, CommonBlockList(BlockType.hideDomain)),
          ),
          Container(
            child: Text('发布'),
            padding: EdgeInsets.all(8),
          ),
          ProviderSettingCell(
            providerKey: 'default_post_privacy',
            leftIcon: Icon(Icons.public),
            title: '嘟文默认可见范围',
            type: SettingType.string,
            displayOptions: ['公开', '不公开', '仅关注者'],
            options: ['public', 'unlisted', 'private'],
            onPressed: _changePrivacy,
          ),
          ProviderSettingCell(
            providerKey: 'make_media_sensitive',
            leftIcon: Icon(Icons.remove_red_eye),
            title: '自动标记媒体为敏感内容',
            type: SettingType.bool,
            onPressed: (value) {
              var params = {
                'source': {'sensitive': value}
              };
              AccountsApi.updateCredentials(params);
            },
          ),
          Container(
            child: Text('时间轴'),
            padding: EdgeInsets.all(8),
          ),
          ProviderSettingCell(
            providerKey: 'show_thumbnails',
            title: '显示预览图',
            type: SettingType.bool,
          ),
          ProviderSettingCell(
            providerKey: 'always_show_sensitive',
            title: '总是显示所有敏感媒体内容',
            type: SettingType.bool,
          ),
          ProviderSettingCell(
            providerKey: 'always_expand_tools',
            title: '始终扩展标有内容警告的嘟文',
            type: SettingType.bool,
          ),
          Container(
            child: Text('过滤器'),
            padding: EdgeInsets.all(8),
          ),
          SettingCell(
            title: '公共时间轴',
            onPress: () =>
                AppNavigate.push(context, CommonFilterList(FilterType.public)),
          ),
          SettingCell(
            title: '通知',
            onPress: () => AppNavigate.push(
                context, CommonFilterList(FilterType.notifications)),
          ),
          SettingCell(
            title: '主页',
            onPress: () =>
                AppNavigate.push(context, CommonFilterList(FilterType.home)),
          ),
          SettingCell(
            title: '对话',
            onPress: () =>
                AppNavigate.push(context, CommonFilterList(FilterType.thread)),
          ),
          SizedBox(
            height: 30,
          )
        ],
      ),
    );
  }

  _changePrivacy(dynamic privacy) {
    var params = {
      'source': {'privacy': privacy}
    };
    AccountsApi.updateCredentials(params);
  }
}
