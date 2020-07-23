import 'package:fastodon/models/json_serializable/article_item.dart';
import 'package:fastodon/pages/timeline/hashtag_timeline.dart';
import 'package:fastodon/pages/user_profile/user_profile.dart';
import 'package:fastodon/plugin/flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:fastodon/pages/webview/inner_browser.dart';
import 'package:fastodon/public.dart';
import 'package:flutter/material.dart';

class HtmlContent extends StatefulWidget {
  final String content;
  final StatusItemData statusData;

  HtmlContent(this.content, {this.statusData});

  @override
  _HtmlContentState createState() => _HtmlContentState();
}

class _HtmlContentState extends State<HtmlContent> with TickerProviderStateMixin{
  bool expanded = true;
  bool needExpand = false;

  @override
  void initState() {
    if (StringUtil.removeAllHtmlTags(widget.content).length > 500) {
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
        ),
        if (needExpand)
          OutlineButton(child: Text(expanded?'折叠内容':'显示更多'),onPressed: () {setState(() {
            expanded = !expanded;
          });},)
      ]),
    );
  }

  _onLinkTap(String link, dom.Node node) {
    var linkText = node.nodes[0]?.text;
    var htmlClass = node.attributes['class'] ?? '';
    if (htmlClass.contains('mention')) {
      if (widget.statusData != null) {
        if (htmlClass.contains('u-url')) {
          List mentions = widget.statusData.mentions;
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
//        if (htmlClass.contains('hashtag')) {
//          List tags = widget.statusData.tags;
//          var tagInUrl = link.substring(link.lastIndexOf('/') + 1);
//          for (var tag in tags) {
//            if (tag['name'] == tagInUrl.toLowerCase()) {
//              AppNavigate.push(null, HashtagTimeline(tagInUrl));
//              return;
//            }
//          }
//        }
      } else {
        if (htmlClass.contains('hashtag')) {
          var tagInUrl = link.substring(link.lastIndexOf('/') + 1);
          AppNavigate.push(null, HashtagTimeline(tagInUrl));
          return;
        }
      }
    } else {
      if (linkText.startsWith('#')) {
        AppNavigate.push(null, HashtagTimeline(linkText.substring(1)));
        return;
      }
    }
    AppNavigate.push(null, InnerBrowser(link));

  }
}
