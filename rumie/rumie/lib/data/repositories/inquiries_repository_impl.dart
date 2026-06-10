import 'package:dio/dio.dart';

import '../../domain/repositories/inquiries_repository.dart';
import '../models/inquiry_out.dart';
import '../models/inquiry_status.dart';
import 'repository_helpers.dart';

class InquiriesRepositoryImpl implements InquiriesRepository {
  final Dio _dio;

  InquiriesRepositoryImpl(this._dio);

  @override
  Future<List<InquiryOut>> list({InquiryStatus? status}) => callApi(() async {
    final r = await _dio.get<dynamic>(
      '/inquiries',
      queryParameters:
          status == null ? null : {'status_filter': _encodeStatus(status)},
    );
    final list = r.data as List<dynamic>;
    return list
        .map((e) => InquiryOut.fromJson(e as Map<String, dynamic>))
        .toList();
  });

  @override
  Future<Map<String, dynamic>> accept(String inquiryId) => callApi(() async {
    final r = await _dio.post<dynamic>('/inquiries/$inquiryId/accept');
    return Map<String, dynamic>.from(r.data as Map);
  });

  @override
  Future<void> reject(String inquiryId) => callApi(() async {
    await _dio.post<dynamic>('/inquiries/$inquiryId/reject');
  });

  String _encodeStatus(InquiryStatus s) {
    switch (s) {
      case InquiryStatus.pending:
        return 'pending';
      case InquiryStatus.accepted:
        return 'accepted';
      case InquiryStatus.rejected:
        return 'rejected';
    }
  }
}
