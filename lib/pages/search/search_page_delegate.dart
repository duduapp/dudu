import 'package:dudu/api/search_api.dart';
import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/pages/search/search_result.dart';
import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';

import '../../widget/other/search.dart' as customSearch;

class SearchPageDelegate extends customSearch.SearchDelegate  {
  SearchPageDelegate() : super(maintainState: true);

  @override
  ThemeData appBarTheme(BuildContext context) {
    assert(context != null);
    final ThemeData theme = ThemeProvider.themeOf(context).data;
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
                Tab(text: '嘟文',),
                Tab(text: '用户',),
                Tab(text: '话题',),
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
  String get searchFieldLabel => '搜索...';

}