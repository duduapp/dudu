import 'package:flutter/material.dart';

class DropDownTitle extends StatelessWidget {
  final String title;
  final bool expand;
  final bool showIcon;

  DropDownTitle({this.title, this.expand = false, this.showIcon = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 5, 5, 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 17),
          ),
          Visibility(
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              visible: showIcon,
              child: Icon(
            expand ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            size: 20,
          )),
        ],
      ),
    );
  }
}
