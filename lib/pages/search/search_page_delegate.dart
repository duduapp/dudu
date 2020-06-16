import 'package:fastodon/api/search_api.dart';
import 'package:fastodon/pages/search/search_result.dart';
import 'package:flutter/material.dart';

import '../../widget/other/search.dart' as customSearch;

class SearchPageDelegate extends customSearch.SearchDelegate  {
  SearchPageDelegate() : super(maintainState: true);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
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