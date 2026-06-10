import 'package:flutter_test/flutter_test.dart';
import 'package:roomie/data/api/interceptors/logging_interceptor.dart';

void main() {
  group('LoggingInterceptor.redactHeaders (V13)', () {
    test('redacts Authorization header', () {
      final out = LoggingInterceptor.redactHeaders({
        'Authorization': 'Bearer abc123',
        'Content-Type': 'application/json',
      });
      expect(out['Authorization'], LoggingInterceptor.redactedMarker);
      expect(out['Content-Type'], 'application/json');
    });

    test('redacts lowercase authorization header', () {
      final out = LoggingInterceptor.redactHeaders({
        'authorization': 'Bearer x',
      });
      expect(out['authorization'], LoggingInterceptor.redactedMarker);
    });
  });

  group('LoggingInterceptor.redactBody (V13)', () {
    test('redacts password field in request body', () {
      final out = LoggingInterceptor.redactBody({
        'email': 'a@b.com',
        'password': 'secret',
      });
      expect(out, {
        'email': 'a@b.com',
        'password': LoggingInterceptor.redactedMarker,
      });
    });

    test('redacts access and refresh in token response', () {
      final out = LoggingInterceptor.redactBody({
        'access': 'a',
        'refresh': 'r',
      });
      expect(out, {
        'access': LoggingInterceptor.redactedMarker,
        'refresh': LoggingInterceptor.redactedMarker,
      });
    });

    test('recurses into nested maps (RegisterOut tokens shape)', () {
      final out = LoggingInterceptor.redactBody({
        'user': {'id': '1', 'email': 'a@b.com'},
        'tokens': {'access': 'a', 'refresh': 'r'},
      });
      expect(out, {
        'user': {'id': '1', 'email': 'a@b.com'},
        'tokens': {
          'access': LoggingInterceptor.redactedMarker,
          'refresh': LoggingInterceptor.redactedMarker,
        },
      });
    });

    test('passes through non-sensitive fields and primitives unchanged', () {
      expect(LoggingInterceptor.redactBody('hello'), 'hello');
      expect(LoggingInterceptor.redactBody(42), 42);
      expect(LoggingInterceptor.redactBody(null), null);
      expect(LoggingInterceptor.redactBody({'foo': 'bar'}), {'foo': 'bar'});
    });

    test('redacts inside list of maps', () {
      final out = LoggingInterceptor.redactBody([
        {'password': 'a'},
        {'password': 'b'},
      ]);
      expect(out, [
        {'password': LoggingInterceptor.redactedMarker},
        {'password': LoggingInterceptor.redactedMarker},
      ]);
    });
  });
}
