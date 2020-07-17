import 'package:cached_network_image/cached_network_image.dart';
import 'package:fastodon/constant/api.dart';
import 'package:fastodon/models/provider/result_list_provider.dart';
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
          requestUrl: Api.CustomEmojis,
          firstRefresh: true,
          buildRow: _buildEmojiItem,
          cacheTimeInSeconds: 3600,
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
          return GridView.builder(
              itemCount: provider.list.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (context, idx) {
                return provider.buildRow(idx, provider.list, provider);
              });
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


