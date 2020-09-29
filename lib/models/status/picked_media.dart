
import 'dart:io';
import 'dart:typed_data';

import 'package:dudu/models/json_serializable/media_attachment.dart';
import 'package:dudu/utils/cache_manager.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class PickedMedia {
  AssetEntity local;
  String url;
  File localFile;
  String description;
  MediaAttachment remote;
  File _localThumbFile;

  PickedMedia({this.local,this.url,this.remote}) {
    getLocalFile();
  }

  getLocalFile() async{
    if (local != null) {
      localFile = await local.file;
    }
  }

  Future<File> localThumbFile() async{
    if (local == null) return null;
    var url = "thumb_" + (await local.file).path;
    var file = await CustomCacheManager().getFileFromCache(url);
    if (file == null) {
      Uint8List thumbData = await local.thumbData;
      return await CustomCacheManager().putFile(url, thumbData);
    }
    return file.file;
  }
}