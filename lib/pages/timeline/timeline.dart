// import 'package:dudu/api/timeline_api.dart';
// import 'package:dudu/constant/icon_font.dart';
// import 'package:dudu/l10n/l10n.dart';
// import 'package:dudu/models/provider/result_list_provider.dart';
// import 'package:dudu/models/provider/settings_provider.dart';
// import 'package:dudu/pages/search/search_page_delegate.dart';
// import 'package:dudu/pages/status/new_status.dart';
// import 'package:dudu/public.dart';
// import 'package:dudu/utils/view/list_view_util.dart';
// import 'package:dudu/widget/listview/provider_easyrefresh_listview.dart';
// import 'package:dudu/widget/timeline/account_switch_timeline.dart';
// import 'package:flutter/material.dart';
// import 'package:gzx_dropdown_menu/gzx_dropdown_menu.dart';
// import 'package:nav_router/nav_router.dart';
// import 'package:pull_to_refresh/pull_to_refresh.dart';
//
// import '../../widget/other/search.dart' as customSearch;
//
enum TimelineType {
  home,
  local,
  federated // 跨站
}
//
// class Timeline extends StatefulWidget {
//   final TimelineType type;
//
//   Timeline(this.type);
//
//   @override
//   _TimelineState createState() => _TimelineState();
// }
//
// class _TimelineState extends State<Timeline> {
//   ScrollController _scrollController = ScrollController();
//   RefreshController _refreshController = RefreshController();
//   GZXDropdownMenuController _menuController = GZXDropdownMenuController();
//   ResultListProvider provider;
//
//   @override
//   void initState() {
//     super.initState();
//
//     var url;
//     switch (widget.type) {
//       case TimelineType.home:
//         url = TimelineApi.home;
//         break;
//       case TimelineType.local:
//         url = TimelineApi.local;
//         break;
//       case TimelineType.federated:
//         url = TimelineApi.federated;
//         break;
//     }
//     provider = ResultListProvider(
//         firstRefresh: false,
//         requestUrl: url,
//         tag: widget.type.toString().split('.').last,
//         buildRow: ListViewUtil.statusRowFunction(),
//         listenBlockEvent: false,
//         dataHandler: ListViewUtil.dataHandlerPrefixIdFunction(
//             widget.type.toString().split('.')[1] + "##"));
//     switch (widget.type) {
//       case TimelineType.home:
//         SettingsProvider().homeProvider = provider;
//         break;
//       case TimelineType.local:
//         SettingsProvider().localProvider = provider;
//         break;
//       case TimelineType.federated:
//         SettingsProvider().federatedProvider = provider;
//         break;
//     }
//     provider.refreshController = _refreshController;
//     provider.scrollController = _scrollController;
//
//     provider.loadCacheDataOrRefresh();
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // provider.checkCachePosition();
//     });
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     _scrollController.dispose();
//     _refreshController.dispose();
//     _menuController.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     var title;
//     switch (widget.type) {
//       case TimelineType.home:
//         title = S.of(context).home;
//         break;
//       case TimelineType.local:
//         title = S.of(context).this_site;
//         break;
//       case TimelineType.federated:
//         title = S.of(context).cross_station;
//         break;
//     }
//     return AccountSwitchTimeline(
//       provider: provider,
//       listView: ProviderEasyRefreshListView(
//         type: widget.type,
//         scrollController: _scrollController,
//       ),
//       title: title,
//       actions: [
//         IconButton(
//           icon: Icon(
//             IconFont.search,
//             size: 26,
//           ),
//           onPressed: () {
//             customSearch.showSearch(
//                 context: context, delegate: SearchPageDelegate());
//           },
//         ),
//         IconButton(
//           icon: Icon(
//             IconFont.addCircle,
//             color: Theme.of(context).buttonColor,
//             size: 26,
//           ),
//           onPressed: () =>
//               AppNavigate.push(NewStatus(), routeType: RouterType.material),
//         )
//       ],
//     );
//   }
// }
