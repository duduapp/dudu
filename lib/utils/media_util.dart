import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class MediaUtil {
  static Future<File> pickAndCompressImage()  async{
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    final directory = await getTemporaryDirectory();
    var targetPath = directory.path + '/' + image.path.split('/').last;
    var result = await FlutterImageCompress.compressAndGetFile(
      image.absolute.path, targetPath,
      quality: 50,
    );
    print(image.lengthSync());
    print(result.lengthSync());
    return result;
  }
}