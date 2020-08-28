import 'package:dudu/models/local_account.dart';
import 'package:dudu/models/provider/result_list_provider.dart';
import 'package:dudu/pages/login/login.dart';
import 'package:dudu/utils/app_navigate.dart';
import 'package:dudu/widget/listview/provider_easyrefresh_listview.dart';
import 'package:dudu/widget/setting/account_row_top.dart';
import 'package:flutter/material.dart';
import 'package:gzx_dropdown_menu/gzx_dropdown_menu.dart';
import 'package:nav_router/nav_router.dart';
import 'package:provider/provider.dart';

class AccountSwitchTimeline extends StatefulWidget {
  final ResultListProvider provider;
  final ProviderEasyRefreshListView listView;
  final String title;
  final List<Widget> actions;

  const AccountSwitchTimeline({Key key, this.provider, this.listView, this.title, this.actions}) : super(key: key);



  @override
  _AccountSwitchTimelineState createState() => _AccountSwitchTimelineState();
}

class _AccountSwitchTimelineState extends State<AccountSwitchTimeline> {

  GlobalKey _stackKey = GlobalKey();
  GZXDropdownMenuController _menuController = GZXDropdownMenuController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _menuController.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: PreferredSize(
          child: AppBar(
            elevation: 0,
          ),
          preferredSize: Size.fromHeight(0)),
//      appBar: PreferredSize(
//        preferredSize: Size.fromHeight(40.0),
//        child: AppBar(
//          title: Stack(
//            key: _stackKey,
//            children: [
//              GZXDropDownHeader(
//                items: [GZXDropDownHeaderItem(title)],
//                stackKey: _stackKey,
//                controller: _menuController,
//              ),
//
//            ],
//          ),
//          centerTitle: true,
//          actions: <Widget>[
//            IconButton(
//              splashColor: Colors.transparent,
//              icon: Icon(
//                IconFont.search,
//                size: 25,
//              ),
//              onPressed: () {
//                customSearch.showSearch(
//                    context: context, delegate: SearchPageDelegate());
//              },
//            ),
//            IconButton(
//              splashColor: Colors.transparent,
//              icon: Icon(
//                Icons.add_circle,
//                color: Theme.of(context).buttonColor,
//              ),
//              onPressed: () {
//                AppNavigate.push(NewStatus(), routeType: RouterType.material);
//              },
//            )
//          ],
//        ),
//      ),
      body: Stack(key: _stackKey, children: [
        Column(children: [
          Container(
            height: 40,
            color: Theme.of(context).appBarTheme.color,
            child: Row(children: [
              SizedBox(width: (widget.actions.length * 35 + 17).toDouble()),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: GZXDropDownHeader(
                      items: [
                        GZXDropDownHeaderItem(widget.title,
                            style: TextStyle(
                                fontSize: 17,
                                color: Theme.of(context).textTheme.bodyText1.color))
                      ],
                      stackKey: _stackKey,
                      controller: _menuController,
                      dividerHeight: 0,
                      borderWidth: 0,
                      color: Theme.of(context).appBarTheme.color,
                      dropDownStyle: TextStyle(
                          fontSize: 17,
                          color: Theme.of(context).textTheme.bodyText1.color),
                      iconDropDownColor: Theme.of(context).textTheme.bodyText1.color),
                ),
              ),
              for (var actionWidget in widget.actions)
              ...[SizedBox(
                width: 30,
                child: actionWidget,
              ),SizedBox(width: 5,),
              ],

              SizedBox(width: 7,
              )
            ]),
          ),
          Divider(
            height: 0,
          ),
          Expanded(
            child:
            ChangeNotifierProvider<ResultListProvider>.value(
              value: widget.provider,
              builder: (context, snapshot) {
              return widget.listView;
            }),
          ),
        ]),
        GZXDropDownMenu(
          animationMilliseconds: 200,
          controller: _menuController,
          menus: [
            GZXDropdownMenuBuilder(dropDownHeight: _getDropMenuHeight(),dropDownWidget: SingleChildScrollView(
              child: Container(
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    for (var acc in LocalStorageAccount.accounts)
                      ...[AccountRowTop(acc),Divider(height: 0,)],

                    InkWell(
                      onTap: () => AppNavigate.push(
                          Login(
                            showBackButton: true,
                          ),
                          routeType: RouterType.material),
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add,color: Theme.of(context).accentColor,),
                            SizedBox(width: 10,),
                            Text('添加账号',style: TextStyle(fontSize:16,color: Theme.of(context).accentColor,),)
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )),


          ],
        )
      ]),
    );
  }

  _getDropMenuHeight() {
    var contentHeight = (LocalStorageAccount.accounts.length * 60 + 50).toDouble();
    return contentHeight > 240.0 ? 240.0 : contentHeight;
  }
}
