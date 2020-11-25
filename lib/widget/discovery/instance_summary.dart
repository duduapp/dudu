import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/models/instance/instance_manager.dart';
import 'package:dudu/models/instance/server_instance.dart';
import 'package:dudu/models/json_serializable/instance_item.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/pages/discovery/instance_detail.dart';
import 'package:dudu/pages/timeline/public_timeline.dart';
import 'package:dudu/pages/webview/inner_browser.dart';
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
  final bool restrictedMode; // can not register,can not view federated timeline, can not open timeline

  InstanceSummary(this.item, {this.showAction = true,this.onDelete,this.restrictedMode = true});



  @override
  Widget build(BuildContext context) {
    var textScale =
        SettingsProvider.getWithCurrentContext('text_scale', listen: false);
    double headerHeight;
    headerHeight = ScreenUtil.scaleFromSetting(textScale) * 36;
    String urlWithoutHttpPrefix;
    if (item.detail.uri.startsWith('https://'))
      urlWithoutHttpPrefix = item.detail.uri.replaceFirst('https://', '');
    else
      urlWithoutHttpPrefix = item.detail.uri;
    return Column(
      children: [
        MediaQuery(
          data: MediaQuery.of(context).copyWith(
              textScaleFactor: ScreenUtil.scaleFromSetting(
                  SettingsProvider().get('text_scale'))),
          child: InkWell(

            onTap: showAction && !item.url.startsWith('help.dudu.today') ?() {
              var url = item.detail.uri;
              if (url.startsWith('https://'))
                url = url.replaceFirst('https://', '');
              AppNavigate.push(PublicTimeline(
                url: url,
                enableFederated: restrictedMode ? false : true,
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
                              memCacheHeight: 100,
                              memCacheWidth: 100,

                              placeholder: (context, str) {
                                return Container(
                                  color: Theme.of(context).backgroundColor,
                                  height: headerHeight,
                                  width: headerHeight,
                                );
                              },
                              errorWidget:(context,url,error) {
                                return Container(
                                  color: Theme.of(context).backgroundColor,
                                  height: headerHeight,
                                  width: headerHeight,
                                );
                              } ,
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
                              Row(
                                children: [
                                  Text(
                                    item.detail.title,
                                    style: TextStyle(height: 1, fontSize: 13.5),
                                  ),

                                ],
                              ),
                              Spacer(),
                              Text(urlWithoutHttpPrefix,
                                  style: TextStyle(
                                      color: Theme.of(context).accentColor,
                                      height: 1,
                                      fontSize: 11)),
                              SizedBox(height: 3,),
                            ],
                          ),
                        ),
                        Spacer(),
                        SizedBox(
                          width: 25,
                          height: 25,
                          child: !showAction? Container() :IconButton(icon: Icon(IconFont.expandMore,size: 20,), onPressed: () {
                            DialogUtils.showBottomSheet(context: context,widgets: [
                              BottomSheetItem(
                                text: '删除',
                                onTap: item.fromServer ? null : () {
                                  InstanceManager.removeInstance(item.detail);
                                  if (onDelete != null) onDelete();
                                },
                                color: item.fromServer ? Colors.grey : null,
                              ),
                              Container(
                                height: 8,
                                color: Theme.of(context).backgroundColor,
                              ),

                            ]);
                          } ,padding: EdgeInsets.all(0), ),
                        )
                      ],
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                    SizedBox(height: 7.5),
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
                              onTap: () async{await InstanceManager.login(item.detail);},
                              text: '登录',
                              activeColor: Theme.of(context).accentColor,
                            ),
                            TextInkWell(
                              onTap: restrictedMode ? (){} :() {
                                UrlUtil.openUrl(
                                    'https://' + urlWithoutHttpPrefix + '/auth/sign_up');
                              },
                              text: '注册',
                              activeColor: Theme.of(context).accentColor,
                            ),
                            TextInkWell(
                              onTap:  () {
                                AppNavigate.push(InnerBrowser('https://' + urlWithoutHttpPrefix + '/about/more'));
                              },
                              text: '更多',
                              activeColor: Theme.of(context).accentColor,
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
