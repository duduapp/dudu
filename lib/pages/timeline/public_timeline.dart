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

class PublicTimeline extends StatefulWidget {
  @override
  _PublicTimelineState createState() => _PublicTimelineState();
}

class _PublicTimelineState extends State<PublicTimeline>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  GlobalKey _headerKey;
  MKDropDownMenuController _menuController1;
  MKDropDownMenuController _menuController2;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _headerKey = GlobalKey();
    _menuController1 = MKDropDownMenuController();
    _menuController2 = MKDropDownMenuController();
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        child: CustomAppBar(
          elevation: 0,
        ),
        preferredSize: Size.fromHeight(0),
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).appBarTheme.color,
            height: 45,
            child: Row(
              children: [
                SizedBox(width: 102,),
                Expanded(
                  child: ColoredTabBar(
                    key: _headerKey,
                    color: Theme.of(context).appBarTheme.color,
                    tabBar: TabBar(
                      onTap: (idx) {
                        OverlayUtil.hideAllOverlay();
                      },
                      indicator: UnderlineTabIndicator(
                          borderSide: BorderSide(
                              width: 2.5, color: Theme.of(context).buttonColor),
                          insets: EdgeInsets.only(left: 5, right: 25)),
                      isScrollable: true,
                      labelPadding: EdgeInsets.all(0),
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: [
                        _tabController.index == 0
                            ? MKDropDownMenu(
                                controller: _menuController1,
                                headerBuilder: (menuShowing) {
                                  return DropDownTitle(
                                    title: '本站',
                                    expand: menuShowing,
                                    showIcon: true,
                                  );
                                },
                                headerKey: _headerKey,
                                menuBuilder: () {
                                  return AccountListHeader(_menuController1);
                                },
                              )
                            : DropDownTitle(
                                title: '本站',
                              ),
                        _tabController.index == 1
                            ? MKDropDownMenu(
                                controller: _menuController2,
                                headerKey: _headerKey,
                                headerBuilder: (menuShowing) {
                                  return DropDownTitle(
                                    title: '跨站',
                                    expand: menuShowing,
                                    showIcon: true,
                                  );
                                },
                                menuBuilder: () {
                                  return AccountListHeader(_menuController2);
                                },
                              )
                            : DropDownTitle(
                                title: '跨站',
                              ),
                      ],
                      controller: _tabController,
                    ),
                  ),
                ),
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
          ),
          Divider(
            height: 0,
          ),
          Expanded(
              child: TabBarView(
            controller: _tabController,
            children: [
              TimelineContent(
                url: Api.LocalTimeLine,
                tag: 'local',
              ),
              TimelineContent(
                url: Api.FederatedTimeLine,
                tag: 'federated',
              ),
            ],
          ))
        ],
      ),
    );
  }
}