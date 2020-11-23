import 'package:dudu/api/accounts_api.dart';
import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/models/logined_user.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/pages/setting/common_block_list.dart';
import 'package:dudu/pages/setting/filter/common_filter_list.dart';
import 'package:dudu/pages/setting/setting_notification.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/url_util.dart';
import 'package:dudu/widget/common/custom_app_bar.dart';
import 'package:dudu/widget/setting/setting_cell.dart';
import 'package:flutter/material.dart';

class AccountSetting extends StatefulWidget {
  @override
  _AccountSettingState createState() => _AccountSettingState();
}

class _AccountSettingState extends State<AccountSetting> {
  @override
  void initState() {
    super.initState();
  //  LoginedUser().requestPreference(); #有些可以获取，有些却不能写入，只在登录时请求
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text('账号设置'),
      ),
      body: ListView(
        children: <Widget>[
          SettingCell(
            leftIcon: Icon(IconFont.notification),
            title: '通知设置',
            onPress: () => AppNavigate.push(SettingNotification()),
          ),
          SettingCell(
            leftIcon: Icon(IconFont.volumeOff),
            title: '被隐藏的用户',
            onPress: () => AppNavigate.push(CommonBlockList(BlockType.mute)),
          ),
          SettingCell(
            leftIcon: Icon(IconFont.block),
            title: '被屏蔽的用户',
            onPress: () => AppNavigate.push(CommonBlockList(BlockType.block)),
          ),
          SettingCell(
            leftIcon: Icon(IconFont.www),
            title: '被隐藏的实例',
            onPress: () =>
                AppNavigate.push(CommonBlockList(BlockType.hideDomain)),
          ),
          Container(
            child: Text('发布'),
            padding: EdgeInsets.all(8),
          ),
          ProviderSettingCell(
            providerKey: 'default_post_privacy',
            leftIcon: Icon(IconFont.earth),
            title: '嘟文默认可见范围',
            type: SettingType.string,
            displayOptions: ['公开', '不公开', '仅关注者'],
            options: ['public', 'unlisted', 'private'],
            onPressed: _changePrivacy,
          ),
          ProviderSettingCell(
            providerKey: 'make_media_sensitive',
            leftIcon: Icon(IconFont.eye),
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
                AppNavigate.push(CommonFilterList(FilterType.public)),
          ),
          SettingCell(
            title: '消息',
            onPress: () =>
                AppNavigate.push(CommonFilterList(FilterType.notifications)),
          ),
          SettingCell(
            title: '主页',
            onPress: () => AppNavigate.push(CommonFilterList(FilterType.home)),
          ),
          SettingCell(
            title: '对话',
            onPress: () =>
                AppNavigate.push(CommonFilterList(FilterType.thread)),
          ),
          Container(
            child: Text('账号操作（需在系统默认的浏览器中完成操作）'),
            padding: EdgeInsets.all(8),
          ),
          SettingCell(
            title: '修改密码',
            onPress: () =>
                UrlUtil.openUrl(LoginedUser().host+'/auth/edit'),
          ),
          SettingCell(
            title: '备份数据',
            onPress: () =>
                UrlUtil.openUrl(LoginedUser().host+'/settings/export'),
          ),
          SettingCell(
            title: '导入数据',
            onPress: () =>
                UrlUtil.openUrl(LoginedUser().host+'/settings/import'),
          ),
          SettingCell(
            title: '注销账号',
            onPress: () =>
                UrlUtil.openUrl(LoginedUser().host+'/settings/delete'),
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
