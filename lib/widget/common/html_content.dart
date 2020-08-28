import 'package:dudu/models/json_serializable/article_item.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/pages/timeline/hashtag_timeline.dart';
import 'package:dudu/pages/user_profile/user_profile.dart';
import 'package:dudu/plugin/flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:dudu/pages/webview/inner_browser.dart';
import 'package:dudu/public.dart';
import 'package:flutter/material.dart';

class HtmlContent extends StatefulWidget {
  final String content;
  final StatusItemData statusData;
  final List emojis;
  final foldConetent;

  HtmlContent(this.content, {this.statusData,this.emojis = const [],this.foldConetent = true});

  @override
  _HtmlContentState createState() => _HtmlContentState();
}

class _HtmlContentState extends State<HtmlContent> with TickerProviderStateMixin{
  bool expanded = true;
  bool needExpand = false;

  @override
  void initState() {
    if (widget.foldConetent && StringUtil.removeAllHtmlTags(widget.content).length > 500 && !SettingsProvider().get('always_expand_tools')) {
      expanded = false;
      needExpand = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      alignment: Alignment.topCenter,
      vsync: this,
       curve: Curves.fastOutSlowIn,
      duration: Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Html(
          data: expanded? widget.content : widget.content.substring(0,500)+'...',
          onLinkTap: _onLinkTap,
          padding: EdgeInsets.all(0),
          blockSpacing: 5,
          emojis: widget.emojis,
          renderNewlines: true,
          useRichText: true//widget.emojis.isEmpty,
        ),
        if (needExpand)
          OutlineButton(child: Text(expanded?'折叠内容':'显示更多'),onPressed: () {setState(() {
            expanded = !expanded;
          });},)
      ]),
    );
  }

  _onLinkTap(String link, dom.Node node) {
    var linkText = '';
    //最多遍历两层
    for (var childNode in node.nodes) {
      if (childNode is dom.Text) {
        linkText += childNode.text;
      } else {
        for (var innerNode in childNode.nodes) {
          if (innerNode is dom.Text) {
            linkText += innerNode.text;
          }
        }
      }
    }
    var htmlClass = node.attributes['class'] ?? '';
    if (htmlClass.contains('mention')) {
      if (widget.statusData != null) {
        if (htmlClass.contains('u-url')) {
          List mentions = widget.statusData.mentions;
          for (var mention in mentions) {
            if (mention['url'] == link) {
              AppNavigate.push(
                  UserProfile(
                    accountId: mention['id'],
                  ));
              return;
            }
          }
        }
        if (htmlClass.contains('hashtag')) {
          List tags = widget.statusData.tags;
          var tagInUrl = link.substring(link.lastIndexOf('/') + 1);
          for (var tag in tags) {
            if (tag['name'] == tagInUrl.toLowerCase()) {
              AppNavigate.push(HashtagTimeline(tagInUrl));
              return;
            }
          }
        }
      } else {
        if (htmlClass.contains('hashtag')) {
          var tagInUrl = link.substring(link.lastIndexOf('/') + 1);
          AppNavigate.push(HashtagTimeline(tagInUrl));
          return;
        }
      }
    }

    if (linkText.startsWith('#')) {
      AppNavigate.push(HashtagTimeline(linkText.substring(1)));
      return;
    }

    AppNavigate.push(InnerBrowser(link));

  }
}
