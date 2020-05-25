import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:fastodon/models/media_attachment.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/untils/dialog_util.dart';
import 'package:fastodon/widget/common/media_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PhotoGallery extends StatefulWidget {
  PhotoGallery({
    this.loadingBuilder,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
    this.initialIndex,
    @required this.galleryItems,
    this.scrollDirection = Axis.horizontal,
  }) : pageController = PageController(initialPage: initialIndex);

  final LoadingBuilder loadingBuilder;
  final Decoration backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final int initialIndex;
  final PageController pageController;
  final List<MediaAttachment> galleryItems;
  final Axis scrollDirection;

  @override
  State<StatefulWidget> createState() {
    return _PhotoGalleryState();
  }
}

class _PhotoGalleryState extends State<PhotoGallery> {
  int currentIndex;

  @override
  void initState() {
    currentIndex = widget.initialIndex;

    super.initState();
  }

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MediaDetail(
      child: InkWell(
          onTap: () {
            revertStatusBar();
            AppNavigate.pop(context);
          },
          child: Container(
            decoration: widget.backgroundDecoration,
            constraints: BoxConstraints.expand(
              height: MediaQuery.of(context).size.height,
            ),
            child: PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: _buildItem,
              itemCount: widget.galleryItems.length,
              loadingBuilder: widget.loadingBuilder,
              backgroundDecoration: widget.backgroundDecoration,
              pageController: widget.pageController,
              onPageChanged: onPageChanged,
              scrollDirection: widget.scrollDirection,
            ),
          )),
      title: '${currentIndex + 1}/${widget.galleryItems.length}',
      onDownloadClick: downloadMedia,
    );
  }

  downloadMedia() async {
    var item = widget.galleryItems[currentIndex];
    DialogUtils.toastDownloadInfo('正在下载中...');
    var response = await Dio()
        .get(item.url, options: Options(responseType: ResponseType.bytes));
    final result =
        await ImageGallerySaver.saveImage(Uint8List.fromList(response.data));
  }



  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    var item = widget.galleryItems[index];
    return PhotoViewGalleryPageOptions.customChild(
      child: Container(
        width: 300,
        height: 300,
        child: CachedNetworkImage(
          imageUrl: item.url,
        ),
      ),
      //  childSize: const Size(300, 300),
      initialScale: PhotoViewComputedScale.contained,
      minScale: PhotoViewComputedScale.contained * (0.5 + index / 10),
      maxScale: PhotoViewComputedScale.covered * 2.0,
      heroAttributes: PhotoViewHeroAttributes(tag: item.id),
    );
  }

  revertStatusBar() {
    FlutterStatusbarcolor.setStatusBarColor(Colors.white);
    FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
  }
}
