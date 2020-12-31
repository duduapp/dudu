import 'dart:io';

import 'package:dudu/l10n/l10n.dart';
import 'package:dudu/models/json_serializable/article_item.dart';
import 'package:dudu/models/json_serializable/owner_account.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/pages/timeline/hashtag_timeline.dart';
import 'package:dudu/pages/user_profile/user_profile.dart';
import 'package:dudu/pages/webview/inner_browser.dart';
import 'package:dudu/plugin/flutter_html/flutter_html.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/provider_util.dart';
import 'package:dudu/utils/translate_util.dart';
import 'package:dudu/utils/url_util.dart';
import 'package:dudu/utils/view/status_action_util.dart';
import 'package:dudu/widget/button/text_ink_well.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;

class HtmlContent extends StatefulWidget {
  final String content;
  final StatusItemData statusData;
  final List emojis;
  final foldConetent;
  final checkToTranslate;

  HtmlContent(this.content,
      {this.statusData,
      this.emojis = const [],
      this.foldConetent = true,
      this.checkToTranslate = false});

  @override
  _HtmlContentState createState() => _HtmlContentState();
}

class _HtmlContentState extends State<HtmlContent>
    with TickerProviderStateMixin {
  bool expanded = true;
  bool needExpand = false;
  bool isTranslating = false;
  String translateResult;
  bool showTranslate = false;

  @override
  void initState() {
    if (widget.foldConetent &&
        StringUtil.removeAllHtmlTags(widget.content).length > 300 &&
        !SettingsProvider().get('always_expand_tools')) {
      expanded = false;
      needExpand = true;
    }

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _checkToShowTranslate());
    super.initState();
  }

  _checkToShowTranslate() {
    if (widget.checkToTranslate) {
      var langCode = Localizations.localeOf(context).languageCode;
      var systemLocal = Platform.localeName;
      showTranslate = (langCode.startsWith('zh') &&
              !StringUtil.estimateChinese(widget.content)) ||
          (langCode.startsWith('en') &&
              !StringUtil.isEnglishLetters(widget.content)) ||
          !(systemLocal.startsWith('zh') || systemLocal.startsWith('en'));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      alignment: Alignment.topCenter,
      vsync: this,
      curve: Curves.fastOutSlowIn,
      duration: Duration(milliseconds: 200),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Html(
            data: expanded
                ? widget.content
                : widget.content.length > 300
                    ? widget.content.substring(0, 300) + '...'
                    : widget.content,
            onLinkTap: _onLinkTap,
            padding: EdgeInsets.all(0),
            blockSpacing: 0,
            emojis: widget.emojis,
            renderNewlines: true,
            useRichText: true //widget.emojis.isEmpty,
            ),
        if (needExpand && widget.content.length > 300)
          OutlineButton(
            child: Text(
              expanded
                  ? S.of(context).collapse_content
                  : S.of(context).display_more,
              style: TextStyle(fontSize: 12),
            ),
            onPressed: () {
              setState(() {
                expanded = !expanded;
              });
            },
          ),
        if (showTranslate && translateResult == null)
          TextInkWell(
            text: S.of(context).translate_toot,
            onTap: _startTranslate,
            padding: EdgeInsets.only(bottom: 8),
          ),
        if (translateResult != null)
          if (isTranslating) CupertinoActivityIndicator(),
        if (translateResult != null) ...[
          TextInkWell(
              padding: EdgeInsets.only(bottom: 4),
              text: S.of(context).translate_by(TranslateUtil.engineName[
                  int.parse(SettingsProvider().get('translate_engine'))]),
              onTap: () => AppNavigate.push(InnerBrowser(
                  TranslateUtil.engineUrl[
                      int.parse(SettingsProvider().get('translate_engine'))]))),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(translateResult),
          )
        ]
      ]),
    );
  }

  _startTranslate() async {
    setState(() {
      isTranslating = true;
    });
    var engine = SettingsProvider().get('translate_engine');
    if (engine == '0')
      translateResult = await TranslateUtil.translateByGoogle(
          StringUtil.removeAllHtmlTags(widget.content));
    else
      translateResult = await TranslateUtil.translateByGoogleCn(
          StringUtil.removeAllHtmlTags(widget.content));
    setState(() {
      isTranslating = false;
    });
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
              AppNavigate.push(UserProfile(
                OwnerAccount.fromJson(mention),
                hostUrl: ProviderUtil.hostUrl(context),
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
