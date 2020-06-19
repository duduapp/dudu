import 'package:flutter/material.dart';

class BottomSheetItem extends StatelessWidget {
  final String text;
  final Function onTap;
  final double height;

  BottomSheetItem({this.text,this.onTap,this.height});

  @override
  Widget build(BuildContext context) {
    return           InkWell(

      onTap: onTap,
      child: Container(
        height: height,
        width: double.infinity,
      //  color: Theme.of(context).bottomSheetTheme.backgroundColor,
        padding: EdgeInsets.all(12),
        child: Align(child: Text(text,style: TextStyle(fontSize: 16),),alignment: Alignment.topCenter,),
      ),
    );
  }
}
