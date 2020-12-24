import 'package:dudu/l10n/l10n.dart';
import 'package:dudu/api/accounts_api.dart';
import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/models/json_serializable/notificate_item.dart';
import 'package:dudu/models/provider/result_list_provider.dart';
import 'package:dudu/utils/string_until.dart';
import 'package:dudu/widget/status/status_item_account.dart';
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
                     S.of(context).request_to_follow_you(StringUtil.displayName(item.account)),
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(child: StatusItemAccount(item.account,padding: 0,)),
              FlatButton(child: Text(S.of(context).agree,style: TextStyle(color: Theme.of(context).buttonColor,fontWeight: FontWeight.normal),),onPressed: () => _acceptRequest(context),),
              FlatButton(child: Text(S.of(context).refuse,style: TextStyle(color: Theme.of(context).buttonColor,fontWeight: FontWeight.normal)),onPressed: () => _rejectRequest(context),)
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
