import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fastodon/models/json_serializable/article_item.dart';
import 'package:fastodon/models/json_serializable/media_attachment.dart';
import 'package:fastodon/models/provider/settings_provider.dart';
import 'package:fastodon/pages/media/photo_gallery.dart';
import 'package:fastodon/pages/media/video_play.dart';
import 'package:fastodon/public.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:nav_router/nav_router.dart';
import 'package:provider/provider.dart';

class StatusItemMedia extends StatefulWidget {
  @override
  _StatusItemMediaState createState() => _StatusItemMediaState();

  final StatusItemData data;
  final List<MediaAttachment> images = [];

  StatusItemMedia(this.data) {
    for (dynamic obj in data.mediaAttachments) {
      images.add(MediaAttachment.fromJson(obj));
    }
  }
}

class _StatusItemMediaState extends State<StatusItemMedia> {
  bool sensitive;
  bool hideImage;

  @override
  void initState() {
    sensitive = widget.data.sensitive;
    if (sensitive)
      hideImage = true;
    else
      hideImage = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool showThumbnails =
        context.select<SettingsProvider, bool>((m) => m.get('show_thumbnails'));
    if (showThumbnails) {
      var mediaLength = widget.data.mediaAttachments.length;
      if (mediaLength == 1) {
        if (widget.images[0].type == 'audio') {
          return audio();
        } else {
          return imageWrapper(singleImage());
        }
      } else if (mediaLength == 2) {
        return imageWrapper(twoImages());
      } else if (mediaLength == 3) {
        return imageWrapper(threeImages());
      } else if (mediaLength == 4) {
        return imageWrapper(fourImages());
      }
    } else {
      return mediaWithNoThumbnail();
    }
    return Container(
      width: 0,
      height: 0,
    );
  }

