

import 'package:flutter/material.dart';


typedef EmojiClicked = Function(String emoji);

class EmojiWidget extends StatelessWidget {
  final EmojiClicked onChoose;

  EmojiWidget({this.onChoose});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

