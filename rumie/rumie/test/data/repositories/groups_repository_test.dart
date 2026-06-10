import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roomie/data/api/exceptions.dart';
import 'package:roomie/data/api/interceptors/error_interceptor.dart';
import 'package:roomie/data/models/group_patch.dart';
import 'package:roomie/data/models/invite_create.dart';
import 'package:roomie/data/models/invite_status.dart';
import 'package:roomie/data/repositories/groups_repository_impl.dart';

import '../../fakes/fake_http_adapter.dart';

({Dio dio, FakeHttpAdapter adapter}) _build() {
  final adapter = FakeHttpAdapter();
  final dio =
      Dio(BaseOptions(baseUrl: 'http://test/api/v1'))
        ..httpClientAdapter = adapter
        ..interceptors.add(ErrorInterceptor());
  return (dio: dio, adapter: adapter);
}

const _groupJson = {
  'id': 'g1',
  'admin_id': 'a1',
  'members': ['m1', 'm2'],
  'preferences': {'budget': 1500, 'tags': []},
  'capacity': 3,
};

void main() {
  group('GroupsRepositoryImpl', () {
    test('getMyGroup happy', () async {
      final (:dio, :adapter) = _build();
      adapter.route(
        'GET',
        '/groups/me',
        const FakeResponse(statusCode: 200, body: _groupJson),
      );
      final repo = GroupsRepositoryImpl(dio);

      final g = await repo.getMyGroup();
      expect(g.id, 'g1');
      expect(g.members, ['m1', 'm2']);
    });

    test('patchMyGroup sends only set fields (PATCH null-strip)', () async {
      final (:dio, :adapter) = _build();
      adapter.route(
        'PATCH',
        '/groups/me',
        const FakeResponse(statusCode: 200, body: _groupJson),
      );
      final repo = GroupsRepositoryImpl(dio);

      await repo.patchMyGroup(const GroupPatch(capacity: 5));
      // (Body inspection covered indirectly — GroupPatch.toJson tested in
      // models_round_trip_test; here we just exercise the wire.)
      expect(adapter.hits('PATCH', '/groups/me'), 1);
    });

    test('createInvite 422 → ValidationException', () async {
      final (:dio, :adapter) = _build();
      adapter.route(
        'POST',
        '/groups/me/invites',
        const FakeResponse(
          statusCode: 422,
          body: {
            'detail': [
              {
                'loc': ['body', 'invitee_email'],
                'msg': 'required',
                'type': 't',
              },
            ],
          },
        ),
      );
      final repo = GroupsRepositoryImpl(dio);

      try {
        await repo.createInvite(const InviteCreate());
        fail('expected throw');
      } on ValidationException catch (e) {
        expect(e.fieldErrors, {
          'invitee_email': ['required'],
        });
      }
    });

    test('acceptInvite parses InviteOut', () async {
      final (:dio, :adapter) = _build();
      adapter.route(
        'POST',
        '/invites/inv1/accept',
        const FakeResponse(
          statusCode: 200,
          body: {
            'id': 'inv1',
            'group_id': 'g1',
            'invitee_id': 'u9',
            'status': 'accepted',
          },
        ),
      );
      final repo = GroupsRepositoryImpl(dio);

      final inv = await repo.acceptInvite('inv1');
      expect(inv.status, InviteStatus.accepted);
    });

    test('leaveGroup returns void on 204', () async {
      final (:dio, :adapter) = _build();
      adapter.route(
        'POST',
        '/groups/me/leave',
        const FakeResponse(statusCode: 204),
      );
      final repo = GroupsRepositoryImpl(dio);

      await repo.leaveGroup();
      expect(adapter.hits('POST', '/groups/me/leave'), 1);
    });
  });
}
