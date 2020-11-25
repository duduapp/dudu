import 'dart:io';

import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/models/task/register_help_task.dart';
import 'package:dudu/pages/login/model/app_credential.dart';
import 'package:dudu/utils/app_navigate.dart';
import 'package:dudu/utils/dialog_util.dart';
import 'package:dudu/utils/url_util.dart';
import 'package:dudu/widget/common/bottom_sheet_item.dart';
import 'package:dudu/widget/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
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
  String title = '网页';
  String url;

  WebViewController _controller;


  @override
  void initState() {
    url = widget.url;
    if (widget.appCredential != null) {
      url = '$url/oauth/authorize?scope=read+write+follow+push+admin%3Awrite%3Aaccounts&response_type=code&redirect_uri=${widget.appCredential.redirectUri}&client_id=${widget.appCredential.clientId}';
    }
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
                    onTap: () => UrlUtil.openUrl(widget.url),
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
        body: WebView(
          initialUrl: url,
          javascriptMode: JavascriptMode.unrestricted,
          initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
          navigationDelegate: (action) {
            if (!action.url.startsWith('http')) return NavigationDecision.prevent;
            setState(() {
              url = action.url;
            });
            if (widget.appCredential != null) {
              List<String> urlList = url.split("?");
              if (urlList[0].contains(widget.appCredential.redirectUri) && urlList[1].length != 0) {
                //error happend
                if (url.contains('error') && !url.contains('?code')) {
                  AppNavigate.pop();
                  return NavigationDecision.prevent;
                }
                List<String> codeList = url.split("=");
                AppNavigate.pop(param: codeList[1]);
              }
            }



            return NavigationDecision.navigate;
          },
          gestureNavigationEnabled: true,
          debuggingEnabled: true,
          onProgress: (p) async {
            if (mounted)
            setState(() {
              progress = p;
            });
          },

          onWebViewCreated: (controller) {
            _controller = controller;
            if (widget.appCredential != null) {
         //     _controller.clearCache();
              final cookieManager = CookieManager();
              cookieManager.clearCookies();
              _controller.clearCache();
            }


          },
          onPageFinished: (str) async {
            if (mounted) {
              _controller.getTitle().then((t) {
                setState(() {
                  title = t;
                });
              });
              if (widget.appCredential != null) {

                if (url == 'https://help.dudu.today/auth/sign_in') {
                  if (RegisterHelpTask.isRegistered()) {
                    _controller.evaluateJavascript(
                        "document.getElementById('user_email').value = '${RegisterHelpTask
                            .getEmail()}';");
                    _controller.evaluateJavascript(
                        "document.getElementById('user_password').value = '${RegisterHelpTask
                            .getPassword()}';");
                  } else {
                    RegisterHelpTask.start();
                  }
                }

              }
            }

          },
        ),
      ),
    );

  }


}
