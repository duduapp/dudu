import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/material.dart';

class EmojiKeyboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EmojiPicker(
      rows: 3,
      columns: 7,
      recommendKeywords: ["racing", "horse"],
      numRecommended: 10,
      onEmojiSelected: (emoji, category) {
        print(emoji);
      },
    );
  }
}
