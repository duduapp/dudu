import 'package:dudu/l10n/l10n.dart';
import 'package:dudu/api/admin_api.dart';
import 'package:dudu/models/json_serializable/owner_account.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/dialog_util.dart';
import 'package:dudu/widget/common/normal_flat_button.dart';
import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart';

class AccountActionDialog extends StatefulWidget {
  final OwnerAccount account;

  AccountActionDialog(this.account);

  @override
  _AccountActionDialogState createState() => _AccountActionDialogState();
}

class _AccountActionDialogState extends State<AccountActionDialog> {
  int groupValue = 0;
  bool sendEmail = false;
  TextEditingController _textEditingController = TextEditingController();

  static Map<int, String> get descriptions => {
    0: S.of(navGK.currentState.overlay.context).just_warn_the_user,
    1: S.of(navGK.currentState.overlay.context).prevent_the_user_from_logging_in,
    2: S.of(navGK.currentState.overlay.context).toots_posted_by_users_will_not_be_displayed_in_the_public_timeline,
    3: S.of(navGK.currentState.overlay.context).deactivate_and_permanently_delete_account_information
  };

  static Map<int,String> actions = {
    0: 'none',
    1: 'disable',
    2: 'silence',
    3: 'suspend'
  };

  static Map<int,String> get shortDescription => {
    0 : S.of(navGK.currentState.overlay.context).caveat,
    1 : S.of(navGK.currentState.overlay.context).deactivate,
    2 : S.of(navGK.currentState.overlay.context).silence,
    3 : S.of(navGK.currentState.overlay.context).ban
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
                 widget.account.acct + " " + S.of(navGK.currentState.overlay.context).perform_management_operations,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
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
                    Text(S.of(navGK.currentState.overlay.context).caveat),
                  ],
                ),

                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Radio(
                      value: 1,
                      groupValue: groupValue,
                      onChanged: (value) {
                        setState(() {
                          groupValue = value;
                        });
                      },
                    ),
                    Text(S.of(navGK.currentState.overlay.context).deactivate),
                  ],
                ),

                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Radio(
                      value: 2,
                      groupValue: groupValue,
                      onChanged: (value) {
                        setState(() {
                          groupValue = value;
                        });
                      },
                    ),
                    Text(S.of(navGK.currentState.overlay.context).silence),
                  ],
                ),

                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Radio(
                      value: 3,
                      groupValue: groupValue,
                      onChanged: (value) {
                        setState(() {
                          groupValue = value;
                        });
                      },
                    ),
                    Text(S.of(navGK.currentState.overlay.context).ban)
                  ],
                ),

              ],
            ),
            Container(
              child: Text(
                descriptions[groupValue],
                style: TextStyle(
                    color: groupValue == 3
                        ? Colors.red
                        : Theme.of(navGK.currentState.overlay.context).accentColor),
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
                Text(S.of(navGK.currentState.overlay.context).remind_users_via_email)
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 5),
              child: Text(S.of(navGK.currentState.overlay.context).email_to_inform_users),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: TextField(
                controller: _textEditingController,
                maxLines: 2,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(navGK.currentState.overlay.context).buttonColor)),
                  border: OutlineInputBorder(borderSide: BorderSide()),
                ),
              ),
            ),
            Row(
              children: [
                Spacer(),
                NormalCancelFlatButton(),
                NormalFlatButton(text: S.of(navGK.currentState.overlay.context).determine,onPressed: () {
                  AppNavigate.pop();
                  DialogUtils.showSimpleAlertDialog(context: context,text: S.of(context).are_you_sure_you_want+shortDescription[groupValue]+' '+widget.account.acct+'?'+
                      S.of(navGK.currentState.overlay.context).this_operation_will + descriptions[groupValue]+'',onConfirm: () async{
                    var res = await AdminApi.accountAction(accountId: widget.account.id,type: actions[groupValue],sendEmail: sendEmail,text: _textEditingController.text);
                    if (!res) {
                      DialogUtils.toastErrorInfo(S.of(navGK.currentState.overlay.context).an_error_occurred);
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
