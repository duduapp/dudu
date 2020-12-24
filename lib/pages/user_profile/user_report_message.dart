import 'package:dudu/l10n/l10n.dart';
import 'package:dudu/api/accounts_api.dart';
import 'package:dudu/models/json_serializable/owner_account.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/app_navigate.dart';
import 'package:dudu/widget/common/custom_app_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UserReportMessage extends StatefulWidget {
  final List<String> chooseStatuses;
  final OwnerAccount account;

  const UserReportMessage({Key key, this.chooseStatuses, this.account})
      : super(key: key);

  @override
  _UserReportMessageState createState() => _UserReportMessageState();
}

class _UserReportMessageState extends State<UserReportMessage> {
  TextEditingController _controller = TextEditingController();
  FocusNode focusNode = new FocusNode();
  bool forward = false;

  @override
  void initState() {
    focusNode.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(S.of(context).report_user('@'+widget.account.acct),overflow: TextOverflow.fade,),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: DefaultTextStyle.merge(
            style: TextStyle(fontSize: 18),
          child: Column(
            children: <Widget>[
              Text(
                S.of(context).the_report_will_be_sent_to_your_server_administrator,
                maxLines: null,
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: _controller,
                focusNode: focusNode,
                maxLines: 5,
                decoration: InputDecoration(
                  alignLabelWithHint: true,
                  labelStyle: TextStyle(
                    color: focusNode.hasFocus
                        ? Theme.of(context).buttonColor
                        : Theme.of(context).accentColor,
                  ),
                  counterText: '',
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).buttonColor)),
                  border: OutlineInputBorder(borderSide: BorderSide()),
                  labelText: S.of(context).reason_for_reporting,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              if (widget.account.acct != widget.account.username) ...[
                Text(S.of(context).this_user_is_from_another_server,),
                SizedBox(height: 20,),
                Row(
                  children: <Widget>[
                    Checkbox(value: forward,onChanged: (bool) {setState(() {
                      forward = bool;
                    });},),
                    Text(S.of(context).forward_to+StringUtil.accountDomain(widget.account),)
                  ],
                )
              ],



              Spacer(),
              SafeArea(
                child: Row(
                  children: <Widget>[
                    Spacer(),
                    OutlineButton(
                      textColor: Theme.of(context).buttonColor,
                      child: Text(S.of(context).back),
                      onPressed: () {
                        AppNavigate.pop();
                      },
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    RaisedButton(
                      textColor: Colors.white,
                      child: Text(S.of(context).complaint),
                      onPressed: () async{
                        var res = await AccountsApi.reportUser(widget.account.id, widget.chooseStatuses, _controller.text, forward);
                        if (res != null) {
                          AppNavigate.pop();
                          AppNavigate.pop();
                        }
                      },
                    ),
                    SizedBox(
                      width: 20,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
