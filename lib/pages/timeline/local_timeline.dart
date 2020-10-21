import 'package:dudu/constant/api.dart';
import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/models/local_account.dart';
import 'package:dudu/pages/login/login.dart';
import 'package:dudu/pages/search/search_page_delegate.dart';
import 'package:dudu/pages/status/new_status.dart';
import 'package:dudu/utils/app_navigate.dart';
import 'package:dudu/widget/common/app_bar_title.dart';
import 'package:dudu/widget/common/colored_tab_bar.dart';
import 'package:dudu/widget/common/custom_app_bar.dart';
import 'package:dudu/widget/setting/account_list_header.dart';
import 'package:dudu/widget/setting/account_row_top.dart';
import 'package:dudu/widget/timeline/timeline_content.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mk_drop_down_menu/mk_drop_down_menu.dart';
import 'package:nav_router/nav_router.dart';
import '../../widget/other/search.dart' as customSearch;

class LocalTimeline extends StatefulWidget {
  @override
  _LocalTimelineState createState() => _LocalTimelineState();
}

class _LocalTimelineState extends State<LocalTimeline> {
  GlobalKey _headerKey;
  MKDropDownMenuController _downMenuController;

  @override
  void initState() {
    _headerKey = GlobalKey();
    _downMenuController = MKDropDownMenuController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        elevation: 0.3,
        centerTitle: true,
        automaticallyImplyLeading: false,
        key: _headerKey,
        title: MKDropDownMenu(
          controller: _downMenuController,
          headerBuilder: (menuShowing) {
            return DropDownTitle(
              title: '首页',
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
            icon: Icon(
              IconFont.search,
              size: 26,
            ),
            onPressed: () {
              customSearch.showSearch(
                  context: context, delegate: SearchPageDelegate());
            },
          ),
          IconButton(
            icon: Icon(
              IconFont.follow,
            //  color: Theme.of(context).buttonColor,
              size: 26,
            ),
            onPressed: () => AppNavigate.push(NewStatus(),
                routeType: RouterType.material),
          )
        ],
      ),
      body: TimelineContent(
        url: Api.LocalTimeLine,
        tag: 'local',
      ),
    );
  }
}
