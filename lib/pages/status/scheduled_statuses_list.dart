import 'package:dudu/api/scheduled_statuses_api.dart';
import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/models/provider/result_list_provider.dart';
import 'package:dudu/pages/status/new_status.dart';
import 'package:dudu/public.dart';
import 'package:dudu/widget/common/custom_app_bar.dart';
import 'package:dudu/widget/common/list_row.dart';
import 'package:dudu/widget/listview/provider_easyrefresh_listview.dart';
import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart';
import 'package:provider/provider.dart';

class ScheduledStatusesList extends StatefulWidget {
  @override
  _ScheduledStatusesListState createState() => _ScheduledStatusesListState();
}

class _ScheduledStatusesListState extends State<ScheduledStatusesList> {
  BuildContext providerContext;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text('定时嘟文'),
      ),
      body: ChangeNotifierProvider<ResultListProvider>(
          create: (context) => ResultListProvider(
                requestUrl: ScheduledStatusesApi.url,
                buildRow: _buildRow,
              ),
          builder: (context, snapshot) {
            providerContext = context;
            return ProviderEasyRefreshListView(
              useAnimatedList: false,
              //    triggerRefreshEvent: [EventBusKey.scheduledStatusDeleted,EventBusKey.scheduledStatusPublished],
            );
          }),
    );
  }

  Widget _buildRow(int idx, List data,ResultListProvider provider) {
    var row = data[idx];
    return ListRow(
      padding: 0,
      child: Padding(
        padding: EdgeInsets.fromLTRB(14,6,6,6),
        child: Row(
          children: <Widget>[
            Text(row['params']['text'], style: TextStyle(fontSize: 14)),
            Spacer(),
            IconButton(
              icon: Icon(IconFont.edit),
              onPressed: () {
                AppNavigate.push(
                    NewStatus(
                      scheduleInfo: row,
                    ),routeType: RouterType.material);
              },
            ),
            IconButton(
              icon: Icon(IconFont.clear),
              onPressed: () async {
                await ScheduledStatusesApi.delete(row['id']);
                provider.removeByIdWithAnimation(row['id']);
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
