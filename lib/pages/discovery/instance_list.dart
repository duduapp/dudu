import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:dudu/constant/db_key.dart';
import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/models/instance/instance_manager.dart';
import 'package:dudu/models/instance/server_instance.dart';
import 'package:dudu/models/json_serializable/instance_item.dart';
import 'package:dudu/models/logined_user.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/pages/discovery/add_instance.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/dialog_util.dart';
import 'package:dudu/widget/common/app_bar_title.dart';
import 'package:dudu/widget/common/custom_app_bar.dart';
import 'package:dudu/widget/common/loading_view.dart';
import 'package:dudu/widget/discovery/instance_summary.dart';
import 'package:dudu/widget/setting/account_list_header.dart';
import 'package:flutter/material.dart';
import 'package:mk_drop_down_menu/mk_drop_down_menu.dart';
import 'package:provider/provider.dart';

class InstanceList extends StatefulWidget {
  @override
  _InstanceListState createState() => _InstanceListState();
}

class _InstanceListState extends State<InstanceList> {
  GlobalKey _headerKey;
  MKDropDownMenuController _downMenuController;
  ScrollController _scrollController;
  List<ServerInstance> instances = [];
  bool loading = true;

  @override
  void initState() {
    _headerKey = GlobalKey();
    _downMenuController = MKDropDownMenuController();
    _scrollController = ScrollController();
    getInstances();
    super.initState();
  }

  getInstances() async {
    instances = await InstanceManager.getList();
    loading = false;
    if (mounted)
      setState(() {});
    else
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
  }

  Widget rowBuilder(BuildContext context, int idx) {
    if (idx == 0) {
      return Column(
        children: [
          SizedBox(height: 10,),
          MediaQuery(
          data: MediaQuery.of(context).copyWith(
          textScaleFactor: ScreenUtil.scaleFromSetting(
          SettingsProvider().get('text_scale'))),
            child: InkWell(
              onTap: () async{
                OverlayUtil.hideAllOverlay();
                var res = await DialogUtils.showRoundedDialog(
                    context: context, content: AddInstance());
                if (res != null) {
                  setState(() {});
                  Timer(Duration(milliseconds: 200), () {
                    _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: Duration(milliseconds: 200),
                        curve: Curves.fastOutSlowIn);
                  });
                }
              },
              child: Ink(
                color: Theme.of(context).primaryColor,
                child: SizedBox(
                  height: 120,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(IconFont.follow,size: 18,),
                          SizedBox(width: 3,),
                          Text('添加网站实例',style: TextStyle(fontSize: 13.5,color: Theme.of(context).accentColor),),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10,)
        ],
      );
    }
    return InstanceSummary(
      instances[idx - 1],
      onDelete: () {
        setState(() {});
      },
      restrictedMode: instances[idx-1].url.startsWith('help.dudu.today') ? true : false,
    );
  }

  @override
  Widget build(BuildContext context) {
    var currentUser =
        context.select<SettingsProvider, LoginedUser>((m) => m.currentUser);

    return Scaffold(
      appBar: CustomAppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        key: _headerKey,
        title: currentUser == null
            ? Text('发现')
            : MKDropDownMenu(
                controller: _downMenuController,
                headerBuilder: (menuShowing) {
                  return DropDownTitle(
                    title: '发现',
                    expand: menuShowing,
                    showIcon: true,
                  );
                },
                headerKey: _headerKey,
                menuBuilder: () {
                  return AccountListHeader(_downMenuController);
                },
              ),
        actions: [
          IconButton(
              icon: Icon(IconFont.follow),
              onPressed: () async {
                OverlayUtil.hideAllOverlay();
                var res = await DialogUtils.showRoundedDialog(
                    context: context, content: AddInstance());
                if (res != null) {
                  setState(() {});
                  Timer(Duration(milliseconds: 200), () {
                    _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: Duration(milliseconds: 200),
                        curve: Curves.fastOutSlowIn);
                  });
                }
              })
        ],
      ),
      body: loading
          ? LoadingView()
          : ListView.builder(
              controller: _scrollController,
              itemBuilder: rowBuilder,
              itemCount: instances.length+1,
            ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController.dispose();
    _downMenuController.dispose();
  }
}
