import 'package:dudu/api/admin_api.dart';
import 'package:dudu/models/json_serializable/owner_account.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/dialog_util.dart';
import 'package:dudu/widget/common/normal_flat_button.dart';
import 'package:flutter/material.dart';

class AccountActionDialog extends StatefulWidget {
  final OwnerAccount account;

  AccountActionDialog(this.account);

  @override
  _AccountActionDialogState createState() => _AccountActionDialogState();
}

class _AccountActionDialogState extends State<AccountActionDialog> {
  int groupValue = 0;
  bool sendEmail = true;
  TextEditingController _textEditingController = TextEditingController();

  static Map<int, String> descriptions = {
    0: '只是警告用户，不会对用户账号进行操作',
    1: '使用户无法登录，会保留用户所有内容',
    2: '用户发表的嘟文将不会显示在公共时间轴中',
    3: '停用并永久删除账号信息'
  };

  static Map<int,String> actions = {
    0: 'none',
    1: 'disable',
    2: 'silence',
    3: 'suspend'
  };

  static Map<int,String> shortDescription = {
    0 : '警告',
    1 : '停用',
    2 : '隐藏',
    3 : '封禁'
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      width: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 3, left: 5),
              child: Text(
                '在' + widget.account.acct + '执行管理操作',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Radio(
                  value: 0,
                  groupValue: groupValue,
                  onChanged: (value) {
                    setState(() {
                      groupValue = value;
                    });
                  },
                ),
                Text('警告'),
                Radio(
                  value: 1,
                  groupValue: groupValue,
                  onChanged: (value) {
                    setState(() {
                      groupValue = value;
                    });
                  },
                ),
                Text('停用'),
                Radio(
                  value: 2,
                  groupValue: groupValue,
                  onChanged: (value) {
                    setState(() {
                      groupValue = value;
                    });
                  },
                ),
                Text('隐藏'),
                Radio(
                  value: 3,
                  groupValue: groupValue,
                  onChanged: (value) {
                    setState(() {
                      groupValue = value;
                    });
                  },
                ),
                Text('封禁')
              ],
            ),
            Container(
              child: Text(
                descriptions[groupValue],
                style: TextStyle(
                    color: groupValue == 3
                        ? Colors.red
                        : Theme.of(context).accentColor),
              ),
              padding: const EdgeInsets.only(left: 10),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Checkbox(
                    value: sendEmail,
                    onChanged: (value) {
                      setState(() {
                        sendEmail = value;
                      });
                    }),
                Text('通过邮件提醒用户')
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 5),
              child: Text('邮件告知用户内容'),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: TextField(
                controller: _textEditingController,
                maxLines: 2,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).buttonColor)),
                  border: OutlineInputBorder(borderSide: BorderSide()),
                ),
              ),
            ),
            Row(
              children: [
                Spacer(),
                NormalCancelFlatButton(),
                NormalFlatButton(text: '确定',onPressed: () {
                  AppNavigate.pop();
                  DialogUtils.showSimpleAlertDialog(context: context,text: '您确定要'+shortDescription[groupValue]+widget.account.acct+'吗，'
                      '该操作将'+descriptions[groupValue]+'',onConfirm: () async{
                    var res = await AdminApi.accountAction(accountId: widget.account.id,type: actions[groupValue],sendEmail: sendEmail,text: _textEditingController.text);
                    if (!res) {
                      DialogUtils.toastErrorInfo('出现错误');
                    }
                //    AppNavigate.pop();
                  });
                },),
              ],
            )
          ],
        ),
      ),
    );
  }
}
