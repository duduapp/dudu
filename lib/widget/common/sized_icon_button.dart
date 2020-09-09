import 'package:flutter/material.dart';

class SizedIconButton extends StatelessWidget {
  final Icon icon;
  final Function onPressed;
  final double width;
  final double height;

  SizedIconButton({this.icon,this.onPressed,this.width = 32,this.height = 50});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: icon,
      onPressed: onPressed,
    );
  }
}

class ClickableIconButton extends StatelessWidget {

  final Widget icon;
  final Function onTap;

  const ClickableIconButton({Key key, this.icon, this.onTap}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: icon,
      onTap: onTap,
    );
  }
}




