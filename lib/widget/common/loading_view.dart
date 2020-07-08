import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  final String text;
  final Color color;// background Color

  LoadingView({this.text,this.color});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: color ?? Theme.of(context).backgroundColor,
        child: Center(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  child: CircularProgressIndicator(),
                  width: 50,
                  height: 50,
                ),
                if (text != null)
                Text(text)
              ]),
        ),
      ),
    );
  }
}
