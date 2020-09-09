import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/pages/login/model/app_credential.dart';
import 'package:dudu/utils/app_navigate.dart';
import 'package:dudu/utils/dialog_util.dart';
import 'package:dudu/widget/common/bottom_sheet_item.dart';
import 'package:dudu/widget/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:nav_router/nav_router.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InnerBrowser extends StatefulWidget {
  final String url;
  final AppCredential appCredential;

  const InnerBrowser(this.url, {Key key,this.appCredential}) : super(key: key);

  @override
  _InnerBrowserState createState() => _InnerBrowserState();
}

class _InnerBrowserState extends State<InnerBrowser> {
  int progress = 0;
  double opacity = 0;
  String title = '网页';
  String url;

  WebViewController _controller;
  FlutterWebviewPlugin _flutterWebviewPlugin;


  @override
  void initState() {
    url = widget.url;
    if (widget.appCredential != null) {
      _flutterWebviewPlugin = FlutterWebviewPlugin();
      _flutterWebviewPlugin.onUrlChanged.listen((String url) {
        setState(() {
          this.url = url;
        });
        if (url.contains(widget.url)) {
          return;
        }
        List<String> urlList = url.split("?");
        if (urlList[0].contains(widget.appCredential.redirectUri) && urlList[1].length != 0) {
          List<String> codeList = url.split("=");
          AppNavigate.pop(param: codeList[1]);
          _flutterWebviewPlugin.dispose();
        }
      });

      _flutterWebviewPlugin.onProgressChanged.listen((event) {
        setState(() {
          progress = (event * 100).toInt();
        });
      });

      _flutterWebviewPlugin.onStateChanged.listen((WebViewStateChanged st) async {
        String currentWebviewTitle = await _flutterWebviewPlugin.evalJavascript("window.document.title");
        setState(() => {title = currentWebviewTitle.replaceAll('\"', "")});
      });
      url = '$url/oauth/authorize?scope=read%20write%20follow%20push&response_type=code&redirect_uri=${widget.appCredential.redirectUri}&client_id=${widget.appCredential.clientId}';
    }

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _flutterWebviewPlugin?.dispose();
  }

  Future<bool> _onWillPop() async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.appCredential != null) {
      

     return WebviewScaffold(
        url: url,
        appBar: CustomAppBar(
          title: Column(
            children: [
              Text(title, style: TextStyle(fontSize: 16),),
              Text(url ?? '', style: TextStyle(fontSize: 12, color: Theme
                  .of(context)
                  .accentColor),)
            ],

          ),
          elevation: 0,
          actions: <Widget>[
            IconButton(
              icon: Icon(IconFont.moreHoriz),
              onPressed: () async{
                _flutterWebviewPlugin.hide();
                await DialogUtils.showBottomSheet(context: navGK.currentState.overlay.context, widgets: [
                  BottomSheetItem(
                    text: '分享',
                    onTap: () => Share.share(url),
                  ),
                  Divider(indent: 0, height: 0),
                  BottomSheetItem(
                    text: '在浏览器中打开',
                    onTap: () async {
                      if (await canLaunch(widget.url)) {
                        await launch(widget.url);
                      } else {
                        // do nothing
                      }
                    },
                  ),
                  Container(
                    height: 8,
                    color: Theme
                        .of(context)
                        .backgroundColor,
                  ),
                ]);
                _flutterWebviewPlugin.show();
              },
            )
          ],
          bottom: progress == 100
              ? null
              : PreferredSize(
            child: SizedBox(
              height: 3,
              child: LinearProgressIndicator(
                value: progress / 100,
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme
                        .of(context)
                        .buttonColor),
              ),
            ),
            preferredSize: Size(double.infinity, 3.0),
          ),
        ),
        withZoom: true,
        withLocalStorage: true,
        hidden: true,
        initialChild: Container(),
        //initialChild: LoadingView(text: '加载中',color: Color.fromRGBO(25, 27, 34, 1),),

      );
    } else {
      //ToDo update official flutter_webview when on progress is merged
      return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: CustomAppBar(
            title: Column(
              children: [
                Text(title, style: TextStyle(fontSize: 16),),
                Text(url ?? '', style: TextStyle(fontSize: 12, color: Theme
                    .of(context)
                    .accentColor),)
              ],
            ),
            elevation: 0,
            actions: <Widget>[
              IconButton(
                icon: Icon(IconFont.moreHoriz),
                onPressed: () {
                  DialogUtils.showBottomSheet(context: context, widgets: [
                    BottomSheetItem(
                      text: '分享',
                      onTap: () => Share.share(url),
                    ),
                    Divider(indent: 0, height: 0),
                    BottomSheetItem(
                      text: '在浏览器中打开',
                      onTap: () async {
                        if (await canLaunch(widget.url)) {
                          await launch(widget.url);
                        } else {
                          // do nothing
                        }
                      },
                    ),
                    Container(
                      height: 8,
                      color: Theme
                          .of(context)
                          .backgroundColor,
                    ),
                  ]);
                },
              )
            ],
            bottom: progress == 100
                ? null
                : PreferredSize(
              child: SizedBox(
                height: 3,
                child: LinearProgressIndicator(
                  value: progress / 100,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme
                          .of(context)
                          .buttonColor),
                ),
              ),
              preferredSize: Size(double.infinity, 3.0),
            ),
          ),
          body: Opacity(
            opacity: opacity,
            child: WebView(
              initialUrl: url,
              javascriptMode: JavascriptMode.unrestricted,
              initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
              navigationDelegate: (action) {
                setState(() {
                  url = action.url;
                });

                return NavigationDecision.navigate;
              },
              gestureNavigationEnabled: true,
              debuggingEnabled: true,
              onProgress: (p) async {
                setState(() {
                  progress = p;
                  //ToDo solve first open webview black,not perfectly
                  if (progress > 30 && opacity != 1) {
                    setState(() {
                      opacity = 1;
                    });
                  }
                });
                if (progress == 100) {}
              },

              onWebViewCreated: (controller) {
                _controller = controller;
              },
              onPageFinished: (str) async {
                _controller.getTitle().then((t) {
                  setState(() {
                    title = t;
                  });
                });
                setState(() {
                  opacity = 1;
                });
              },
            ),
          ),
        ),
      );
    }

  }


}
