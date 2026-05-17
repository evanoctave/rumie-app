import 'dart:typed_data';

import '../../data/models/asset_kind.dart';
import '../../data/models/presign_out.dart';

abstract class AssetRepository {
  Future<PresignOut> presign({
    required AssetKind kind,
    required String contentType,
  });

  /// 2-step upload (V8): presign → PUT bytes to `put_url` w/ ⊥ `Authorization`
  /// header. Returns the resulting `asset_url`.
  Future<String> upload({
    required AssetKind kind,
    required Uint8List bytes,
    required String contentType,
  });
}
