import 'package:fastodon/models/provider/settings_provider.dart';
import 'package:fastodon/widget/dialog/single_choice_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingCell extends StatelessWidget {
  SettingCell(
      {Key key,
      this.title,
      this.leftIcon = const Opacity(
        child: Icon(Icons.remove),
        opacity: 0,
      ),
      this.onPress,
      this.tail = const Icon(
        Icons.keyboard_arrow_right,
        size: 30,
      ),
      this.subTitle})
      : super(key: key);
  final String title;
  final String subTitle;
  final Widget leftIcon;
  final Function onPress;
  final Widget tail;

  @override
  Widget build(BuildContext context) {
    Widget cont;
    if (subTitle != null) {
      cont = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(title, style: TextStyle(fontSize: 15)),
          Text(
            subTitle,
            style: TextStyle(fontSize: 12),
          )
        ],
      );
    } else {
      cont = Text(title, style: TextStyle(fontSize: 15));
    }

    return Container(
      color: Theme.of(context).primaryColor,
      child: InkWell(
        onTap: () => onPress(),
        child: Column(
          children: <Widget>[
            Ink(
              height: subTitle == null ? 55 : 60,
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  leftIcon,
                  SizedBox(width: 10),
                  cont,
                  if (tail != null) Spacer(),
                  if (tail != null) tail
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 50),
              child: Divider(height: 1.0),
            )
          ],
        ),
      ),
    );
  }
}

class ProviderSettingCell extends StatefulWidget {
  final String providerKey;
  final SettingType type;
  final String title;
  final Widget leftIcon;
  final List<String> options;
  final List<String> displayOptions;
  final Function(dynamic value) onPressed;
  final Widget dialogTitle;

  const ProviderSettingCell(
      {Key key,
      @required this.providerKey,
      @required this.type,
      @required this.title,
      this.leftIcon = const Opacity(
        child: Icon(Icons.remove),
        opacity: 0,
      ),
      this.options,
      this.displayOptions,
      this.onPressed,this.dialogTitle})
      : super(key: key);

  @override
  _ProviderSettingCellState createState() => _ProviderSettingCellState();
}

class _ProviderSettingCellState extends State<ProviderSettingCell> {
  bool boolValue;
  String stringValue;

  @override
  void initState() {
    SettingsProvider provider =
        Provider.of<SettingsProvider>(context, listen: false);
    switch (widget.type) {
      case SettingType.string:
        stringValue = provider.get(widget.providerKey);
        break;
      case SettingType.bool:
        boolValue = provider.get(widget.providerKey);
        break;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget tail;
    switch (widget.type) {
      case SettingType.string:
        tail = Container();
        break;
      case SettingType.bool:
        tail = Switch(
          value: boolValue ?? false,
          onChanged: _onPressBool,
        );
        break;
    }

    return SettingCell(
      title: widget.title,
      leftIcon: widget.leftIcon,
      onPress: widget.type == SettingType.string
          ? _onPressString
          : widget.type == SettingType.bool
              ? () => _onPressBool(!boolValue)
              : null,
      subTitle: widget.type == SettingType.string
          ? widget.displayOptions[widget.options.indexOf(stringValue)] ?? ''
          : null,
      tail: tail,
    );
  }

  _onPressString() {
    SettingsProvider provider =
        Provider.of<SettingsProvider>(context, listen: false);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SingleChoiceDialog(
            title: widget.dialogTitle ?? Text(widget.title),
            choices: widget.displayOptions,
            onChoose: (idx) {
              provider.update(widget.providerKey, widget.options[idx]);
              setState(() {
                stringValue = widget.options[idx];
              });
            },
            groupValue: widget.options.indexOf(stringValue),
          );
        });
    if (widget.onPressed != null) {
      widget.onPressed(stringValue);
    }
  }

  _onPressBool(bool value) {
    SettingsProvider provider =
        Provider.of<SettingsProvider>(context, listen: false);
    if (value != null) {
      boolValue = value;
    } else {
      boolValue = !boolValue;
    }
    setState(() {});
    provider.update(widget.providerKey, boolValue);
    if (widget.onPressed != null) {
      widget.onPressed(boolValue);
    }
  }
}

class SettingCellText extends StatelessWidget {
  final Widget text;
  final Function onPressed;

  SettingCellText({this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        color: Theme.of(context).primaryColor,
        child: Center(child: text),
      ),
    );
  }
}
