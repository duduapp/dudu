

import 'dart:io';
import 'dart:typed_data';

import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
import 'package:fastodon/models/media_attachment.dart';
import 'package:fastodon/untils/app_navigate.dart';
import 'package:fastodon/widget/status_bar_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class VideoPlay extends StatefulWidget {
  final MediaAttachment media;
  VideoPlay(this.media);

  @override
  _VideoPlayState createState() => _VideoPlayState();
}

class _VideoPlayState extends State<VideoPlay> {
  VideoPlayerController videoPlayerController;
  ChewieController chewieController;


  @override
  Widget build(BuildContext context) {
    MediaAttachment media = widget.media;
    videoPlayerController = VideoPlayerController.network(
        media.url);

    var aspect;
    if (media.meta.containsKey('rotate')) {
      aspect = media.meta['height']/media.meta['width'];
    } else {
      aspect = media.meta['aspect'];
    }
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      looping: true,
      aspectRatio: aspect,
      showControlsOnInitialize: false
    );



    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back,color: Colors.white,),onPressed: (){revertStatusBar();AppNavigate.pop(context);},),
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.file_download,color: Colors.white,),onPressed: (){downloadMedia();},),
          //   IconButton(icon: Icon(Icons.share,color: Colors.white,))
        ],
      ),
      body: Container(
        color: Colors.black,
        child: StatusBarColor(
          child: Hero(
            tag: widget.media.id,
            child: Chewie(
              controller: chewieController,
            ),
          ),
          fromColor: Colors.white,
          toColor: Colors.black,
        ),
      ),

    );
  }

  showToast(String msg) {
    Fluttertoast.showToast(

        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 14.0);
  }

  downloadMedia() async{

    showToast('正在下载中...');

    var appDocDir = await getTemporaryDirectory();
    var filename = widget.media.url.split('/').last.split('?').first;
    String savePath = appDocDir.path + filename;

    await Dio().download(widget.media.url, savePath);
    final result = await ImageGallerySaver.saveFile(savePath);
  }

  revertStatusBar() {
    FlutterStatusbarcolor.setStatusBarColor(Colors.white);
    FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController.dispose();
    super.dispose();
  }
}
