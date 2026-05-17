import 'package:dio/dio.dart';

import '../../domain/repositories/listings_repository.dart';
import '../models/listing_create.dart';
import '../models/listing_out.dart';
import '../models/listing_patch.dart';
import 'repository_helpers.dart';

class ListingsRepositoryImpl implements ListingsRepository {
  final Dio _dio;

  ListingsRepositoryImpl(this._dio);

  @override
  Future<ListingOut> create(ListingCreate body) => callApi(() async {
        final r = await _dio.post<dynamic>('/listings', data: body.toJson());
        return ListingOut.fromJson(r.data as Map<String, dynamic>);
      });

  @override
  Future<ListingOut> get(String listingId) => callApi(() async {
        final r = await _dio.get<dynamic>('/listings/$listingId');
        return ListingOut.fromJson(r.data as Map<String, dynamic>);
      });

  @override
  Future<ListingOut> patch(String listingId, ListingPatch body) =>
      callApi(() async {
        final r = await _dio.patch<dynamic>(
          '/listings/$listingId',
          data: body.toJson(),
        );
        return ListingOut.fromJson(r.data as Map<String, dynamic>);
      });

  @override
  Future<void> delete(String listingId) => callApi(() async {
        await _dio.delete<dynamic>('/listings/$listingId');
      });
}
