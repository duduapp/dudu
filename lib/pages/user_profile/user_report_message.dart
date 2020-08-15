import 'package:dudu/api/accounts_api.dart';
import 'package:dudu/models/json_serializable/owner_account.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/app_navigate.dart';
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
      appBar: AppBar(
        title: Text('举报@${widget.account.acct}的滥用行为',overflow: TextOverflow.fade,),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: DefaultTextStyle.merge(
            style: TextStyle(fontSize: 18),
          child: Column(
            children: <Widget>[
              Text(
                '该报告将发送给您的服务器管理员。你可以在下面填写举报该用户的理由：',
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
                  labelText: '举报原因',
                ),
              ),
              SizedBox(
                height: 20,
              ),
              if (widget.account.acct != widget.account.username) ...[
                Text('这名用户来自另一个服务器。是否要向那个服务器发送一条匿名的举报？',),
                SizedBox(height: 20,),
                Row(
                  children: <Widget>[
                    Checkbox(value: forward,onChanged: (bool) {setState(() {
                      forward = bool;
                    });},),
                    Text('转发到'+StringUtil.accountDomain(widget.account),)
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
                      child: Text('返回'),
                      onPressed: () {
                        AppNavigate.pop();
                      },
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    RaisedButton(
                      textColor: Colors.white,
                      child: Text('举报'),
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
