
import 'package:dudu/models/json_serializable/article_item.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/pages/status/status_detail.dart';
import 'package:dudu/public.dart';
import 'package:dudu/widget/common/html_content.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusItemText extends StatefulWidget {
  final StatusItemData data;
  final navigateToDetail;

  StatusItemText(this.data,{this.navigateToDetail = false});

  @override
  _StatusItemTextState createState() => _StatusItemTextState();
}

class _StatusItemTextState extends State<StatusItemText> {
  bool showMore = false;

  @override
  void initState() {
    super.initState();

    SettingsProvider provider =
        Provider.of<SettingsProvider>(context, listen: false);
    showMore = provider.get('always_expand_tools');
  }

  _onShowMorePressed() {
    setState(() {
      showMore = !showMore;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        HtmlContent(
           widget.data.spoilerText.isEmpty
              ? widget.data.content.trim()
              : widget.data.spoilerText.trim(),statusData: widget.data,emojis: widget.data.emojis,
        ),
        if (widget.data.spoilerText.isNotEmpty)
          OutlineButton(
            child: Text(showMore ? '折叠内容' : '显示更多',style: TextStyle(fontWeight: FontWeight.normal),),
            onPressed: _onShowMorePressed,
          ),
        if (showMore)
          HtmlContent(
             widget.data.content,statusData: widget.data,emojis: widget.data.emojis,
          )
      ]),
    );
  }
}


