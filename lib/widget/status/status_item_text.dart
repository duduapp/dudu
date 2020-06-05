import 'package:fastodon/models/article_item.dart';
import 'package:fastodon/pages/timeline/status_detail.dart';
import 'package:fastodon/public.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class StatusItemText extends StatefulWidget {
  final StatusItemData data;

  StatusItemText(this.data);

  @override
  _StatusItemTextState createState() => _StatusItemTextState();
}

class _StatusItemTextState extends State<StatusItemText> {
  bool showMore = false;

  _onShowMorePressed() {
    setState(() {
      showMore = !showMore;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => AppNavigate.push(context, StatusDetail(widget.data)),
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Html(
            data: widget.data.spoilerText.isEmpty ? widget.data.content.trim() : widget.data.spoilerText.trim(),
            blockSpacing: 0,
            onLinkTap: (url) {
              print('点击到的链接：' + url);
            },
          ),
          if (widget.data.spoilerText.isNotEmpty) OutlineButton(child: Text(showMore ? '折叠内容' : '显示更多'),onPressed: _onShowMorePressed,),
          if (showMore) Html(data: widget.data.content,blockSpacing: 0,)
        ]),
      ),
    );
  }
}
