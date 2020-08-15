import 'package:fastodon/api/accounts_api.dart';
import 'package:fastodon/models/json_serializable/article_item.dart';
import 'package:fastodon/models/json_serializable/owner_account.dart';
import 'package:fastodon/models/provider/result_list_provider.dart';
import 'package:fastodon/pages/user_profile/user_report_message.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/widget/common/list_row.dart';
import 'package:fastodon/widget/listview/provider_easyrefresh_listview.dart';
import 'package:fastodon/widget/status/status_item_content.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserReport extends StatefulWidget {
  final OwnerAccount account;
  final String fromStatusId;

  UserReport({Key key, this.account,this.fromStatusId}) : super(key: key);

  @override
  _UserReportState createState() => _UserReportState();
}

class _UserReportState extends State<UserReport> {
  List<String> chooseStatues = [];

  @override
  void initState() {
    if (widget.fromStatusId != null)
    chooseStatues.add(widget.fromStatusId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('举报@${widget.account.acct}的滥用行为',overflow: TextOverflow.fade,),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ChangeNotifierProvider<ResultListProvider>(
              create: (context) => ResultListProvider(
                requestUrl: '${AccountsApi.url}/${widget.account.id}/statuses',
                buildRow: _buildRow
              ),
              child: ProviderEasyRefreshListView(),
            ),
          ),
          SafeArea(

            child: Row(
              children: <Widget>[
                Spacer(),
                OutlineButton(textColor:Theme.of(context).buttonColor,child: Text('取消'),onPressed: (){AppNavigate.pop();},),
                SizedBox(width: 5,),
                RaisedButton(textColor:Colors.white,child: Text('继续'),onPressed: () {
                  AppNavigate.push(UserReportMessage(chooseStatuses: chooseStatues,account: widget.account,));
                },),
                SizedBox(width: 20,)
              ],
            ),
          )
        ],
      ),
    );


  }

  Widget _buildRow(int idx,List data,ResultListProvider provider) {
    StatusItemData itemData = StatusItemData.fromJson(data[idx]);
    return ListRow(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(flex:7,child: StatusItemContent(itemData)),
          Flexible(
            flex: 3,
            child: Column(
              children: <Widget>[
                Text(DateUntil.dateTime(itemData.createdAt)),
                Checkbox(value: chooseStatues.contains(itemData.id),onChanged: (bool) {
                  if (bool) {
                    chooseStatues.add(itemData.id);
                  } else {
                    chooseStatues.remove(itemData.id);
                  }
                  setState(() {

                  });
                },)
              ],

            ),
          )
        ],
      ),
    );

  }
}
