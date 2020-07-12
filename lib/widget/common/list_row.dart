import 'package:flutter/material.dart';


class ListRow extends StatelessWidget {
  ListRow({this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8),
      child: child,
      decoration: BoxDecoration(
          border:
          Border(bottom: BorderSide(color: Theme.of(context).buttonColor))),
    );
  }
}
