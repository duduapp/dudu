import 'package:flutter/material.dart';

class TextInkWell extends StatelessWidget {
  final String text;
  final EdgeInsets padding;
  final Function onTap;
  final Color activeColor;

  TextInkWell({this.text, this.padding = const EdgeInsets.all(8), this.onTap,this.activeColor});

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
                  : (this.activeColor ?? Theme.of(context).buttonColor)),
        ),
      ),
    );
  }
}
