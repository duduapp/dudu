


import 'package:fastodon/pages/setting/setting_cell.dart';
import 'package:flutter/material.dart';

class AccountSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('账号设置'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SettingCell(
              leftIcon: Icon(Icons.volume_off),
              title: '被隐藏的用户',
            ),
            SettingCell(
              leftIcon: Icon(Icons.block),
              title: '被屏蔽的用户',
            ),
            SettingCell(
              leftIcon: Icon(Icons.volume_off),
              title: '隐藏域名',
            ),
            Container(child: Text('发布'),padding: EdgeInsets.all(8),),
            SettingCell(
              leftIcon: Icon(Icons.public),
              title: '嘟文默认可见范围',
            ),
            SettingCell(
              leftIcon: Icon(Icons.remove_red_eye),
              title: '自动标记媒体为敏感内容',
              tail: Switch(value: false,),
            ),
            Container(child: Text('时间轴'),padding: EdgeInsets.all(8),),
            SettingCell(
              title: '显示预览图',
            ),
            SettingCell(
              title: '总是显示所有敏感媒体内容',
            ),
            SettingCell(
              title: '始终扩展标有内容警告的嘟文',
            ),
            Container(child: Text('过滤器'),padding: EdgeInsets.all(8),),
            SettingCell(
              title: '公共时间轴',
            ),
            SettingCell(
              title: '通知',
            ),
            SettingCell(
              title: '主页',
            ),
            SettingCell(
              title: '对话',
            ),
          ],
        ),
      ),
    );
  }
}
