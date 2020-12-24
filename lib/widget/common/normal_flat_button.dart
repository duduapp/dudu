import 'package:dudu/l10n/l10n.dart';


import 'package:dudu/public.dart';
import 'package:flutter/material.dart';

class NormalFlatButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;


  const NormalFlatButton({Key key, this.text, this.onPressed}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return FlatButton(

      child: Text(
        text,

      ),
      onPressed: onPressed,
    );
  }
}

class NormalCancelFlatButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NormalFlatButton(
      text: S.of(context).cancel,
      onPressed: () => AppNavigate.pop(),
    );
  }
}

