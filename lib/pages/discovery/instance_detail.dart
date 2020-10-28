import 'package:cached_network_image/cached_network_image.dart';
import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/models/json_serializable/instance_item.dart';
import 'package:dudu/pages/timeline/public_timeline.dart';
import 'package:dudu/pages/webview/inner_browser.dart';
import 'package:dudu/plugin/flutter_html/flutter_html.dart';
import 'package:dudu/public.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InstanceDetail extends StatelessWidget {
  final InstanceItem instance;
  final ScrollController scrollController;

  InstanceDetail(this.instance, this.scrollController);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 35, right: 20, left: 20),
        child: Container(
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => AppNavigate.pop(),
                    child: Container(
                    //    margin: EdgeInsets.only(bottom: 8),
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(IconFont.clear,color: Theme.of(context).primaryColor,size: 18,)),
                  ),
                  Spacer(),
                  FlatButton(onPressed: () => AppNavigate.push(InnerBrowser('https://'+instance.uri+'/about/more')), child: Text('阅读实例规则'))
                ],
              ),
              Expanded(
                  child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  color: Theme.of(context).primaryColor,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            CachedNetworkImage(
                              imageUrl: instance.thumbnail,
                              width: ScreenUtil.width(context) - 40,
                              fit: BoxFit.cover,
                            ),
                            Positioned.fill(
                                child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(8),
                                decoration: new BoxDecoration(
                                  gradient: new LinearGradient(
                                      colors: [
                                        const Color(0xffc1c3c8),
                                        const Color(0xff4f5f8),
                                      ],
                                      begin: const FractionalOffset(0.0, 1.0),
                                      end: const FractionalOffset(0.0, 0.0),
                                      stops: [0.0, 1.0],
                                      tileMode: TileMode.clamp),
                                ),
                                child: Text(
                                  instance.title,
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ))
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            instance.uri,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DefaultTextStyle.merge(
                              child: Html(
                                data: instance.description.isEmpty ? (instance.shortDescription ?? '') : instance.description,
                              ),
                              style: TextStyle(
                                  color: Theme.of(context).accentColor)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DefaultTextStyle.merge(
                            style:
                                TextStyle(color: Theme.of(context).accentColor),
                            child: Table(
                              columnWidths: {0: FractionColumnWidth(.4)},
                              defaultVerticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              children: [
                                TableRow(children: [
                                  Text(
                                    '联系人邮箱:',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(instance.email ?? '')
                                ]),
                                TableRow(children: [
                                  Text('用户数:', style: TextStyle(fontSize: 16)),
                                  Text(instance.stats['user_count'].toString())
                                ]),
                                TableRow(children: [
                                  Text('嘟文数:', style: TextStyle(fontSize: 16)),
                                  Text(
                                      instance.stats['status_count'].toString())
                                ]),
                                TableRow(children: [
                                  Text('版本:', style: TextStyle(fontSize: 16)),
                                  Text(
                                      instance.version)
                                ])
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    FlatButton(onPressed: () => AppNavigate.push(PublicTimeline(url: instance.uri,)), child: Text('浏览看看')),
                    FlatButton(onPressed: () {}, child: Text('登录')),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
