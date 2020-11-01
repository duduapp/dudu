import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dudu/models/instance/instance_manager.dart';
import 'package:dudu/models/instance/server_instance.dart';
import 'package:dudu/models/json_serializable/instance_item.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/pages/discovery/instance_detail.dart';
import 'package:dudu/pages/timeline/public_timeline.dart';
import 'package:dudu/plugin/flutter_html/flutter_html.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/dialog_util.dart';
import 'package:dudu/utils/screen.dart';
import 'package:dudu/utils/string_until.dart';
import 'package:dudu/utils/url_util.dart';
import 'package:dudu/widget/button/text_ink_well.dart';
import 'package:dudu/widget/common/bottom_sheet_item.dart';
import 'package:dudu/widget/common/html_content.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class InstanceSummary extends StatelessWidget {
  final ServerInstance item;
  final bool showAction;
  final Function onDelete;

  InstanceSummary(this.item, {this.showAction = true,this.onDelete});



  @override
  Widget build(BuildContext context) {
    var textScale =
        SettingsProvider.getWithCurrentContext('text_scale', listen: true);
    double headerHeight;
    headerHeight = ScreenUtil.scaleFromSetting(textScale) * 36;

    return Column(
      children: [
        MediaQuery(
          data: MediaQuery.of(context).copyWith(
              textScaleFactor: ScreenUtil.scaleFromSetting(
                  SettingsProvider().get('text_scale'))),
          child: InkWell(
            onLongPress: !item.fromServer ?() {
              DialogUtils.showBottomSheet(context: context,widgets: [
                BottomSheetItem(
                  text: '删除',
                  onTap: () {
                      InstanceManager.removeInstance(item.detail);
                      if (onDelete != null) onDelete();
                  },
                ),
                Container(
                  height: 8,
                  color: Theme.of(context).backgroundColor,
                ),

              ]);
            } : null,
            onTap: showAction && !item.fromStale ?() {
              AppNavigate.push(PublicTimeline(
                url: item.detail.uri,
              ));
              // showMaterialModalBottomSheet(
              //   expand: true,
              //     useRootNavigator: true,
              //     bounce: true,
              //     context: context,
              //     builder: (context, scrollController) {
              //       return InstanceDetail(item, scrollController);
              //     });
              //AppNavigate.push(InstanceDetail(item));
            } :null,
            child: Ink(
              color: item.fromStale ? Color.fromRGBO(230, 230, 230, 1):Theme.of(context).primaryColor,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: CachedNetworkImage(
                              imageUrl: item.detail.thumbnail,
                              width: headerHeight,
                              height: headerHeight,
                              fit: BoxFit.cover,
                              placeholder: (context, str) {
                                return Container(
                                  color: Theme.of(context).backgroundColor,
                                  height: headerHeight,
                                  width: headerHeight,
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: headerHeight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                item.detail.title,
                                style: TextStyle(height: 1, fontSize: 13.5),
                              ),
                              Spacer(),
                              Text(item.detail.uri,
                                  style: TextStyle(
                                      color: Theme.of(context).accentColor,
                                      height: 1,
                                      fontSize: 10)),
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
                    SizedBox(height: 9),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0, right: 5),
                      child: Text(
                        StringUtil.removeAllHtmlTags(item.detail.description.isEmpty
                            ? item.detail.shortDescription
                            : item.detail.description),
                        style: TextStyle(),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // SizedBox(
                    //   height: 4,
                    // ),
                    if (showAction) ...[
                      Divider(
                        height: 0,
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TextInkWell(
                              onTap: item.fromStale ? null: () async{await InstanceManager.login(item.detail);},
                              text: '登录',
                            ),
                            TextInkWell(
                              onTap: item.fromStale ? null :() {
                                UrlUtil.openUrl(
                                    'https://' + item.detail.uri + '/auth/sign_up');
                              },
                              text: '注册',
                            ),
                            TextInkWell(
                              onTap: item.fromStale ? null : () {
                                UrlUtil.openUrl(
                                    'https://' + item.detail.uri + '/about');
                              },
                              text: '更多',
                            ),
                          ],
                        ),
                      )
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        )
      ],
    );

    // return Container(
    //   width: double.infinity,
    //   height: 100,
    //   child: Card(
    //     child: ListTile(
    //       leading: CachedNetworkImage(
    //         imageUrl: item.thumbnail,
    //         height: 100,
    //         width: 80,
    //       ),
    //       title: Text(item.title),
    //       subtitle: Text(
    //         StringUtil.removeAllHtmlTags(item.shortDescription),
    //         maxLines: 4,
    //         overflow: TextOverflow.ellipsis,
    //       ),
    //     ),
    //   ),
    // );
  }
}
