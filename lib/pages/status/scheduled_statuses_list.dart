import 'package:fastodon/api/scheduled_statuses_api.dart';
import 'package:fastodon/pages/status/new_status.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/widget/listview/easyrefresh_listview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_header.dart';

class ScheduledStatusesList extends StatefulWidget {
  @override
  _ScheduledStatusesListState createState() => _ScheduledStatusesListState();
}

class _ScheduledStatusesListState extends State<ScheduledStatusesList> {
  EasyRefreshController _controller = EasyRefreshController();

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
      body: EasyRefreshListView(
        requestUrl: ScheduledStatusesApi.url,
        buildRow: _buildRow,
        controller: _controller,
        header: MaterialHeader(),
        triggerRefreshEvent: [EventBusKey.scheduledStatusDeleted,EventBusKey.scheduledStatusPublished],
      ),
    );
  }

  Widget _buildRow(int idx, List data) {
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
                    ));
              },
            ),
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () async {
                await ScheduledStatusesApi.delete(row['id']);
                eventBus.emit(EventBusKey.scheduledStatusDeleted);
              },
            )
          ],
        ),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(color: Theme.of(context).buttonColor))),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
