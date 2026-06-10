import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

class FakeResponse {
  final int statusCode;
  final dynamic body;
  const FakeResponse({required this.statusCode, this.body});
}

/// Minimal in-memory [HttpClientAdapter] for interceptor tests. Routes are
/// keyed by `METHOD path`. Each call consumes the head of the route's queue;
/// if only one entry remains it is reused. Tracks per-route hit counts.
class FakeHttpAdapter implements HttpClientAdapter {
  final Map<String, List<FakeResponse>> _routes = {};
  final Map<String, int> _hits = {};

  Duration responseDelay = Duration.zero;

  void route(String method, String path, FakeResponse response) {
    final key = _key(method, path);
    _routes.putIfAbsent(key, () => <FakeResponse>[]).add(response);
  }

  int hits(String method, String path) => _hits[_key(method, path)] ?? 0;

  static String _key(String method, String path) =>
      '${method.toUpperCase()} $path';

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    // Match against the path Dio computes — covers both relative `/me` and
    // absolute path under a baseUrl. Query strings (e.g. presigned-URL
    // signatures) are ignored so routes can be keyed by bare path.
    final key = _key(options.method, options.path.split('?').first);
    _hits[key] = (_hits[key] ?? 0) + 1;

    if (responseDelay > Duration.zero) {
      await Future<void>.delayed(responseDelay);
    }

    final queue = _routes[key];
    if (queue == null || queue.isEmpty) {
      return ResponseBody.fromString(
        '',
        404,
        headers: {
          Headers.contentTypeHeader: ['text/plain'],
        },
      );
    }
    final entry = queue.length == 1 ? queue.first : queue.removeAt(0);
    final body =
        entry.body == null
            ? ''
            : (entry.body is String
                ? entry.body as String
                : jsonEncode(entry.body));
    return ResponseBody.fromString(
      body,
      entry.statusCode,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
