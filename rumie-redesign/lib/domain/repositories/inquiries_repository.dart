import '../../data/models/inquiry_out.dart';
import '../../data/models/inquiry_status.dart';

abstract class InquiriesRepository {
  Future<List<InquiryOut>> list({InquiryStatus? status});

  /// Server returns an open object (per OpenAPI); typed as `Map`.
  Future<Map<String, dynamic>> accept(String inquiryId);

  Future<void> reject(String inquiryId);
}
