import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dudu/models/json_serializable/instance_item.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/pages/discovery/instance_detail.dart';
import 'package:dudu/pages/timeline/public_timeline.dart';
import 'package:dudu/plugin/flutter_html/flutter_html.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/screen.dart';
import 'package:dudu/utils/string_until.dart';
import 'package:dudu/utils/url_util.dart';
import 'package:dudu/widget/common/html_content.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class InstanceSummary extends StatelessWidget {
  final InstanceItem item;

  InstanceSummary(this.item);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MediaQuery(
          data: MediaQuery.of(context).copyWith(
              textScaleFactor: ScreenUtil.scaleFromSetting(
                  SettingsProvider().get('text_scale'))),
          child: InkWell(
            onTap: () {
              AppNavigate.push(PublicTimeline(url: item.uri,));
              // showMaterialModalBottomSheet(
              //   expand: true,
              //     useRootNavigator: true,
              //     bounce: true,
              //     context: context,
              //     builder: (context, scrollController) {
              //       return InstanceDetail(item, scrollController);
              //     });
              //AppNavigate.push(InstanceDetail(item));
            },
            child: Ink(
              child: Container(
                color: Theme.of(context).primaryColor,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: CachedNetworkImage(
                              imageUrl: item.thumbnail,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              placeholder: (context, str) {
                                return Container(
                                  color: Theme.of(context).backgroundColor,
                                  height: 50,
                                  width: 50,
                                );
                              },
                            ),
                          ),
                        ),
                         SizedBox(
                           height: 50,
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(item.uri,style: TextStyle(color: Theme.of(context).accentColor)),
                              Spacer(),
                              Text(item.title)
                            ],
                           ),
                         ),


                      ],
                    ),

                    // Padding(
                    //   padding: const EdgeInsets.only(top: 5, right: 5),
                    //   child: Text(
                    //     item.title,
                    //     style: TextStyle(fontSize: 12),
                    //     softWrap: false,
                    //     maxLines: 1,
                    //     overflow: TextOverflow.ellipsis,
                    //   ),
                    // ),
                    SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0, right: 5),
                      child: Text(
                    StringUtil.removeAllHtmlTags(
                        item.description.isEmpty
                            ? item.shortDescription
                            : item.description),
                    style: TextStyle(fontSize: 12),
                     maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // SizedBox(
                    //   height: 4,
                    // ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton(onPressed: (){}, child: Text('登录')),
                          TextButton(onPressed: (){UrlUtil.openUrl('https://'+item.uri+'/auth/sign_up');}, child: Text('注册')),
                          TextButton(onPressed: (){UrlUtil.openUrl('https://'+item.uri+'/about');}, child: Text('更多')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 10,)
      ],
    );

    return Container(
      width: double.infinity,
      height: 100,
      child: Card(
        child: ListTile(
          leading: CachedNetworkImage(
            imageUrl: item.thumbnail,
            height: 100,
            width: 80,
          ),
          title: Text(item.title),
          subtitle: Text(
            StringUtil.removeAllHtmlTags(item.shortDescription),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
