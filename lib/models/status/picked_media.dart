
import 'dart:io';

import 'package:dudu/models/json_serializable/media_attachment.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class PickedMedia {
  AssetEntity local;
  String url;
  File localFile;
  String description;
  MediaAttachment remote;


  PickedMedia({this.local,this.url,this.remote}) {
    getLocalFile();
  }

  getLocalFile() async{
    if (local != null) {
      localFile = await local.file;
    }
  }
}