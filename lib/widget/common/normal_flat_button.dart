

import 'package:fastodon/public.dart';
import 'package:fastodon/utils/themes.dart';
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
        style: TextStyle(fontWeight: FontWeight.normal),
      ),
      onPressed: onPressed,
    );
  }
}

class NormalCancelFlatButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NormalFlatButton(
      text: '取消',
      onPressed: () => AppNavigate.pop(),
    );
  }
}

