import 'package:flutter/material.dart';

class BottomSheetItem extends StatelessWidget {
  final String text;
  final Function onTap;
  final double height;
  final bool safeArea;
  final bool bottomBorder;

  BottomSheetItem({this.text, this.onTap, this.height, this.safeArea = false,this.bottomBorder});

  @override
  Widget build(BuildContext context) {
    if (safeArea) {
      return InkWell(
        onTap: onTap,
        child: SafeArea(
          child: Container(

            height: height,
            width: double.infinity,
            //  color: Theme.of(context).bottomSheetTheme.backgroundColor,
            padding: EdgeInsets.all(12),
            child: Align(
              child: Text(
                text,
                style: TextStyle(fontSize: 16),
              ),
              alignment: Alignment.topCenter,
            ),
          ),
        ),
      );
    } else {
      return InkWell(
        onTap: onTap,
        child: Container(

          height: height,
          width: double.infinity,
          //  color: Theme.of(context).bottomSheetTheme.backgroundColor,
          padding: EdgeInsets.all(12),
          child: Align(
            child: Text(
              text,
              style: TextStyle(fontSize: 16),
            ),
            alignment: Alignment.topCenter,
          ),
        ),
      );
    }
  }
}
