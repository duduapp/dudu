
import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
import 'package:fastodon/models/media_attachment.dart';
import 'package:fastodon/utils/dialog_util.dart';
import 'package:fastodon/widget/common/media_detail.dart';
import 'package:flutter/material.dart';
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
  void initState() {
    MediaAttachment media = widget.media;
    videoPlayerController = VideoPlayerController.network(media.url);

    var aspect;
    if (media.meta.containsKey('rotate')) {
      aspect = media.meta['height'] / media.meta['width'];
    } else {
      aspect = media.meta['aspect'];
    }
    chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        autoPlay: true,
        looping: true,
        aspectRatio: aspect,
        showControlsOnInitialize: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {


    return MediaDetail(
      child: Container(
        color: Colors.black,
        child: Hero(
          tag: widget.media.id,
          child: Chewie(
            controller: chewieController,
          ),
        ),
      ),
      title: "1/1",
      onDownloadClick: downloadMedia,
    );
  }


  downloadMedia() async {
    DialogUtils.toastDownloadInfo('正在下载中...');
    var appDocDir = await getTemporaryDirectory();
    var filename = widget.media.url.split('/').last.split('?').first;
    String savePath = appDocDir.path + filename;

    await Dio().download(widget.media.url, savePath);
    final result = await ImageGallerySaver.saveFile(savePath);
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController.dispose();
    super.dispose();
  }
}
