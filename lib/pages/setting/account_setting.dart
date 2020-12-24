import 'package:dudu/l10n/l10n.dart';
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
        title: Text(S.of(context).account_settings),
      ),
      body: ListView(
        children: <Widget>[
          SettingCell(
            leftIcon: Icon(IconFont.notification),
            title: S.of(context).notification_settings,
            onPress: () => AppNavigate.push(SettingNotification()),
          ),
          SettingCell(
            leftIcon: Icon(IconFont.volumeOff),
            title: S.of(context).hidden_user,
            onPress: () => AppNavigate.push(CommonBlockList(BlockType.mute)),
          ),
          SettingCell(
            leftIcon: Icon(IconFont.block),
            title: S.of(context).blocked_user,
            onPress: () => AppNavigate.push(CommonBlockList(BlockType.block)),
          ),
          SettingCell(
            leftIcon: Icon(IconFont.www),
            title: S.of(context).hidden_instance,
            onPress: () =>
                AppNavigate.push(CommonBlockList(BlockType.hideDomain)),
          ),
          Container(
            child: Text(S.of(context).release),
            padding: EdgeInsets.all(8),
          ),
          ProviderSettingCell(
            providerKey: 'default_post_privacy',
            leftIcon: Icon(IconFont.earth),
            title: S.of(context).default_visible_range,
            type: SettingType.string,
            displayOptions: [S.of(context).public, S.of(context).private, S.of(context).followers_only],
            options: ['public', 'unlisted', 'private'],
            onPressed: _changePrivacy,
          ),
          ProviderSettingCell(
            providerKey: 'make_media_sensitive',
            leftIcon: Icon(IconFont.eye),
            title: S.of(context).automatically_mark_media_as_sensitive,
            type: SettingType.bool,
            onPressed: (value) {
              var params = {
                'source': {'sensitive': value}
              };
              AccountsApi.updateCredentials(params);
            },
          ),
          Container(
            child: Text(S.of(context).timeline),
            padding: EdgeInsets.all(8),
          ),
          ProviderSettingCell(
            providerKey: 'show_thumbnails',
            title: S.of(context).show_preview,
            type: SettingType.bool,
          ),
          ProviderSettingCell(
            providerKey: 'always_show_sensitive',
            title: S.of(context).always_show_all_sensitive_media_content,
            type: SettingType.bool,
          ),
          ProviderSettingCell(
            providerKey: 'always_expand_tools',
            title: S.of(context).always_expand_toots_marked_with_content_warnings,
            type: SettingType.bool,
          ),
          Container(
            child: Text(S.of(context).filter),
            padding: EdgeInsets.all(8),
          ),
          SettingCell(
            title: S.of(context).public_timeline,
            onPress: () =>
                AppNavigate.push(CommonFilterList(FilterType.public)),
          ),
          SettingCell(
            title: S.of(context).news,
            onPress: () =>
                AppNavigate.push(CommonFilterList(FilterType.notifications)),
          ),
          SettingCell(
            title: S.of(context).home_page,
            onPress: () => AppNavigate.push(CommonFilterList(FilterType.home)),
          ),
          SettingCell(
            title: S.of(context).dialogue,
            onPress: () =>
                AppNavigate.push(CommonFilterList(FilterType.thread)),
          ),
          Container(
            child: Text(S.of(context).account_operation),
            padding: EdgeInsets.all(8),
          ),
          SettingCell(
            title: S.of(context).change_password,
            onPress: () =>
                UrlUtil.openUrl(LoginedUser().host+'/auth/edit'),
          ),
          SettingCell(
            title: S.of(context).backup_data,
            onPress: () =>
                UrlUtil.openUrl(LoginedUser().host+'/settings/export'),
          ),
          SettingCell(
            title: S.of(context).import_data,
            onPress: () =>
                UrlUtil.openUrl(LoginedUser().host+'/settings/import'),
          ),
          SettingCell(
            title: S.of(context).logout,
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
