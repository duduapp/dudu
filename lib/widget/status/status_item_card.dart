

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fastodon/models/json_serializable/article_item.dart' hide Card;
import 'package:fastodon/pages/webview/inner_browser.dart';
import 'package:fastodon/public.dart';
import 'package:flutter/material.dart';

class StatusItemCard extends StatelessWidget {
  final StatusItemData statusData;

  const StatusItemCard(this.statusData,{Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (statusData.card != null && statusData.card.image != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: InkWell(
          onTap: () => AppNavigate.push(context, InnerBrowser(statusData.card.url)),
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
//              border: Border.all(color: Theme.of(context).accentColor),

              ),

              height: 120,

              child: Row(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(6),bottomLeft: Radius.circular(6)),
                    child: CachedNetworkImage(
                      width: 120,
                      height: 120,
                      imageUrl: statusData.card.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 3,right: 5),
                          child: Text(
                            statusData.card.title,
                            style: TextStyle(fontSize: 15),
                            softWrap: false,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: 5),
                        Expanded(child: Padding(
                          padding: const EdgeInsets.only(bottom:4.0,right: 5),
                          child: Text(statusData.card.description, style: TextStyle(fontSize: 14),overflow: TextOverflow.ellipsis,maxLines: 4,),
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
