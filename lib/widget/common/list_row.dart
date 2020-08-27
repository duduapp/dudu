import 'package:flutter/material.dart';


class ListRow extends StatelessWidget {
  ListRow({this.child,this.padding = 8});
  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Ink(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      child: child,
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          border:
          Border(bottom: BorderSide(color: Theme.of(context).dividerColor,))),
    );
  }
}
