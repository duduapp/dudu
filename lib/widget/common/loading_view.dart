import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  final String text;

  LoadingView({this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
