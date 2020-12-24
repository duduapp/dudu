import 'package:dudu/l10n/l10n.dart';
import 'package:dudu/models/local_account.dart';
import 'package:dudu/models/logined_user.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/pages/login/login.dart';
import 'package:dudu/utils/app_navigate.dart';
import 'package:dudu/widget/setting/account_row_top.dart';
import 'package:flutter/material.dart';
import 'package:mk_drop_down_menu/mk_drop_down_menu.dart';
import 'package:nav_router/nav_router.dart';

class AccountListHeader extends StatelessWidget {
  final MKDropDownMenuController controller;


  AccountListHeader(this.controller);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      constraints: BoxConstraints(maxHeight: 240),
      child: SingleChildScrollView(
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              if (LoginedUser().account != null)
              for (var acc in LocalStorageAccount.accounts)
                ...[AccountRowTop(acc,controller),Divider(height: 0,)],
              InkWell(
                onTap: () {
                  controller.hideMenu();
                  SettingsProvider().setHomeTabIndex(2);
                  // AppNavigate.push(
                  //     Login(
                  //       showBackButton: true,
                  //     ),
                  //     routeType: RouterType.material);
                },
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add,color: Theme.of(context).accentColor,),
                      SizedBox(width: 10,),
                      Text(S.of(context).add_account,style: TextStyle(fontSize:16,color: Theme.of(context).accentColor,),)
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}


