import 'package:cached_network_image/cached_network_image.dart';
import 'package:fastodon/models/article_item.dart';
import 'package:fastodon/models/media_attachment.dart';
import 'package:fastodon/pages/common/photo_gallery.dart';
import 'package:fastodon/untils/screen.dart';
import 'package:flutter/material.dart';

class StatusItemMedia extends StatelessWidget {
  final StatusItemData data;
  final List<MediaAttachment> images = [];

  StatusItemMedia(this.data) {
    for (dynamic obj in data.mediaAttachments) {
      images.add(MediaAttachment.fromJson(obj));
    }
  }

  BuildContext context;

  @override
  Widget build(BuildContext context) {
    this.context = context;
    var mediaLength = data.mediaAttachments.length;
    if (mediaLength == 1) {
      var type = data.mediaAttachments[0]['type'];
      if (type == 'image') {
        return singleImage();
      } else if (type == 'video') {
        return singleVideo(data.mediaAttachments[0]);
      }
    } else if (mediaLength == 2) {
      return twoImages();
    } else if (mediaLength == 3) {
      return threeImages();
    } else if (mediaLength == 4) {
      return fourImages();
    }
    return Container(width: 0,height: 0,);
  }

  Widget singleImage() {
    return image(images[0],0,double.infinity,300,BoxFit.fitWidth);
  }

  Widget twoImages() {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints){
      return Container(
        child: Row(
          children: <Widget>[
            image(images[0],0,constraints.maxWidth*0.494,220,BoxFit.cover),
            SizedBox(width: constraints.maxWidth*0.012,),
            image(images[1],1,constraints.maxWidth*0.494,220,BoxFit.cover)
          ],
        ),
      );
    },);
  }

  Widget threeImages() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Column(
          children: <Widget>[
            Row(children: <Widget>[
              image(images[0],0,constraints.maxWidth*0.494,110,BoxFit.cover),
              SizedBox(width: constraints.maxWidth*0.012,),
              image(images[1],1,constraints.maxWidth*0.494,110,BoxFit.cover)
            ],),
            SizedBox(height: constraints.maxWidth*0.012,),
            image(images[2],2,constraints.maxWidth,110,BoxFit.cover),
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
               image(images[0],0,constraints.maxWidth*0.494,110,BoxFit.cover),
               SizedBox(width: constraints.maxWidth*0.012,),
               image(images[1],1,constraints.maxWidth*0.494,110,BoxFit.cover)
             ],
           ),
           SizedBox(height: constraints.maxWidth*0.012,),
           Row(
             children: <Widget>[
               image(images[2],2,constraints.maxWidth*0.494,110,BoxFit.cover),
               SizedBox(width: constraints.maxWidth*0.012,),
               image(images[3],3,constraints.maxWidth*0.494,110,BoxFit.cover)
             ],
           )
         ],
       );
     },
    );
  }

  Widget image(MediaAttachment image,int idx,double width,double height,BoxFit fit) {
    return InkWell(
      onTap: (){open(context, idx);},
      child: Hero(
        tag: image.id,
        child: Container(
            width: width,
            height: height,
            child: FittedBox(
              child: CachedNetworkImage(imageUrl: image.url),
              fit: fit,
            )),
      ),
    );
  }

  Widget singleVideo(dynamic attachment) {
    return Container();
  }

  void open(BuildContext context, final int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoGallery(
          galleryItems: images,
          backgroundDecoration: const BoxDecoration(
            color: Colors.black,
          ),
          initialIndex: index,
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }
}
