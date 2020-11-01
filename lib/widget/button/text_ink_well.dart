import 'package:flutter/material.dart';

class TextInkWell extends StatelessWidget {
  final String text;
  final EdgeInsets padding;
  final Function onTap;

  TextInkWell({this.text, this.padding = const EdgeInsets.all(8), this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Text(
          text,
          style: TextStyle(
              fontSize: 13,
              color: onTap == null
                  ? Theme.of(context).textTheme.bodyText1.color
                  : Theme.of(context).buttonColor),
        ),
      ),
    );
  }
}
