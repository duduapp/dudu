import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  final String text;
  final Color color;// background Color
  final double height;

  LoadingView({this.text,this.color,this.height});

  @override
  Widget build(BuildContext context) {
     Widget loadView =  Container(
      color: color ?? Theme.of(context).backgroundColor,
      child: Center(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                child: CircularProgressIndicator(strokeWidth: 2,),
                width: 50,
                height: 50,
              ),
              if (text != null)
                Text(text)
            ]),
      ),
    );
     return height == null ? loadView : SingleChildScrollView(child: SizedBox(height: height,child: loadView,),);
  }
}

