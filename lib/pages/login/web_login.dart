import 'package:fastodon/widget/common/loading_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'model/app_credential.dart';
import 'package:fastodon/utils/app_navigate.dart';

class WebLogin extends StatefulWidget {
  WebLogin({Key key, this.serverItem, this.hostUrl}) : super(key: key);

  final AppCredential serverItem;
  final String hostUrl;

  @override
  _WebLoginState createState() => _WebLoginState();
}

class _WebLoginState extends State<WebLogin> {
  bool loading = true;

  Widget build(BuildContext context) {
    final _flutterWebviewPlugin = new FlutterWebviewPlugin();

    _flutterWebviewPlugin.onUrlChanged.listen((String url) {
      if (url.contains(widget.hostUrl)) {
        return;
      }
      List<String> urlList = url.split("?");
      if (urlList[0].contains(widget.serverItem.redirectUri) &&
          urlList[1].length != 0) {
        List<String> codeList = url.split("=");
        AppNavigate.pop(context, param: codeList[1]);
      }
    });

    _flutterWebviewPlugin.onStateChanged.listen((WebViewStateChanged state) {
      switch (state.type) {
        case WebViewState.finishLoad:
          setState(() {
            loading = false;
          });
          break;
      }
    });

    String url =
        '${widget.hostUrl}/oauth/authorize?scope=read%20write%20follow%20push&response_type=code&redirect_uri=${widget.serverItem.redirectUri}&client_id=${widget.serverItem.clientId}';
    return WebviewScaffold(
      url: url,
      appBar: new AppBar(
        title: Text(
          '登录',
        ),
        actions: <Widget>[
          if (loading)
            Container(
                padding: EdgeInsets.fromLTRB(0, 10, 12, 0),
                child: Theme(
                    data: ThemeData(
                        cupertinoOverrideTheme:
                            CupertinoThemeData(brightness: Brightness.dark)),
                    child: CupertinoActivityIndicator()))
        ],
        backgroundColor: Color.fromRGBO(40, 44, 55, 1),
      ),
      withZoom: true,
      withLocalStorage: true,
      initialChild: LoadingView(),
    );
  }
}
