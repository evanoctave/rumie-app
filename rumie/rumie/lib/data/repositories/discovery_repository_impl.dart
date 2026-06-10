import 'package:dio/dio.dart';

import '../../domain/repositories/discovery_repository.dart';
import '../models/group_out.dart';
import '../models/listing_out.dart';
import 'repository_helpers.dart';

class DiscoveryRepositoryImpl implements DiscoveryRepository {
  final Dio _dio;

  DiscoveryRepositoryImpl(this._dio);

  @override
  Future<List<GroupOut>> discoverGroups({int limit = 20}) => callApi(() async {
    final r = await _dio.get<dynamic>(
      '/discovery/groups',
      queryParameters: {'limit': limit},
    );
    final list = r.data as List<dynamic>;
    return list
        .map((e) => GroupOut.fromJson(e as Map<String, dynamic>))
        .toList();
  });

  @override
  Future<List<ListingOut>> discoverListings({int limit = 20}) =>
      callApi(() async {
        final r = await _dio.get<dynamic>(
          '/discovery/listings',
          queryParameters: {'limit': limit},
        );
        final list = r.data as List<dynamic>;
        return list
            .map((e) => ListingOut.fromJson(e as Map<String, dynamic>))
            .toList();
      });
}