  Widget mediaWithNoThumbnail() {
    return Padding(
      padding: const EdgeInsets.only(top: 10,bottom: 10),
      child: Column(
        children: <Widget>[
          for (MediaAttachment media in widget.images)
            InkWell(
              onTap: () => open(context, widget.images.indexOf(media)),
              child: Row(
                children: <Widget>[
                  Icon(media.type == 'image'
                      ? Icons.image
                      : media.type == 'video'
                          ? Icons.videocam
                          : media.type == 'audio'
                              ? Icons.audiotrack
                              : Icons.image),
                  Expanded(
                      child: Text(
                    media.description ?? '没有描述信息',
                    overflow: TextOverflow.ellipsis,
                  ))
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget singleImage() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return image(
            widget.images[0], 0, constraints.maxWidth, 220, BoxFit.cover);
      },
    );
  }

  Widget audio() {
    return InkWell(
      onTap: () {
        AppNavigate.push(VideoPlay(widget.images[0]));
      },
      child: ListTile(
        leading: Icon(Icons.music_note),
        title: Text(
          widget.images[0].description ?? '',
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ),
    );
  }

  Widget twoImages() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          child: Row(
            children: <Widget>[
              image(widget.images[0], 0, constraints.maxWidth * 0.494, 220,
                  BoxFit.cover),
              SizedBox(
                width: constraints.maxWidth * 0.012,
              ),
              image(widget.images[1], 1, constraints.maxWidth * 0.494, 220,
                  BoxFit.cover)
            ],
          ),
        );
      },
    );
  }

  Widget threeImages() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                image(widget.images[0], 0, constraints.maxWidth * 0.494, 110,
                    BoxFit.cover),
                SizedBox(
                  width: constraints.maxWidth * 0.012,
                ),
                image(widget.images[1], 1, constraints.maxWidth * 0.494, 110,
                    BoxFit.cover)
              ],
            ),
            SizedBox(
              height: constraints.maxWidth * 0.012,
            ),
            image(widget.images[2], 2, constraints.maxWidth, 110, BoxFit.cover),
          ],
        );
      },
    );
  }

  Widget fourImages() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                image(widget.images[0], 0, constraints.maxWidth * 0.494, 110,
                    BoxFit.cover),
                SizedBox(
                  width: constraints.maxWidth * 0.012,
                ),
                image(widget.images[1], 1, constraints.maxWidth * 0.494, 110,
                    BoxFit.cover)
              ],
            ),
            SizedBox(
              height: constraints.maxWidth * 0.012,
            ),
            Row(
              children: <Widget>[
                image(widget.images[2], 2, constraints.maxWidth * 0.494, 110,
                    BoxFit.cover),
                SizedBox(
                  width: constraints.maxWidth * 0.012,
                ),
                image(widget.images[3], 3, constraints.maxWidth * 0.494, 110,
                    BoxFit.cover)
              ],
            )
          ],
        );
      },
    );
  }

  Widget imageWrapper(Widget widget) {
    var primaryColor = Theme.of(context).primaryColor;
    return Padding(
      padding: EdgeInsets.only(top: 7,bottom: 10),
      child: Stack(
        children: <Widget>[
          widget,
          Align(
            alignment: Alignment.topLeft,
            child: hideImage == false
                ? IconButton(
                    icon: Icon(
                      Icons.remove_red_eye,
                      color: primaryColor,
                    ),
                    onPressed: () {
                      setState(() {
                        hideImage = true;
                      });
                    },
                  )
                : Container(),
          ),
          if (hideImage)
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      hideImage = false;
                    });
                  },
                  child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: new BoxDecoration(
                          //color is transparent so that it does not blend with the actual color specified
                          borderRadius: const BorderRadius.all(
                              const Radius.circular(8.0)),
                          color: new Color.fromRGBO(240, 240, 240,
                              0.5) // Specifies the background color and the opacity
                          ),
                      child: Text(sensitive ? '敏感内容' : '已隐藏的照片或视频')),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget image(
      MediaAttachment image, int idx, double width, double height, BoxFit fit) {
    var indicatorSize = width > height ? height / 2.5 : width / 2.5;
    var imageUrl;
    var type = image.type;
    if (type == 'video' || type == 'gifv') {
      imageUrl = image.previewUrl;
    } else {
      imageUrl = image.url;
    }
    return InkWell(
      onTap: () {
        if (sensitive && hideImage == true) {
          setState(() {
            hideImage = false;
          });
          return;
        } else if (hideImage == true) {
          setState(() {
            hideImage = false;
          });
          return;
        }
        open(context, idx);
      },
      child: Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Hero(
            tag: image.id,
            flightShuttleBuilder: (
                BuildContext flightContext,
                Animation<double> animation,
                HeroFlightDirection flightDirection,
                BuildContext fromHeroContext,
                BuildContext toHeroContext,
                ) {
              final Hero hero = flightDirection == HeroFlightDirection.push ? fromHeroContext.widget : toHeroContext.widget;
              return hero.child;
            },
            child: Image(
              width: width,
              height: height,
              fit: BoxFit.cover,
              loadingBuilder:  (context, widget,chunk) {
                if (chunk == null) {
                  return widget;
                }
                return Container(
                  width: width,
                  height: height,
                  child: Center(
                    child: SizedBox(
                      width: indicatorSize,
                      height: indicatorSize,
                      child: CircularProgressIndicator(
                          ),
                    ),
                  ),
                );
              },
              image: CachedNetworkImageProvider(imageUrl),
            ),
//            child: CachedNetworkImage(
//               fit: BoxFit.cover,
//                width: width,
//                height: height,
//                imageUrl: imageUrl,
//                progressIndicatorBuilder: (context, url, downloadProgress) =>
//                    Container(
//                      width: width,
//                      height: height,
//                      child: Center(
//                        child: SizedBox(
//                          width: indicatorSize,
//                          height: indicatorSize,
//                          child: CircularProgressIndicator(
//                              value: downloadProgress.progress),
//                        ),
//                      ),
//                    ),
//                errorWidget: (context, url, error) => Icon(Icons.error)),
          ),
        ),
        if (hideImage)
          Positioned.fill(
            child: ClipRRect(
                child: BlurHash(
                  hash: image.blurhash,
                ),
                borderRadius: BorderRadius.circular(8.0)),
          ),
        if ((image.type == 'video' || image.type == 'gifv') &&
            hideImage == false)
          Positioned.fill(
            child: Center(
                child: Icon(
              Icons.play_circle_filled,
              size: 65,
              color: Colors.white,
            )),
          )
      ]),
    );
  }

  void open(BuildContext context, final int index) {
    var image = widget.images[index];
    var type = image.type;
    Widget to;
    if (type == 'video' || type == 'gifv' || type == 'audio') {
      to = VideoPlay(widget.images[index]);
    } else {
      to = PhotoGallery(
        galleryItems: widget.images,
        initialIndex: index,
      );
    }
//    Navigator.of(context).push(
//      PageRouteBuilder(
//        transitionDuration: Duration(milliseconds: 2000),
//        pageBuilder: (
//            BuildContext context,
//            Animation<double> animation,
//            Animation<double> secondaryAnimation) {
//          return to;
//        },
//        transitionsBuilder: (
//            BuildContext context,
//            Animation<double> animation,
//            Animation<double> secondaryAnimation,
//            Widget child) {
//          return Align(
//            child: FadeTransition(
//              opacity: animation,
//              child: child,
//            ),
//          );
//        },
//      ),
//    );
    AppNavigate.push(to, routeType: RouterType.fade);
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class VideoPlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
