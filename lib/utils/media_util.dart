import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dudu/models/json_serializable/media_attachment.dart';
import 'package:dudu/utils/cache_manager.dart';
import 'package:dudu/utils/dialog_util.dart';
import 'package:dudu/widget/flutter_framework/progress_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:share_extend/share_extend.dart';

class MediaUtil {
  static Future<File> pickAndCompressImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return null;
    }
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
      return DialogUtils.toastFinishedInfo('没有存储权限');
    }
    if (attachment.type == 'image') {
      var file =
          (await CustomCacheManager().getFileFromCache(attachment.url))?.file;
      if (file != null) {
        ImageGallerySaver.saveFile(file.path);
        DialogUtils.toastDownloadInfo('文件已保存');
        return;
      }
    }

    DialogUtils.toastDownloadInfo('正在下载中...');
    Response response;
    try {
      response = await Dio().get(attachment.url,
          options: Options(responseType: ResponseType.bytes));
    } catch (e) {
      return;
    }
    final result =
        await ImageGallerySaver.saveImage(Uint8List.fromList(response.data));
  }
}
