import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../domain/repositories/asset_repository.dart';
import '../api/exceptions.dart';
import '../models/asset_kind.dart';
import '../models/presign_in.dart';
import '../models/presign_out.dart';
import 'repository_helpers.dart';

class AssetRepositoryImpl implements AssetRepository {
  /// Main Dio (carries `AuthInterceptor`) — used for the `/uploads/presign`
  /// call. Bearer token is attached automatically.
  final Dio _dio;

  /// Bare Dio (no `AuthInterceptor`) — used for the PUT to the presigned URL.
  /// V8 forbids attaching `Authorization` to the S3 PUT.
  final Dio _putDio;

  AssetRepositoryImpl(this._dio, this._putDio);

  @override
  Future<PresignOut> presign({
    required AssetKind kind,
    required String contentType,
  }) => callApi(() async {
    final body = PresignIn(kind: kind, contentType: contentType).toJson();
    final r = await _dio.post<dynamic>('/uploads/presign', data: body);
    return PresignOut.fromJson(r.data as Map<String, dynamic>);
  });

  @override
  Future<String> upload({
    required AssetKind kind,
    required Uint8List bytes,
    required String contentType,
  }) async {
    final presigned = await presign(kind: kind, contentType: contentType);
    try {
      await _putDio.put<void>(
        presigned.putUrl,
        data: Stream<Uint8List>.fromIterable([bytes]),
        options: Options(
          headers: {
            'Content-Type': contentType,
            Headers.contentLengthHeader: bytes.length,
          },
          contentType: contentType,
        ),
      );
    } on DioException catch (e) {
      throw NetworkException('Upload PUT failed: ${e.message ?? e.type.name}');
    }
    return presigned.assetUrl;
  }
}
