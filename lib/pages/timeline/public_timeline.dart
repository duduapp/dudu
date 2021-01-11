import 'package:dudu/l10n/l10n.dart';
import 'package:badges/badges.dart';
import 'package:dudu/api/timeline_api.dart';
import 'package:dudu/constant/api.dart';
import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/models/local_account.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/models/runtime_config.dart';
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
import 'package:provider/provider.dart';
import '../../widget/other/search.dart' as customSearch;

class PublicTimeline extends StatefulWidget {
  final String url;
  final bool enableFederated;

  PublicTimeline({this.url,this.enableFederated = true});

  @override
  _PublicTimelineState createState() => _PublicTimelineState();
}

class _PublicTimelineState extends State<PublicTimeline>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  GlobalKey _headerKey;
  MKDropDownMenuController _menuController1;
  MKDropDownMenuController _menuController2;

  String url;

  @override
  void initState() {
    _tabController = TabController(initialIndex:widget.url == null ? SettingsProvider().publicTabIndex ?? 0 : 0,length: 2, vsync: this);
    _tabController.addListener(() {
      if (!widget.enableFederated) {
        _tabController.index = 0;
      } else {

      }
      if (widget.url == null) {
          SettingsProvider().setPublicTabIndex(_tabController.index);
      }
      setState(() {});
    });
    _headerKey = GlobalKey();
    _menuController1 = MKDropDownMenuController();
    _menuController2 = MKDropDownMenuController();

    if (widget.url != null) {
      if (widget.url.startsWith('https://')) {
        url = widget.url;
      } else {
        url = 'https://' + widget.url;
      }
    }

    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<SettingsProvider>(context);
    var showBadge = provider.get('red_dot_notfication');
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
                if (widget.url == null)
                  SizedBox(
                    width: 102,
                  ),
                if (widget.url != null) ...[
                  IconButton(
                      icon: Icon(IconFont.back),
                      onPressed: () => AppNavigate.pop()),
                ],
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
                      labelStyle: TextStyle(fontWeight: FontWeight.normal),
                      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
                      tabs: [
                        Badge(
                          position: BadgePosition.topEnd(top: 5,end: 18),
                          showBadge: showBadge && provider.unread[TimelineApi.local] != 0 && widget.url == null,
                          child: (_tabController.index == 0 && widget.url == null)
                              ? MKDropDownMenu(
                                  controller: _menuController1,
                                  headerBuilder: (menuShowing) {
                                    return DropDownTitle(
                                      title: S.of(context).this_site,
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
                                  title: S.of(context).this_site,
                                ),
                        ),
                        (_tabController.index == 1 && widget.url == null)
                            ? MKDropDownMenu(
                                controller: _menuController2,
                                headerKey: _headerKey,
                                headerBuilder: (menuShowing) {
                                  return DropDownTitle(
                                    title: S.of(context).cross_station,
                                    expand: menuShowing,
                                    showIcon: true,
                                  );
                                },
                                menuBuilder: () {
                                  return AccountListHeader(_menuController2);
                                },
                              )
                            : DropDownTitle(
                                title: S.of(context).cross_station,
                                fontColor: widget.enableFederated ? null : Colors.grey,
                              ),
                      ],
                      controller: _tabController,
                    ),
                  ),
                ),
                if (widget.url == null) ...[
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
                ] else
                  SizedBox(width: 20,),
              ],
            ),
          ),

          Divider(
            height: 1,
          ),
          Expanded(
              child: TabBarView(
                physics: widget.enableFederated ? null : NeverScrollableScrollPhysics(),
            controller: _tabController,
            children: [
              TimelineContent(
                url: widget.url != null
                    ? url + TimelineApi.local
                    : TimelineApi.local,
                tag: 'local',
              ),
              TimelineContent(
                url: widget.url != null
                    ? url + TimelineApi.federated
                    : TimelineApi.federated,
                tag: 'federated',
              ),
            ],
          ))
        ],
      ),
    );
  }
}
