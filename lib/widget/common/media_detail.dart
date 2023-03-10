

import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/utils/app_navigate.dart';
import 'package:dudu/widget/common/custom_app_bar.dart';
import 'package:flutter/material.dart';

class MediaDetail extends StatelessWidget {
  final Widget child;
  final String title;
  final Function onDownloadClick;
  final Function onShareClick;

  MediaDetail({this.child,this.title,this.onDownloadClick,this.onShareClick});

  Future<bool> _onWillPop() async {
  //  revertStatusBar();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        leading: InkWell(
          onTap: () => AppNavigate.pop(),
          child: Icon(IconFont.back,size: 28,color: Colors.white,),
        ),
        automaticallyImplyLeading: false,
        title: Text(
          title,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        brightness: Brightness.dark,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              IconFont.download,
              color: Colors.white,
            ),
            onPressed: () {
              onDownloadClick();
            },
          ),
          IconButton(
            icon: Icon(IconFont.share),
            color: Colors.white,
            onPressed: onShareClick,
          )
          //   IconButton(icon: Icon(Icons.share,color: Colors.white,))
        ],
      ),
      body: child,
    );
  }


}
