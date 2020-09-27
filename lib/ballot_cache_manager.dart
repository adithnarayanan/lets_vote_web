import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class BallotCacheManager extends BaseCacheManager {
  static const key = 'ballotCache';

  static BallotCacheManager _instance;

  factory BallotCacheManager() {
    if (_instance == null) {
      _instance = new BallotCacheManager._();
    }
    return _instance;
  }

  BallotCacheManager._() : super(key, maxAgeCacheObject: Duration(days: 3));

  Future<String> getFilePath() async {
    var directory = await getTemporaryDirectory();
    return path.join(directory.path, key);
  }
}
