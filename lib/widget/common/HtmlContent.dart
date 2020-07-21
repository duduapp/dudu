import 'package:fastodon/pages/webview/inner_browser.dart';
import 'package:fastodon/public.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class HtmlContent extends StatelessWidget {
  final String content;

  HtmlContent(this.content);

  @override
  Widget build(BuildContext context) {
    return Html(
      data: content,
      onLinkTap: _onLinkTap ,
    );
  }

  _onLinkTap(String link) {
    if (link.startsWith('@')) {
      print(link);
    } else if (StringUtil.isUrl(link)) {
      AppNavigate.push(null, InnerBrowser(link));
    }
  }
}
