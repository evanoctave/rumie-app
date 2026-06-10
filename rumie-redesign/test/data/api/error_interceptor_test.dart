import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roomie/data/api/exceptions.dart';
import 'package:roomie/data/api/interceptors/error_interceptor.dart';

import '../../fakes/fake_http_adapter.dart';

void main() {
  group('ErrorInterceptor.parseFieldErrors (V5)', () {
    test('parses single field error from FastAPI shape', () {
      final fe = ErrorInterceptor.parseFieldErrors({
        'detail': [
          {
            'loc': ['body', 'email'],
            'msg': 'value is not a valid email',
            'type': 'value_error.email',
          },
        ],
      });
      expect(fe, {
        'email': ['value is not a valid email'],
      });
    });

    test('aggregates multiple errors on same field', () {
      final fe = ErrorInterceptor.parseFieldErrors({
        'detail': [
          {
            'loc': ['body', 'password'],
            'msg': 'too short',
            'type': 'a',
          },
          {
            'loc': ['body', 'password'],
            'msg': 'must contain digit',
            'type': 'b',
          },
        ],
      });
      expect(fe, {
        'password': ['too short', 'must contain digit'],
      });
    });

    test('uses last non-scope segment from nested loc', () {
      final fe = ErrorInterceptor.parseFieldErrors({
        'detail': [
          {
            'loc': ['body', 'preferences', 'budget'],
            'msg': 'must be positive',
            'type': 'value_error',
          },
        ],
      });
      expect(fe, {
        'budget': ['must be positive'],
      });
    });

    test('malformed payloads → empty map', () {
      expect(ErrorInterceptor.parseFieldErrors(null), isEmpty);
      expect(ErrorInterceptor.parseFieldErrors('oops'), isEmpty);
      expect(ErrorInterceptor.parseFieldErrors({'detail': 'oops'}), isEmpty);
      expect(ErrorInterceptor.parseFieldErrors({'detail': []}), isEmpty);
    });
  });

  group('ErrorInterceptor.mapException (V6)', () {
    DioException req(DioExceptionType type, {int? statusCode, dynamic body}) {
      final opts = RequestOptions(path: '/x');
      return DioException(
        requestOptions: opts,
        type: type,
        response: statusCode == null
            ? null
            : Response<dynamic>(
                requestOptions: opts,
                statusCode: statusCode,
                data: body,
              ),
        message: 'msg',
      );
    }

    test('connectionTimeout → NetworkException', () {
      expect(
        ErrorInterceptor.mapException(req(DioExceptionType.connectionTimeout)),
        isA<NetworkException>(),
      );
    });

    test('connectionError → NetworkException', () {
      expect(
        ErrorInterceptor.mapException(req(DioExceptionType.connectionError)),
        isA<NetworkException>(),
      );
    });

    test('422 badResponse → ValidationException with parsed fields', () {
      final mapped = ErrorInterceptor.mapException(req(
        DioExceptionType.badResponse,
        statusCode: 422,
        body: {
          'detail': [
            {
              'loc': ['body', 'email'],
              'msg': 'bad',
              'type': 't',
            },
          ],
        },
      ));
      expect(mapped, isA<ValidationException>());
      expect(
        (mapped as ValidationException).fieldErrors,
        {
          'email': ['bad'],
        },
      );
    });

    test('500 badResponse → ServerException with statusCode', () {
      final mapped = ErrorInterceptor.mapException(
          req(DioExceptionType.badResponse, statusCode: 500));
      expect(mapped, isA<ServerException>());
      expect((mapped as ServerException).statusCode, 500);
    });

    test('401 badResponse → UnauthorizedException', () {
      final mapped = ErrorInterceptor.mapException(
          req(DioExceptionType.badResponse, statusCode: 401));
      expect(mapped, isA<UnauthorizedException>());
    });
  });

  group('ErrorInterceptor integration', () {
    test('attaches ValidationException as DioException.error for 422', () async {
      final adapter = FakeHttpAdapter()
        ..route(
          'GET',
          '/x',
          const FakeResponse(
            statusCode: 422,
            body: {
              'detail': [
                {
                  'loc': ['body', 'email'],
                  'msg': 'bad',
                  'type': 't',
                },
              ],
            },
          ),
        );
      final dio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'))
        ..httpClientAdapter = adapter
        ..interceptors.add(ErrorInterceptor());

      try {
        await dio.get<dynamic>('/x');
        fail('expected throw');
      } on DioException catch (e) {
        expect(e.error, isA<ValidationException>());
        expect((e.error as ValidationException).fieldErrors,
            {'email': ['bad']});
      }
    });

    test('passes through DioException whose error is already ApiException',
        () async {
      // Compose ErrorInterceptor after a stub that produces ApiException.
      final adapter = FakeHttpAdapter()
        ..route('GET', '/x', const FakeResponse(statusCode: 500));
      final dio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'))
        ..httpClientAdapter = adapter
        ..interceptors.add(InterceptorsWrapper(onError: (e, h) {
          h.next(DioException(
            requestOptions: e.requestOptions,
            response: e.response,
            type: e.type,
            error: const ServerException('pre-mapped', statusCode: 500),
          ));
        }))
        ..interceptors.add(ErrorInterceptor());

      try {
        await dio.get<dynamic>('/x');
        fail('expected throw');
      } on DioException catch (e) {
        expect(e.error, isA<ServerException>());
        expect((e.error as ServerException).message, 'pre-mapped');
      }
    });
  });
}
