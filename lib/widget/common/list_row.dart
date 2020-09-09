import 'package:flutter/material.dart';


class ListRow extends StatelessWidget {
  ListRow({this.child,this.padding = 8});
  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      child: Material(color: Theme.of(context).primaryColor,child: child),
      decoration: BoxDecoration(

          border:
          Border(bottom: BorderSide(color: Theme.of(context).dividerColor,))),
    );
  }
}
