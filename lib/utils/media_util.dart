import 'package:dudu/l10n/l10n.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dudu/models/json_serializable/media_attachment.dart';
import 'package:dudu/utils/cache_manager.dart';
import 'package:dudu/utils/dialog_util.dart';
import 'package:dudu/widget/flutter_framework/progress_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:mime/mime.dart';
import 'package:nav_router/nav_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:share_extend/share_extend.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class MediaUtil {
  static Future<File> pickAndCompressImage(BuildContext context) async {
    final List<AssetEntity> assets = await AssetPicker.pickAssets(
        context,
        maxAssets: 1,
        themeColor: Colors.blue,
        previewThumbSize: const <int>[1200, 1200],
        requestType: RequestType.image);

    if (assets == null || assets.isEmpty) {
      return null;
    }

    var image = await assets[0].file;

    if (Platform.isIOS) {
      var orignalFile = await assets[0].originFile;
      if (orignalFile.lengthSync() > 2 * 1024 * 1024) {
        DialogUtils.toastFinishedInfo(S.of(context).picture_file_must_be_less_than_2m);
        return null;
      }
      if (orignalFile.path.endsWith(".gif") || orignalFile.path.endsWith(".GIF")) {
        return orignalFile;
      }
    }

    if (image.lengthSync() > 2 * 1024 * 1024) {
      return await compressImageFile(image);
    }
    // do not compress gif
    if (image.path.endsWith(".gif") || image.path.endsWith(".GIF")) {
      return image;
    }


    return await compressImageFile(image);
  }
  
  static Future<File> compressImageFile(File image) async {
    final directory = await getTemporaryDirectory();
    var targetPath = directory.path + '/compress_' + image.path.split('/').last;
    var result = await FlutterImageCompress.compressAndGetFile(
      image.absolute.path,
      targetPath,
      quality: 50,
    );
    debugPrint(image.lengthSync().toString());
    debugPrint(result.lengthSync().toString());
    return result;
  }

  static String secondsToMedisDuration(double sec) {
    if (sec == null) return null;
    var duration = Duration(seconds: sec.toInt());
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  static shareMedia(MediaAttachment attachment) async {
    if (attachment.type == 'image') {
      File file;
      ProgressDialog dialog;
      file =
          (await CustomCacheManager().getFileFromCache(attachment.url))?.file;
      if (file != null) {
        ShareExtend.share(file.path, 'image');
        return;
      }
    }
    Share.share(attachment.url);
  }

  static downloadMedia(MediaAttachment attachment) async {
    if (await Permission.storage.request().isGranted) {

    } else {
      return DialogUtils.toastFinishedInfo(S.of(navGK.currentState.overlay.context).no_storage_permissions);
    }

    var file =
        (await CustomCacheManager().getFileFromCache(attachment.url))?.file;
    if (file != null) {
      // if (attachment.type == "video" || attachment.type == "gifv")
      //   await PhotoManager.editor.saveVideo(file);
      // else
      //   await PhotoManager.editor.saveImageWithPath(file.path);

      await ImageGallerySaver.saveFile(file.path);
      DialogUtils.toastDownloadInfo(S.of(navGK.currentState.overlay.context).file_saved);
      return;
    }


    DialogUtils.toastDownloadInfo(S.of(navGK.currentState.overlay.context).downloading);
    file =
        await CustomCacheManager().getSingleFile(attachment.url);

    ImageGallerySaver.saveFile(file.path);
  }
}
