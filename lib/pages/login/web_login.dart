import 'package:dudu/l10n/l10n.dart';
// import 'package:dudu/utils/app_navigate.dart';
// import 'package:dudu/widget/common/custom_app_bar.dart';
// import 'package:dudu/widget/common/loading_view.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
//
// import 'model/app_credential.dart';
//
// class WebLogin extends StatelessWidget {
//   WebLogin({Key key, this.serverItem, this.hostUrl}) : super(key: key);
//
//   final AppCredential serverItem;
//   final String hostUrl;
//
//
//   @override
//   Widget build(BuildContext context) {
//     final _flutterWebviewPlugin = new FlutterWebviewPlugin();
//
//     _flutterWebviewPlugin.onUrlChanged.listen((String url) {
//       if (url.contains(hostUrl)) {
//         return;
//       }
//       List<String> urlList = url.split("?");
//       if (urlList[0].contains(serverItem.redirectUri) && urlList[1].length != 0) {
//         List<String> codeList = url.split("=");
//         AppNavigate.pop(param: codeList[1]);
//       }
//     });
//
//     String url = '$hostUrl/oauth/authorize?scope=read%20write%20follow%20push&response_type=code&redirect_uri=${serverItem.redirectUri}&client_id=${serverItem.clientId}';
//     return WebviewScaffold(
//         url: url,
//         appBar: new CustomAppBar(
//           title: new Text(S.of(context).log_in),
//           backgroundColor: Color.fromRGBO(40, 44, 55, 1),
//         ),
//         withZoom: true,
//         withLocalStorage: true,
//       hidden: true,
//       initialChild: LoadingView(text: S.of(context).loading,color: Color.fromRGBO(25, 27, 34, 1),),
//
//     );
//   }
//
// }
