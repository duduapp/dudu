

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dudu/models/json_serializable/article_item.dart' hide Card;
import 'package:dudu/pages/webview/inner_browser.dart';
import 'package:dudu/public.dart';
import 'package:flutter/material.dart';

class StatusItemCard extends StatelessWidget {
  final StatusItemData statusData;

  const StatusItemCard(this.statusData,{Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (statusData.card != null && statusData.card.image != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 8,bottom: 8),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          child: InkWell(
            onTap: () => AppNavigate.push(InnerBrowser(statusData.card.url)),
            child: Ink(

              height: 130,

              child: Row(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(6),bottomLeft: Radius.circular(6)),
                    child: CachedNetworkImage(
                      width: 120,
                      height: 130,
                      imageUrl: statusData.card.image,
                      fit: BoxFit.cover,
                      placeholder: (context,str) {
                        return Container(
                          color: Theme.of(context).backgroundColor,
                          width: 120,
                          height: 130,
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Flexible(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5,right: 5),
                            child: Text(
                              statusData.card.title,
                              style: TextStyle(fontSize: 14),
                              softWrap: false,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        Flexible(flex:3,child: Padding(
                          padding: const EdgeInsets.only(bottom:4.0,right: 5),
                          child: Text(statusData.card.description, style: TextStyle(fontSize: 14),overflow: TextOverflow.ellipsis,maxLines: 3,),
                        )),
                        SizedBox(height: 5,),
                        Flexible(flex:1,child: Padding(
                          padding: const EdgeInsets.only(bottom:4.0,right: 5),
                          child: Text(statusData.card.url, style: TextStyle(fontSize: 14,color: Theme.of(context).accentColor),overflow: TextOverflow.ellipsis,maxLines: 1,),
                        ))
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
