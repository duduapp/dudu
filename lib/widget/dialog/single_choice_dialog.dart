import 'package:fastodon/utils/app_navigate.dart';
import 'package:flutter/material.dart';

class SingleChoiceDialog extends StatelessWidget {
  final Widget title;
  final List<String> choices;
  final Function onChoose;

  SingleChoiceDialog({this.title, this.choices, this.onChoose});

  @override
  Widget build(BuildContext context) {
    List<Widget> choicesW = [];
    for (String choice in choices) {
      choicesW.add(InkWell(
        child: Row(
          children: <Widget>[
            Radio(
              value: 'unlisted',
            ),
            Text('不公开')
          ],
        ),
        onTap: () {
          onChoose(choice);
          AppNavigate.pop(context);
        },
      ));
    }
    return AlertDialog(
      title: title,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: choicesW,
      ),
    );
  }
}
