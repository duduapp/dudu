import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:dudu/models/json_serializable/media_attachment.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/cache_manager.dart';
import 'package:dudu/utils/dialog_util.dart';
import 'package:dudu/utils/media_util.dart';
import 'package:dudu/widget/common/media_detail.dart';
import 'package:dudu/widget/flutter_framework/progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share/share.dart';
import 'package:share_extend/share_extend.dart';

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
            AppNavigate.pop();
          },
          child: Container(
            decoration: widget.backgroundDecoration,
            constraints: BoxConstraints.expand(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
            //Todo update flutter to 1.20 will make photo view not swipe,which will influence cached network image
            child: PhotoViewGallery.builder(
              scrollPhysics: const ClampingScrollPhysics(),
              builder: _buildItem,
              itemCount: widget.galleryItems.length,
              loadFailedChild: Container(
                color: Colors.black,
                child: Center(
                  child: Text(
                    '图片加载出现错误',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              loadingBuilder: (context, event) => Stack(
                children: [
                  Container(
                    color: Colors.black,
                    child: PhotoView(
                      imageProvider: CachedNetworkImageProvider(
                          widget.galleryItems[currentIndex].previewUrl,
                          cacheManager: CustomCacheManager()),
                      heroAttributes: PhotoViewHeroAttributes(
                          tag: widget.galleryItems[currentIndex].id),
                      initialScale: PhotoViewComputedScale.contained,
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 30.0,
                      height: 30.0,
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.transparent,
                        valueColor: new AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.5)),
                        strokeWidth: 30,
                        value: event == null
                            ? 0
                            : event.cumulativeBytesLoaded /
                                event.expectedTotalBytes,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundDecoration: widget.backgroundDecoration,
              pageController: widget.pageController,
              onPageChanged: onPageChanged,
              scrollDirection: widget.scrollDirection,
            ),
          )),
      title: widget.galleryItems.length > 1
          ? '${currentIndex + 1}/${widget.galleryItems.length}'
          : '',
      onDownloadClick: () async => await MediaUtil.downloadMedia(widget.galleryItems[currentIndex]),
      onShareClick: _onShareClick,
    );
  }

  _onShareClick() async{
    await MediaUtil.shareMedia(widget.galleryItems[currentIndex]);
  }

  downloadMedia() async {
    var item = widget.galleryItems[currentIndex];
    DialogUtils.toastDownloadInfo('正在下载中...');
    Response response;
    try {
      response = await Dio()
          .get(item.url, options: Options(responseType: ResponseType.bytes));
    } catch (e) {
      return;
    }
    final result =
        await ImageGallerySaver.saveImage(Uint8List.fromList(response.data));
  }

  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    var item = widget.galleryItems[index];
    return PhotoViewGalleryPageOptions(
      imageProvider: CachedNetworkImageProvider(item.url,
          cacheManager: CustomCacheManager()),
      heroAttributes: PhotoViewHeroAttributes(
        tag: item.id,
      ),

//      child: Container(
//        width: double.infinity,
//        child: CachedNetworkImage(
//          fit: BoxFit.contain,
//          imageUrl: item.url,
//          progressIndicatorBuilder: (context, url, downloadProgress) =>
//              Container(
//                child: Center(
//                  child: SizedBox(
//                    width: 100,
//                    height: 100,
//                    child: CircularProgressIndicator(
//                        value: downloadProgress.progress),
//                  ),
//                ),
//              ),
//        ),
//      ),
      //  childSize: const Size(300, 300),
      initialScale: PhotoViewComputedScale.contained,
      minScale: PhotoViewComputedScale.contained * 0.5,
      maxScale: PhotoViewComputedScale.contained * 3.0,
      // heroAttributes: PhotoViewHeroAttributes(tag: item.id),
    );
  }
}
