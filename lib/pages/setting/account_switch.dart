import 'package:cached_network_image/cached_network_image.dart';
import 'package:fastodon/models/local_account.dart';
import 'package:fastodon/models/logined_user.dart';
import 'package:fastodon/models/provider/settings_provider.dart';
import 'package:fastodon/pages/login/login.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/widget/common/bottom_sheet_item.dart';
import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart';

import '../home_page.dart';

class AccountSwitch extends StatefulWidget {
  @override
  _AccountSwitchState createState() => _AccountSwitchState();
}

class _AccountSwitchState extends State<AccountSwitch> {
  List<LocalAccount> accounts = [];

  bool manageMode = false;

  @override
  void initState() {
    _getLocalAccounts();
    super.initState();
  }

  _getLocalAccounts() {
    LocalStorageAccount.getAccounts().then((value) {
      setState(() {
        accounts = value;
      });
    });
  }

  _onBackPressed() {
    if (manageMode) {
      setState(() {
        manageMode = false;
      });
    } else {
      AppNavigate.pop(context);
    }
  }

  _onManagePressed() {
    setState(() {
      manageMode = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    var primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SafeArea(
              child: Row(
                children: <Widget>[
                  FlatButton(
                      onPressed: _onBackPressed,
                      child: Text(
                        manageMode ? '取消' : '关闭',
                        style: TextStyle(
                            fontSize: 16, color:Theme.of(context).textTheme.bodyText1.color,fontWeight: FontWeight.normal),
                      )),
                  Spacer(),
                  if (!manageMode)
                    FlatButton(
                        onPressed: _onManagePressed,
                        child: Text(
                          '管理',
                          style: TextStyle(
                              fontSize: 16, color:Theme.of(context).textTheme.bodyText1.color,fontWeight: FontWeight.normal),
                        ))
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Center(
              child: Text(
                manageMode ? '清除账号信息' : '点击来切换账号',
                style: TextStyle(fontSize: 25),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Center(
              child: Divider(
                thickness: 1,
                indent: 50,
                endIndent: 50,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            for (var account in accounts) accountRow(account),
            //SizedBox(height: 10,),
            if (!manageMode)
              InkWell(
                onTap: () => AppNavigate.push(context,Login(showBackButton: true,),routeType:RouterType.material),
                child: Container(
                  padding: EdgeInsets.all(25),
                  color: primaryColor,
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.add,
                        size: 25,
                        color: Theme.of(context).splashColor,
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      Text(
                        '添加账号',
                        style: TextStyle(
                            fontSize: 20, color: Theme.of(context).splashColor),
                      )
                    ],
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  _onDeletePressed(LocalAccount account) async {
    showModalBottomSheet(
        context: context,
        builder: (_) => Container(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  BottomSheetItem(
                    text: '删除账号${StringUtil.accountFullAddress(account.account)}',
                    onTap: () => _confirmDelete(account),
                  ),
                  Container(
                    height: 8,
                    color: Theme.of(context).backgroundColor,
                  ),
                  BottomSheetItem(
                    text: '取消',
                    onTap: () => AppNavigate.pop(context),
                    safeArea: true,
                  )
                ],
              ),
            ));
  }

  _confirmDelete(LocalAccount account) async {
    await LocalStorageAccount.removeAccount(account);
    _getLocalAccounts();
    setState(() {
      manageMode = false;
    });
    AppNavigate.pop(context);
  }

  Widget accountRow(LocalAccount accountInfo) {
    return InkWell(
      onTap: () async {
        if (accountInfo.active) {
          AppNavigate.pop(context);
        } else {
          await LocalStorageAccount.setActiveAccount(accountInfo);
          LoginedUser().loadFromLocalAccount(accountInfo);
          await SettingsProvider().load();
          AppNavigate.pushAndRemoveUntil(context,HomePage(),routeType: RouterType.scale);
        }
      },
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.only(bottom: 10),
        color: Theme.of(context).primaryColor,
        child: ListTile(
          leading: CachedNetworkImage(
            imageUrl: accountInfo.account?.avatarStatic,
          ),
          title: Row(
            children: <Widget>[
              Text(StringUtil.displayName(accountInfo.account)),
              Spacer(),
              if (accountInfo.active)
                Text(
                  '当前使用',
                  style: TextStyle(color: Theme.of(context).buttonColor),
                )
            ],
          ),
          subtitle: Text(StringUtil.accountFullAddress(accountInfo.account)),
          trailing: (manageMode && !accountInfo.active)
              ? ButtonTheme(
                  minWidth: 60,
                  height: 35,
                  child: RaisedButton(
                    child: Text(
                      '删除',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    color: Colors.red,
                    onPressed: () {
                      _onDeletePressed(accountInfo);
                    },
                    textColor: Colors.white,
                    padding: EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                )
              : null,
          contentPadding: EdgeInsets.all(0),
        ),
      ),
    );
  }
}
