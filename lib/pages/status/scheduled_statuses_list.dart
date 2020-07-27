import 'package:fastodon/api/scheduled_statuses_api.dart';
import 'package:fastodon/models/provider/result_list_provider.dart';
import 'package:fastodon/pages/status/new_status.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/widget/listview/provider_easyrefresh_listview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/material_header.dart';
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
      appBar: AppBar(
        title: Text('定时嘟文'),
        centerTitle: false,
      ),
      body: ChangeNotifierProvider<ResultListProvider>(
          create: (context) => ResultListProvider(
                requestUrl: ScheduledStatusesApi.url,
                buildRow: _buildRow,
              ),
          builder: (context, snapshot) {
            providerContext = context;
            return ProviderEasyRefreshListView(
              header: MaterialHeader(),
              //    triggerRefreshEvent: [EventBusKey.scheduledStatusDeleted,EventBusKey.scheduledStatusPublished],
            );
          }),
    );
  }

  Widget _buildRow(int idx, List data,ResultListProvider provider) {
    var row = data[idx];
    return InkWell(
      child: Container(
        padding: EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            Text(row['params']['text'], style: TextStyle(fontSize: 18)),
            Spacer(),
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                AppNavigate.push(
                    context,
                    NewStatus(
                      scheduleInfo: row,
                    ),routeType: RouterType.material);
              },
            ),
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () async {
                await ScheduledStatusesApi.delete(row['id']);
                provider.removeByIdWithAnimation(row['id']);
              },
            )
          ],
        ),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor))),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
