import 'package:fastodon/utils/app_navigate.dart';
import 'package:flutter/material.dart';

class SingleChoiceDialog extends StatelessWidget {
  final Widget title;
  final List<String> choices;
  final Function onChoose;
  final int groupValue;

  SingleChoiceDialog({this.title, this.choices, this.onChoose,this.groupValue});

  @override
  Widget build(BuildContext context) {
    List<Widget> choicesW = [];
    for (String choice in choices) {
      choicesW.add(InkWell(
        child: Row(
          children: <Widget>[
            Radio(
              value: choices.indexOf(choice),
              groupValue: groupValue,
            ),
            Text(choice)
          ],
        ),
        onTap: () {
          onChoose(choices.indexOf(choice));
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
