import 'package:flutter/material.dart';

class BottomNavigationItem extends StatelessWidget {
  final Widget icon;
  final Widget title;

  const BottomNavigationItem({Key key, this.icon, this.title}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        icon,
        title
      ],
    );
  }
}
