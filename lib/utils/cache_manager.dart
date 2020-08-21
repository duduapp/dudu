import 'package:path/path.dart' as p;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

class CustomCacheManager extends BaseCacheManager {
  static const key = 'libCachedImageData';

  static CustomCacheManager _instance;

  factory CustomCacheManager() {
    _instance ??= CustomCacheManager._();
    return _instance;
  }

  CustomCacheManager._() : super(key);

  @override
  Future<String> getFilePath() async {
    var directory = await getTemporaryDirectory();
    return p.join(directory.path, key);
  }
}