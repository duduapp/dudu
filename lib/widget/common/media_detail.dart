

import 'package:fastodon/untils/app_navigate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';

class MediaDetail extends StatelessWidget {
  final Widget child;
  final String title;
  final Function onDownloadClick;

  MediaDetail({this.child,this.title,this.onDownloadClick});

  Future<bool> _onWillPop() async {
    revertStatusBar();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.black);
    FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              revertStatusBar();
              AppNavigate.pop(context);
            },
          ),
          title: Text(
            title,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.file_download,
                color: Colors.white,
              ),
              onPressed: () {
                onDownloadClick();
              },
            ),
            //   IconButton(icon: Icon(Icons.share,color: Colors.white,))
          ],
        ),
        body: child,
      ),
    );
  }


  revertStatusBar() {
    FlutterStatusbarcolor.setStatusBarColor(Colors.white);
    FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
  }
}
