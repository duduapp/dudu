

import 'package:fastodon/untils/app_navigate.dart';
import 'package:flutter/material.dart';

class MediaDetail extends StatelessWidget {
  final Widget child;
  final String title;
  final Function onDownloadClick;

  MediaDetail({this.child,this.title,this.onDownloadClick});

  Future<bool> _onWillPop() async {
  //  revertStatusBar();
    return true;
  }

  @override
  Widget build(BuildContext context) {
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
              AppNavigate.pop(context);
            },
          ),
          title: Text(
            title,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          brightness: Brightness.dark,
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


}
