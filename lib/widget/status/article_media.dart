import 'package:cached_network_image/cached_network_image.dart';
import 'package:fastodon/models/json_serializable/media_attachment.dart';
import 'package:fastodon/public.dart';
import 'package:flutter/material.dart';

class ArticleMedia extends StatelessWidget {
  ArticleMedia({
    Key key, 
    this.itemList,
   }) : super(key: key);

  final List itemList;

  List<Widget> picAndVideo (BuildContext context) {
    List<Widget> picList = [];
    for (var data in itemList) {
      MediaAttachment media = MediaAttachment.fromJson(data);
      if(media.type == 'image') {
        picList.add(GestureDetector(
          child: Container(
            width: (ScreenUtil.width(context) - 50) / 3,
            height: (ScreenUtil.width(context) - 50) / 3,
            child: CachedNetworkImage(
              imageUrl: media.previewUrl,
            ),
          ),
          onTap: () {
            print('object');
          },
        ));
      } else {
        picList.add(Container());
      }
    }
    return picList;
  }

  @override
  Widget build(BuildContext context) { 
    return Container(
      width: ScreenUtil.width(context),
      padding: EdgeInsets.all(15),
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.end, 
        children: picAndVideo(context), //要显示的子控件集合
      )
    );
  }
}
