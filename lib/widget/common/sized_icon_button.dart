import 'package:flutter/material.dart';

class SizedIconButton extends StatelessWidget {
  final Icon icon;
  final Function onPressed;
  final double width;
  final double height;

  SizedIconButton({this.icon,this.onPressed,this.width = 32,this.height = 50});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: IconButton(
        padding: new EdgeInsets.all(0.0),
        icon: icon,
        onPressed: onPressed,
      ),
    );
  }
}



