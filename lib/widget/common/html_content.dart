import 'package:fastodon/models/json_serializable/article_item.dart';
import 'package:fastodon/pages/timeline/hashtag_timeline.dart';
import 'package:fastodon/pages/user_profile/user_profile.dart';
import 'package:html/dom.dart' as dom;
import 'package:fastodon/pages/webview/inner_browser.dart';
import 'package:fastodon/public.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class HtmlContent extends StatelessWidget {
  final String content;
  final StatusItemData statusData;

  HtmlContent(this.content, {this.statusData});

  @override
  Widget build(BuildContext context) {
    return Html(
      data: content,
      onLinkTap: _onLinkTap,
    );
  }

  _onLinkTap(String link, dom.Node node) {
    var htmlClass = node.attributes['class'] ?? '';
    if (htmlClass.contains('mention')) {
      if (statusData != null) {
        if (htmlClass.contains('u-url')) {
          List mentions = statusData.mentions;
          for (var mention in mentions) {
            if (mention['url'] == link) {
              AppNavigate.push(
                  null,
                  UserProfile(
                    accountId: mention['id'],
                  ));
              return;
            }
          }
        }
        if (htmlClass.contains('hashtag')) {
          List tags = statusData.tags;
          var tagInUrl = link.substring(link.lastIndexOf('/') + 1);
          for (var tag in tags) {
            if (tag['name'] == tagInUrl) {
              AppNavigate.push(null, HashtagTimeline(tagInUrl));
              return;
            }
          }
        }
      }
    }
    AppNavigate.push(null, InnerBrowser(link));
  }
}
