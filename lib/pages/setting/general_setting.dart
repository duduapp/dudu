import 'package:fastodon/pages/setting/setting_cell.dart';
import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';

class GeneralSetting extends StatefulWidget {
  @override
  _GeneralSettingState createState() => _GeneralSettingState();
}

class _GeneralSettingState extends State<GeneralSetting> {
  String textScale;

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
  }

  _getTextScale() {
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('通用设置'),
        centerTitle: false,
      ),
      body: Column(
        children: <Widget>[
          SettingCell(
            leftIcon: Icon(Icons.color_lens),
            title: '应用主题',
            onPress: () => showDialog(
                context: context,
                builder: (_) => ThemeConsumer(child: ThemeDialog(title: Text('选择主题'),hasDescription: false,))),
          ),
          SettingCell(
            leftIcon: Icon(Icons.font_download),
            title: '字体大小',

          )
        ],
      ),
    );
  }
}
