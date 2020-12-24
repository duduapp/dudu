import 'package:dudu/l10n/l10n.dart';
import 'package:flutter/material.dart';

class EmptyView extends StatelessWidget {
  final String text;

  EmptyView({this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).backgroundColor,
        child: Center(child: Text(text?? S.of(context).no_content_yet)));
  }
}

class EmptyViewWithHeight extends StatelessWidget {
  final String text;
  final double height;

  EmptyViewWithHeight({this.text,this.height = 200});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: height,
        color: Theme.of(context).backgroundColor,
        child: Center(child: Text(text?? S.of(context).no_content_yet)));
  }
}
