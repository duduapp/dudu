import 'package:fastodon/constant/api.dart';
import 'package:fastodon/models/provider/result_list_provider.dart';
import 'package:fastodon/utils/list_view.dart';
import 'package:fastodon/widget/listview/provider_easyrefresh_listview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HashtagTimeline extends StatelessWidget {
  final String hashtag;

  HashtagTimeline(this.hashtag);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('#'+hashtag),
        centerTitle: false,
      ),
      body: ChangeNotifierProvider<ResultListProvider>(
        create: (context) => ResultListProvider(
          requestUrl: Api.hashtagTimeline+'/'+hashtag,
          buildRow: ListViewUtil.statusRowFunction(),

        ),
        child: ProviderEasyRefreshListView(
        ),
      ),
    );
  }

}
