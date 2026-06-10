import 'package:dio/dio.dart';

import '../../domain/repositories/swipe_repository.dart';
import '../models/swipe_in.dart';
import '../models/swipe_out.dart';
import 'repository_helpers.dart';

class SwipeRepositoryImpl implements SwipeRepository {
  final Dio _dio;

  SwipeRepositoryImpl(this._dio);

  @override
  Future<SwipeOut> swipe(SwipeIn body) => callApi(() async {
    final r = await _dio.post<dynamic>('/swipes', data: body.toJson());
    return SwipeOut.fromJson(r.data as Map<String, dynamic>);
  });
}
