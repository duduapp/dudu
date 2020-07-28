import 'package:cached_network_image/cached_network_image.dart';
import 'package:fastodon/models/provider/settings_provider.dart';
import 'package:fastodon/utils/screen.dart';
import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart';

class TextWithEmoji extends StatelessWidget {
  final String text;
  final List emojis;
  final int maxLines;
  final TextOverflow overflow;
  final TextStyle style;

  const TextWithEmoji({Key key, this.text, this.emojis,this.maxLines,this.style,this.overflow = TextOverflow.ellipsis})
      : super(key: key);
  static RegExp regExp = RegExp(r':[a-zA-Z0-9_]+:', multiLine: true);

  static List<InlineSpan> getTextSpans(
  {String text, List emojis,TextStyle style}) {
    if (emojis.length == 0 || text.trim().isEmpty) {
      return [TextSpan(text: text)];
    }

    var matches = regExp.allMatches(text);
    if (matches.length == 0) {
      return [TextSpan(text: text)];
    } else {
      List<InlineSpan> widgets = [];
      List<int> splitInt = [0];
      for (var match in matches) {
        splitInt.add(match.start);
        splitInt.add(match.end);
      }
      if (splitInt.last != text.length) {
        splitInt.add(text.length);
      }
      for (int i = 0; i < splitInt.length - 1; i++) {
        var subStr = text.substring(splitInt[i], splitInt[i + 1]);
        if (subStr.isEmpty) continue;
        // emoji
        if (subStr.startsWith(':') && subStr.endsWith(':')) {
          var shortcode = subStr.substring(
              subStr.indexOf(':') + 1, subStr.lastIndexOf(':'));
          for (var emoji in emojis) {
            if (emoji['shortcode'] == shortcode) {
              widgets.add(WidgetSpan(
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CachedNetworkImage(imageUrl: emoji['url']))));
              break;
            }
          }
        } else {
          if (style != null)
            widgets.add(TextSpan(text: subStr,style: style));
          else
            widgets.add(TextSpan(text: subStr));
        }
      }

      return widgets;
    }
  }

  @override
  Widget build(BuildContext context) {
    var textScale = SettingsProvider.getWithCurrentContext('text_scale');
    if (emojis.length == 0) {
      return Text(
        text,
        maxLines: maxLines,
        overflow: overflow,
        style: style,
      );
    }
    var matches = regExp.allMatches(text);
    if (matches.length == 0) {
      return Text(text,maxLines: maxLines,overflow: overflow,style: style,);
    } else {
      // 参考https://stackoverflow.com/questions/51379194/richtext-does-not-style-text-as-expected
      return RichText(
        textScaleFactor: Screen.scaleFromSetting(textScale),
        maxLines: maxLines,
        overflow: overflow,
        text:
            TextSpan(children: getTextSpans(text:text, emojis:emojis),style: style ?? DefaultTextStyle.of(context).style),
      );
    }
  }
}
