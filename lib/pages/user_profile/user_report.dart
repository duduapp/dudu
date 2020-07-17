import 'package:fastodon/api/accounts_api.dart';
import 'package:fastodon/models/article_item.dart';
import 'package:fastodon/models/owner_account.dart';
import 'package:fastodon/models/provider/result_list_provider.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/widget/common/list_row.dart';
import 'package:fastodon/widget/listview/provider_easyrefresh_listview.dart';
import 'package:fastodon/widget/status/status_item_content.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserReport extends StatefulWidget {
  final OwnerAccount account;

  UserReport({Key key, this.account}) : super(key: key);

  @override
  _UserReportState createState() => _UserReportState();
}

class _UserReportState extends State<UserReport> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('举报${widget.account.acct}的滥用行为',overflow: TextOverflow.fade,),
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
                OutlineButton(textColor:Theme.of(context).buttonColor,child: Text('取消'),onPressed: (){AppNavigate.pop(context);},),
                SizedBox(width: 5,),
                RaisedButton(textColor:Colors.white,child: Text('继续'),onPressed: () {},),
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
                Checkbox(value: false,)
              ],

            ),
          )
        ],
      ),
    );

  }
}
