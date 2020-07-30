import 'package:fastodon/constant/app_config.dart';
import 'package:fastodon/models/json_serializable/article_item.dart';
import 'package:fastodon/pages/webview/inner_browser.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/utils/date_until.dart';
import 'package:flutter/material.dart';

class StatusItemPrimaryBottom extends StatelessWidget {
  final StatusItemData data;

  const StatusItemPrimaryBottom(this.data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color splashColor = Theme.of(context).splashColor;
    return DefaultTextStyle.merge(
      style: TextStyle(color: splashColor),
      child: Padding(
        padding: const EdgeInsets.only(top: 15),
        child: Row(
          children: <Widget>[
            Icon(
              AppConfig.visibilityIcons[data.visibility],
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              DateUntil.absoluteTime(data.createdAt),
              style: TextStyle(),
            ),
            if (data.application != null)
              ...[
            Text('・'),
            InkWell(
                child: Text(
                  data.application.name,
                  style: TextStyle(color: data.application.website != null ? Theme.of(context).buttonColor: splashColor),
                ),
                onTap: data.application.website != null
                    ? () => AppNavigate.push(
                         InnerBrowser(data.application.website))
                    : null)]
          ],
        ),
      ),
    );
  }
}
