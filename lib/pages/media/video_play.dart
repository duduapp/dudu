import 'package:dudu/l10n/l10n.dart';

import 'package:cached_video_player/cached_video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
import 'package:dudu/models/json_serializable/media_attachment.dart';
import 'package:dudu/utils/cache_manager.dart';
import 'package:dudu/utils/dialog_util.dart';
import 'package:dudu/utils/media_util.dart';
import 'package:dudu/widget/common/loading_view.dart';
import 'package:dudu/widget/common/media_detail.dart';
import 'package:dudu/widget/dialog/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

class VideoPlay extends StatefulWidget {
  final MediaAttachment media;
  VideoPlay(this.media);

  @override
  _VideoPlayState createState() => _VideoPlayState();
}

class _VideoPlayState extends State<VideoPlay> {
  CachedVideoPlayerController videoPlayerController;
  ChewieController chewieController;

  bool fileDownloaded = false;

  void setPlayer() async{

    videoPlayerController = CachedVideoPlayerController.network(widget.media.url);


    MediaAttachment media = widget.media;
    var aspect;
    if ((media.type == "video" || media.type == "gifv")&& media.meta.containsKey('original')) {
      aspect =   media.meta['original']['width'] / media.meta['original']['height'];
    } else {
      aspect = media.meta['aspect'];
    }
    chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        autoPlay: true,
        looping: true,
        aspectRatio: aspect,

        showControlsOnInitialize: widget.media.type == 'audio' ? true : false);
    setState(() {
      fileDownloaded = true;
    });
  }

  @override
  void initState() {
    setPlayer();


    super.initState();
  }

  @override
  Widget build(BuildContext context) {


    return MediaDetail(
      child: Container(
        color: Colors.black,
        child: Hero(
          tag: widget.media.id,
          child: fileDownloaded ? Chewie(
            controller: chewieController,
          ) : Center(child: CircularProgressIndicator(strokeWidth: 2,)),
        ),
      ),
      title: "1/1",
      onDownloadClick: () async => await MediaUtil.downloadMedia(widget.media),
      onShareClick: () async {
        await MediaUtil.shareMedia(widget.media);
      },
    );
  }


  downloadMedia() async {
    DialogUtils.toastDownloadInfo(S.of(context).downloading);
    var appDocDir = await getTemporaryDirectory();
    var filename = widget.media.url.split('/').last.split('?').first;
    String savePath = appDocDir.path + filename;

    await Dio().download(widget.media.url, savePath);
    final result = await ImageGallerySaver.saveFile(savePath);
  }

  @override
  void dispose() {
    videoPlayerController?.dispose();
    chewieController?.dispose();
    super.dispose();
  }
}
