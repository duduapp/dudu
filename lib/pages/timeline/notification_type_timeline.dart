import 'package:dudu/constant/api.dart';
import 'package:dudu/models/notification/NotificationType.dart';
import 'package:dudu/utils/request.dart';
import 'package:dudu/utils/view/list_view_util.dart';
import 'package:dudu/widget/common/custom_app_bar.dart';
import 'package:dudu/widget/timeline/timeline_content.dart';
import 'package:flutter/material.dart';

class NotificationTypeTimeline extends StatelessWidget {
  final String type;

  NotificationTypeTimeline(this.type);

  @override
  Widget build(BuildContext context) {
    var notificationTypes = ['follow', 'favourite', 'reblog', 'mention', 'poll', 'follow_request'];
    notificationTypes.remove(type);

    var url = Request.buildGetUrl(Api.Notifications, {'exclude_types':notificationTypes});
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(NotificationType.notificationDescription[type]),
      ),
      body: TimelineContent(
        url: url,
        tag: type,
        rowBuilder: ListViewUtil.notificationRowFunction(),
        prefixId: false,
      ),
    );
  }
}
