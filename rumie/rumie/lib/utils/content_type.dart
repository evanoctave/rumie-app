/// MIME type for an image picked from the device, by file extension. Sent
/// as both `PresignIn.content_type` and the PUT `Content-Type` (V8).
String contentTypeForPath(String path) {
  final ext = path.split('.').last.toLowerCase();
  switch (ext) {
    case 'png':
      return 'image/png';
    case 'heic':
      return 'image/heic';
    case 'webp':
      return 'image/webp';
    case 'gif':
      return 'image/gif';
    default:
      return 'image/jpeg';
  }
}
