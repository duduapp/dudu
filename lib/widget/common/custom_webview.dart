import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class CustomWebView extends StatefulWidget {
  final AppBar appBar;
  final String url;
  final bool withJavascript;
  final bool clearCache;
  final bool clearCookies;
  final bool enableAppScheme;
  final String userAgent;
  final bool primary;
  final bool withZoom;
  final bool withLocalStorage;
  final bool withLocalUrl;
  final bool scrollBar;

  final Map<String, String> headers;

  _CustomWebViewState state;

  CustomWebView(
      {Key key,
        @required this.url,
        @required this.appBar,
        this.headers,
        this.withJavascript,
        this.clearCache,
        this.clearCookies,
        this.enableAppScheme,
        this.userAgent,
        this.primary = true,
        this.withZoom,
        this.withLocalStorage,
        this.withLocalUrl,
        this.scrollBar})
      : super(key: key);

  @override
  _CustomWebViewState createState() {
    if (state == null) {
      state = new _CustomWebViewState();
    }

    return state;
  }

  void notifyShowBottomSheet(
      BuildContext context, ScaffoldFeatureController controller) {
    if (state == null) {
      state = new _CustomWebViewState();
    }

    state._resizeWebViewRect(context, controller);
  }
}

class _CustomWebViewState extends State<CustomWebView> {
  final webviewReference = new FlutterWebviewPlugin();
  Rect _rect;
  Timer _resizeTimer;

  static bool bottomSheetState;

  var mediaQuery;

  @override
  void initState() {
    _buildWebViewRect(context);

    super.initState();
    webviewReference.close();
  }

  @override
  void dispose() {
    super.dispose();
    webviewReference.close();
    webviewReference.dispose();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    mediaQuery = MediaQuery.of(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _buildWebViewRect(context);
    return new Center(child: const CircularProgressIndicator());
  }

  void _buildWebViewRect(BuildContext context, {Rect newRect}) {
    Future.delayed(new Duration(milliseconds: 100), () {
      var rect;

      if (newRect != null) {
        rect = newRect;
      } else {
        rect = _buildRect(context);
      }

      if (_rect == null) {
        _rect = rect;
        webviewReference.launch(widget.url,
            headers: widget.headers,
            withJavascript: widget.withJavascript,
            clearCache: widget.clearCache,
            clearCookies: widget.clearCookies,
            enableAppScheme: widget.enableAppScheme,
            userAgent: widget.userAgent,
            rect: _rect,
            withZoom: widget.withZoom,
            withLocalStorage: widget.withLocalStorage,
            withLocalUrl: widget.withLocalUrl,
            scrollBar: widget.scrollBar);
      } else {
        if (_rect != rect) {
          _rect = rect;
          _resizeTimer?.cancel();
          _resizeTimer = new Timer(new Duration(milliseconds: 300), () {
            // avoid resizing to fast when build is called multiple time
            webviewReference.resize(_rect);
          });
        }
      }
    });
  }

  Rect _buildRect(BuildContext context) {
    if (mediaQuery == null) {
      mediaQuery = MediaQuery.of(context);
    }
    final topPadding = widget.primary ? mediaQuery.padding.top : 0.0;
    var top = topPadding;

    if (widget.appBar != null) {
      top = widget.appBar.preferredSize.height + topPadding;
    }

    if (top < 60) {
      top = top + 24;
    }

    var height = mediaQuery.size.height - top;

    debugPrint("top:$top");

    return new Rect.fromLTWH(0.0, top, mediaQuery.size.width, height);
  }

  _resizeWebViewRect(
      BuildContext context, ScaffoldFeatureController controller) {
    // 显示
    Future.delayed(new Duration(milliseconds: 500), () {
      if (context != null) {
        var height = context.size.height;
        debugPrint("bottomSheet height:$height");
        Rect rect = _buildRect(context);
        _buildWebViewRect(context,
            newRect: new Rect.fromLTWH(
                rect.left, rect.top, rect.width, rect.height - height));

        //隐藏
        if (controller != null) {
          controller.closed.then((value) {
            debugPrint("bottomSheet close");
            _buildWebViewRect(context);
          });
        }
      }
    });
  }
}