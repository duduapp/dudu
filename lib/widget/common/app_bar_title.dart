import 'package:flutter/material.dart';

class DropDownTitle extends StatelessWidget {
  final String title;
  final bool expand;
  final bool showIcon;
  final bool iconMaintainSize;

  DropDownTitle({this.title, this.expand = false, this.showIcon = false, this.iconMaintainSize = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 5, 5, 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 17),
          ),
          Visibility(
              maintainSize: iconMaintainSize,
              maintainAnimation: iconMaintainSize,
              maintainState: iconMaintainSize,
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
