import '../api/rumie_api.dart';

class UploadService {
  // Use a dynamic type for the API to avoid a hard dependency on a specific
  // API class name which may differ across codegen or platforms.
  final dynamic api;

  UploadService(this.api);

  Future<dynamic> presignUpload({
    required String filename,
    required String contentType,
  }) {
    return api.presignUpload(
      filename: filename,
      contentType: contentType,
    );
  }
}