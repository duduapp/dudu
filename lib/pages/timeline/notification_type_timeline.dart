import 'package:dudu/api/timeline_api.dart';
import 'package:dudu/constant/api.dart';
import 'package:dudu/models/notification/NotificationType.dart';
import 'package:dudu/utils/request.dart';
import 'package:dudu/utils/view/list_view_util.dart';
import 'package:dudu/widget/common/custom_app_bar.dart';
import 'package:dudu/widget/timeline/timeline_content.dart';
import 'package:flutter/material.dart';

class NotificationTypeTimeline extends StatelessWidget {
  final String title;
  final String url;

  NotificationTypeTimeline(this.url,this.title);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(title),
      ),
      body: TimelineContent(
        url: url,
        tag: 'none',
        rowBuilder: ListViewUtil.notificationRowFunction(),
        prefixId: false,
      ),
    );
  }
}
