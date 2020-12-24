import 'package:dudu/l10n/l10n.dart';
import 'package:dudu/api/search_api.dart';
import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/pages/search/search_result.dart';
import 'package:dudu/utils/themes.dart';
import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart';

import '../../widget/other/search.dart' as customSearch;

class SearchPageDelegate extends customSearch.SearchDelegate  {
  SearchPageDelegate() : super(maintainState: true);

  @override
  ThemeData appBarTheme(BuildContext context) {

    assert(context != null);
    int chooseTheme = 0;
    try {
      chooseTheme = int.parse(SettingsProvider().get('theme'));
    } catch(e) {}
    final ThemeData theme = ThemeUtil.themes[chooseTheme];
    assert(theme != null);

    return theme;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(IconFont.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(IconFont.back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container(
      child: DefaultTabController(
        // The number of tabs / content sections to display.
          length: 3,
          child: Scaffold(
            appBar: TabBar(
              tabs: <Widget>[
                Tab(text: S.of(context).toots,),
                Tab(text: S.of(context).user,),
                Tab(text: S.of(context).topic,),
              ],
            ),
            body: TabBarView(
              children: <Widget>[
                SearchResult(SearchType.statuses,query),
                SearchResult(SearchType.accounts,query),
                SearchResult(SearchType.hashtags,query),
              ],
            ),
          )// Complete this code in the next step.
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }

  @override
  String get searchFieldLabel => S.of(navGK.currentState.overlay.context).search_for;

}