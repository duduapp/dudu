import 'package:fastodon/api/accounts_api.dart';
import 'package:fastodon/constant/icon_font.dart';
import 'package:fastodon/models/json_serializable/notificate_item.dart';
import 'package:fastodon/models/provider/result_list_provider.dart';
import 'package:fastodon/utils/string_until.dart';
import 'package:fastodon/widget/status/status_item_account.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FollowRequestCell extends StatelessWidget {
  FollowRequestCell({Key key, @required this.item}) : super(key: key);
  final NotificationItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      padding: EdgeInsets.fromLTRB(15, 8, 15, 8),
      margin: EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Center(
                    child: Icon(
                      IconFont.personAdd,
                      color: Theme.of(context).buttonColor,
                    ),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: Text(
                    StringUtil.displayName(item.account) + '请求关注你',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(child: StatusItemAccount(item.account)),
              FlatButton(child: Text('同意',style: TextStyle(color: Theme.of(context).buttonColor,fontWeight: FontWeight.normal),),onPressed: () => _acceptRequest(context),),
              FlatButton(child: Text('拒绝',style: TextStyle(color: Theme.of(context).buttonColor,fontWeight: FontWeight.normal)),onPressed: () => _rejectRequest(context),)
            ],

          )
        ],
      ),
    );
  }

  _acceptRequest(BuildContext context) async{
    await AccountsApi.acceptFollow(item.account.id);
    _removeRow(context);
  }

  _rejectRequest(BuildContext context) {
    AccountsApi.rejectFollow(item.account.id);
    _removeRow(context);
  }

  _removeRow(BuildContext context) {
    ResultListProvider provider = Provider.of<ResultListProvider>(context,listen: false);
    provider.removeByIdWithAnimation(item.id);
  }
}
