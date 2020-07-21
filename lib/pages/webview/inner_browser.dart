import 'package:fastodon/public.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class InnerBrowser extends StatefulWidget {
  final String url;

  const InnerBrowser(this.url, {Key key}) : super(key: key);

  @override
  _InnerBrowserState createState() => _InnerBrowserState();
}

class _InnerBrowserState extends State<InnerBrowser> {
  double progress = 0;
  String title = '网页';

  @override
  Widget build(BuildContext context) {
    final _flutterWebviewPlugin = new FlutterWebviewPlugin();

    _flutterWebviewPlugin.onProgressChanged.listen((event) {
      setState(() {
        progress = event;
      });
    });

    _flutterWebviewPlugin.onStateChanged.listen((WebViewStateChanged st) async {
      String currentWebviewTitle = await _flutterWebviewPlugin.evalJavascript("window.document.title");
      setState(() => {title = currentWebviewTitle});
    });

    return WebviewScaffold(
      url: widget.url,
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.clear,size: 30,),onPressed: ()=>AppNavigate.pop(context),),
        title: Text(title),
        bottom: progress == 1
            ? null
            : PreferredSize(
                child: SizedBox(
                  height: 3,
                  child: LinearProgressIndicator(
                    value: progress,
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).buttonColor),
                  ),
                ),
                preferredSize: Size(double.infinity, 3.0),
              ),
      ),
    );
  }
}
