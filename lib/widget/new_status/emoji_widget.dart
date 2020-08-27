import 'package:cached_network_image/cached_network_image.dart';
import 'package:dudu/constant/api.dart';
import 'package:dudu/models/provider/result_list_provider.dart';
import 'package:dudu/widget/common/empty_view.dart';
import 'package:dudu/widget/common/loading_view.dart';
import 'package:dudu/widget/listview/provider_easyrefresh_listview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef EmojiClicked = Function(String emoji);


class EmojiKeyboard extends StatelessWidget {

  final EmojiClicked onChoose;

  EmojiKeyboard({this.onChoose});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ResultListProvider>(
      create: (context) => ResultListProvider(
          enableRefresh: false,
          enableLoad: false,
          requestUrl: Api.CustomEmojis,
          buildRow: _buildEmojiItem,
          enableCache: true,
          dataHandler: (data) {
            List newData = [];
            for (var row in data) {
              if (row['visible_in_picker']) {
                newData.add(row);
              }
            }
            return newData;
          }
      ),
      child: Consumer<ResultListProvider>(
        builder: (context, provider, child) {
          return ProviderEasyRefreshListView(
            usingGrid: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            emptyView: EmptyView(text: '本实例没有自定义表情',),
          );
        },
      ),
    );
  }

  Widget _buildEmojiItem(int idx, List data, ResultListProvider provider) {
    var row = data[idx];
    if (row['visible_in_picker']) {
      return InkWell(
        onTap: () => onChoose(data[idx]['shortcode']),
        child: CachedNetworkImage(
          imageUrl: data[idx]['static_url'],
        ),
      );
    } else {
      return Container(child: Text('aaa'),);
    }
  }
}


