import 'package:dudu/l10n/l10n.dart';



import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/models/status/picked_media.dart';
import 'package:dudu/utils/app_navigate.dart';
import 'package:dudu/widget/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class PickedMediaPreview extends StatelessWidget {
  final int initialIndex;
  final List<PickedMedia> medias;
  final PageController pageController;

  PickedMediaPreview(this.medias,this.initialIndex): pageController = PageController(initialPage: initialIndex);

  String getTitle() {
    return '';
  }

  PhotoViewGalleryPageOptions _buildLocalImageItem(BuildContext context, int index) {
    var item = medias[index];

    return PhotoViewGalleryPageOptions(
      imageProvider: FileImage(item.localFile),
      heroAttributes: PhotoViewHeroAttributes(
        tag: item.local.id,
      ),
      
      //  childSize: const Size(300, 300),
      initialScale: PhotoViewComputedScale.contained,
      minScale: PhotoViewComputedScale.contained * 1,
      maxScale: PhotoViewComputedScale.contained * 3.0,
      // heroAttributes: PhotoViewHeroAttributes(tag: item.id),
    );
  }
  
  Widget localImages() {
    return PhotoViewGallery.builder(
      scrollPhysics: const ClampingScrollPhysics(),
      builder: _buildLocalImageItem,
      itemCount: medias.length,
      loadFailedChild: Container(
        color: Colors.black,
        child: Center(
          child: Text(
            S.of(navGK.currentState.overlay.context).error_loading_image,
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
      pageController: pageController,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    Widget childWidget = Container();
    PickedMedia media = medias[initialIndex];
    
    if (media.local != null) {
      if (media.local.type == AssetType.image) {
        childWidget = localImages();
      } else if (media.local.type == AssetType.video) {
        
      } else if (media.local.type == AssetType.audio) {
        
      }
    }
    


    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        automaticallyImplyLeading: false,
        leading: InkWell(
          onTap: () => AppNavigate.pop(),
          child: Icon(IconFont.back,size: 28,color: Colors.white,),
        ),
        title: Text(
          getTitle(),
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        brightness: Brightness.dark,
        actions: <Widget>[

          IconButton(
            icon: Icon(IconFont.delete,color: Colors.white,),
            onPressed: null,
          ),
          IconButton(
            icon: Icon(IconFont.moreHoriz,color: Colors.white,),
            onPressed: null,
          )
          //   IconButton(icon: Icon(Icons.share,color: Colors.white,))
        ],
      ),
      body: childWidget,
    );
  }
}
