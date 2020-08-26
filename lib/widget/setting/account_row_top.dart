

import 'package:dudu/models/local_account.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/account_util.dart';
import 'package:dudu/widget/other/avatar.dart';
import 'package:flutter/material.dart';

class AccountRowTop extends StatelessWidget {
  final LocalAccount account;
  
  AccountRowTop(this.account);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (!account.active) {
          AccountUtil.switchToAccount(account);
        }
      },
      child: Container(
        height: 60,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Row(
          children: [
            Avatar(account:account.account,navigateToDetail: false,width: 40,height: 40,),
            SizedBox(width: 10,),
            Expanded(child: Text(StringUtil.accountFullAddress(account.account),overflow: TextOverflow.ellipsis,)),
            if (account.active)
              Icon(Icons.check,color: Theme.of(context).buttonColor,)
          ],
        ),
      ),
    );
  }
}
