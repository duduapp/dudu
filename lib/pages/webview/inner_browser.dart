import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/dialog_util.dart';
import 'package:dudu/widget/common/bottom_sheet_item.dart';
import 'package:dudu/widget/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InnerBrowser extends StatefulWidget {
  final String url;

  const InnerBrowser(this.url, {Key key}) : super(key: key);

  @override
  _InnerBrowserState createState() => _InnerBrowserState();
}

class _InnerBrowserState extends State<InnerBrowser> {
  int progress = 0;
  double opacity = 0;
  String title = '网页';
  String url;

  WebViewController _controller;


  @override
  void initState() {
    url = widget.url;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
//    final _flutterWebviewPlugin = new FlutterWebviewPlugin();
//
//    _flutterWebviewPlugin.onProgressChanged.listen((event) {
//      setState(() {
//       // progress = event;
//      });
//    });
//
//    _flutterWebviewPlugin.onUrlChanged.listen((event) {
//      debugPrint(event);
//    });
//
//    _flutterWebviewPlugin.onStateChanged.listen((WebViewStateChanged st) async {
//      String currentWebviewTitle =
//          await _flutterWebviewPlugin.evalJavascript("window.document.title");
//      setState(() => {title = currentWebviewTitle});
//    });

    //ToDo update official flutter_webview when on progress is merged
    return Scaffold(
      appBar: CustomAppBar(
        title: Column(
          children: [
            Text(title,style: TextStyle(fontSize: 16),),
            Text(url ?? '',style: TextStyle(fontSize: 12,color: Theme.of(context).accentColor),)
          ],
        ),
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_horiz),
            onPressed: () {
              DialogUtils.showBottomSheet(context: context, widgets: [
                BottomSheetItem(
                  text: '分享',
                  onTap: () => Share.share(widget.url),
                ),
                Divider(indent: 60, height: 0),
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
                  color: Theme.of(context).backgroundColor,
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
                        Theme.of(context).buttonColor),
                  ),
                ),
                preferredSize: Size(double.infinity, 3.0),
              ),
      ),
      body: Opacity(
        opacity: opacity,
        child: WebView(
          initialUrl: widget.url,
          javascriptMode: JavascriptMode.unrestricted,
          navigationDelegate: (action) {
            setState(() {
              url = action.url;
            });
            return NavigationDecision.navigate;
          },
          gestureNavigationEnabled: true,
          debuggingEnabled: true,
          onProgress: (p) async{
            setState(() {
              progress = p;
              //ToDo solve first open webview black,not perfectly
              if (progress > 30 && opacity != 1) {
                setState(() {
                  opacity = 1;
                });
              }
            });
            if (progress == 100) {
            }
          },

          onWebViewCreated: (controller) {
            _controller = controller;
          },
          onPageFinished: (str) async{
            _controller.getTitle().then((t){
              setState(() {
                title = t;
              });
            });
            setState(()  {
              opacity = 1;
            });
          },
        ),
      ),
    );

//    return WebviewScaffold(
//      userAgent: 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.89 Mobile Safari/537.36',
//      url: widget.url,
//      withJavascript: true,
//      appBar: AppBar(
//        leading: IconButton(icon: Icon(Icons.clear,size: 30,),onPressed: ()=>AppNavigate.pop(),),
//        title: Text(title),
//        bottom: progress == 1
//            ? null
//            : PreferredSize(
//                child: SizedBox(
//                  height: 3,
//                  child: LinearProgressIndicator(
//                    value: progress,
//                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).buttonColor),
//                  ),
//                ),
//                preferredSize: Size(double.infinity, 3.0),
//              ),
//      ),
//    );
  }
}
