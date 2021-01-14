import 'package:dudu/l10n/l10n.dart';

import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/models/json_serializable/article_item.dart';
import 'package:dudu/models/json_serializable/media_attachment.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/pages/media/audio_play.dart';
import 'package:dudu/pages/media/photo_gallery.dart';
import 'package:dudu/pages/media/video_play.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/media_util.dart';
import 'package:dudu/widget/common/no_splash_ink_well.dart';
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
  bool hideImage;

  @override
  void initState() {
    if (widget.data.sensitive)
      hideImage = true;
    else
      hideImage = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (SettingsProvider().get('always_show_sensitive')) {
        setState(() {
          hideImage = false;
        });
      }
    });
    super.initState();
  }


  @override
  void didUpdateWidget(covariant StatusItemMedia oldWidget) {
    if (widget.data.sensitive)
      hideImage = true;
    else
      hideImage = false;
    super.didUpdateWidget(oldWidget);
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
    if (widget.images.isEmpty) {
      return Container();
    }
    return Padding(
      padding:
          EdgeInsets.only(top: widget.data.content.isEmpty ? 5 : 0, bottom: 8),
      child: Column(
        children: <Widget>[
          for (MediaAttachment media in widget.images)
            InkWell(
              onTap: () => open(context, widget.images.indexOf(media)),
              child: Row(
                children: <Widget>[
                  Icon(
                    media.type == 'image'
                        ? IconFont.picture
                        : media.type == 'video'
                            ? IconFont.video
                            : media.type == 'audio'
                                ? IconFont.audio
                                : IconFont.picture,
                    size: 16,
                  ),
                  Expanded(
                      child: Text(
                    media.description ?? S.of(context).no_description,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12),
                  ))
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget singleImage() {
    return image(
        widget.images[0], 0, ScreenUtil.width(context)-30, 220, BoxFit.cover);
  }

  Widget audio() {
    return InkWell(
      onTap: () {
        if (Platform.isIOS)
          AppNavigate.push(AudioPlay(widget.images[0]));
        else
          AppNavigate.push(VideoPlay(widget.images[0]));
      },
      child: Container(
        padding: EdgeInsets.only(
            bottom: 7, top: widget.data.content.isEmpty ? 6 : 0),
        child: Row(
          children: [
            Icon(
              IconFont.audio,
              size: 20,
            ),
            SizedBox(
              width: 3,
            ),
            Text(
                MediaUtil.secondsToMedisDuration(
                        widget.images[0].meta['original']['duration']) ??
                    '',
                style: TextStyle(fontSize: 11)),
            SizedBox(
              width: 3,
            ),
            Flexible(
              child: Text(
                widget.images[0].description ?? S.of(context).no_description_information,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(fontSize: 12),
              ),
            )
          ],
        ),
      ),
      // child: ListTile(
      //   leading: Icon(IconFont.audio,size: 30,),
      //   title: Text(
      //     widget.images[0].description ?? S.of(context).no_description_information,
      //     overflow: TextOverflow.ellipsis,
      //     maxLines: 2,
      //   ),
      // ),
    );
  }

  Widget twoImages() {
     var imageWidth = (ScreenUtil.width(context) - 30) * 0.494;
     return Container(
      child: Row(
        children: <Widget>[
          image(widget.images[0], 0, imageWidth, 220,
              BoxFit.cover),
          SizedBox(
            width: (ScreenUtil.width(context) - 30) * 0.012,
          ),
          image(widget.images[1], 1, imageWidth, 220,
              BoxFit.cover)
        ],
      ),
    );
  }

  Widget threeImages() {
    var imageWidth = (ScreenUtil.width(context) - 30) * 0.494;
    var dividerWidth = (ScreenUtil.width(context) - 30) * 0.012;
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            image(widget.images[0], 0, imageWidth, 110,
                BoxFit.cover),
            SizedBox(
              width: dividerWidth,
            ),
            image(widget.images[1], 1, imageWidth, 110,
                BoxFit.cover)
          ],
        ),
        SizedBox(
          height: dividerWidth,
        ),
        image(widget.images[2], 2, (ScreenUtil.width(context) - 30), 110, BoxFit.cover),
      ],
    );
  }

  Widget fourImages() {
    var imageWidth = (ScreenUtil.width(context) - 30) * 0.494;
    var dividerWidth = (ScreenUtil.width(context) - 30) * 0.012;
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            image(widget.images[0], 0, imageWidth, 110,
                BoxFit.cover),
            SizedBox(
              width: dividerWidth,
            ),
            image(widget.images[1], 1, imageWidth, 110,
                BoxFit.cover)
          ],
        ),
        SizedBox(
          height: dividerWidth,
        ),
        Row(
          children: <Widget>[
            image(widget.images[2], 2, imageWidth, 110,
                BoxFit.cover),
            SizedBox(
              width: dividerWidth,
            ),
            image(widget.images[3], 3, imageWidth, 110,
                BoxFit.cover)
          ],
        )
      ],
    );
  }

  Widget imageWrapper(Widget widget) {
    var primaryColor = Theme.of(context).primaryColor;
    return Padding(
      padding: EdgeInsets.only(
          top: this.widget.data.content.isEmpty ? 12 : 0, bottom: 13),
      child: Stack(
        children: <Widget>[
          widget,
          Align(
            alignment: Alignment.topLeft,
            child: hideImage == false
                ? IconButton(
                    icon: Icon(
                      IconFont.eyeClose,
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
                      child: Text(this.widget.data.sensitive ? S.of(context).sensitive_content : S.of(context).hidden_photo_or_video)),
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
      imageUrl = image.previewUrl;
    }
    return NoSplashInkWell(
      onTap: () {
        if (widget.data.sensitive && hideImage == true) {
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
              final Hero hero = flightDirection == HeroFlightDirection.push
                  ? fromHeroContext.widget
                  : toHeroContext.widget;
              return hero.child;
            },
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: width,
              height: height,
              fit: BoxFit.cover,
              progressIndicatorBuilder: (context, widget, chunk) {
                return Container(
                  color: Theme.of(context).backgroundColor,
                  width: width,
                  height: height,
                );
              },
              errorWidget: (context,url,error) {
                return Container();
              },
    //          memCacheWidth: width.toInt(),
      //        memCacheHeight: height.toInt() * 2,
            ),
//            child: Image(
//              width: width,
//              height: height,
//              fit: BoxFit.cover,
//              loadingBuilder:  (context, widget,chunk) {
//                if (chunk == null) {
//                  return widget;
//                }
//                return Container(
//                  color: Theme.of(context).backgroundColor,
//                  width: width,
//                  height: height,
//
//                );
//              },
//              errorBuilder: (context,object,trace) {
//                return Container(
//                  color: Theme.of(context).backgroundColor,
//                  width: width,
//                  height: height,
//                  child: Center(child: Text(!sensitive || !hideImage ? S.of(context).an_error_occurred: '',style: TextStyle(color: Theme.of(context).accentColor),),),
//                );
//              },
//              image: CachedNetworkImageProvider(imageUrl,cacheManager: CustomCacheManager()),
//            ),
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
                child: image.blurhash != null
                    ? BlurHash(
                        hash: image.blurhash,
                      )
                    : Container(color: Theme.of(context).scaffoldBackgroundColor,),
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
      List<MediaAttachment> medias = [];
      for (var media in widget.images) {
        if (media.type == 'image') {
          medias.add(media);
        }
      }
      if (widget.images[index].type == 'image') {
        to = PhotoGallery(
          galleryItems: medias,
          initialIndex: medias.indexOf(widget.images[index]),
        );
      }
      else
        return;
    }
//    Navigator.of(context).push(
//      PageRouteBuilder(
//        transitionDuration: Duration(milliseconds: 800),
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
