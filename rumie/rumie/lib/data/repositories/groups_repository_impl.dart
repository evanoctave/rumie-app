import 'package:dio/dio.dart';

import '../../domain/repositories/groups_repository.dart';
import '../models/group_out.dart';
import '../models/group_patch.dart';
import '../models/invite_create.dart';
import '../models/invite_out.dart';
import 'repository_helpers.dart';

class GroupsRepositoryImpl implements GroupsRepository {
  final Dio _dio;

  GroupsRepositoryImpl(this._dio);

  @override
  Future<GroupOut> getMyGroup() => callApi(() async {
        final r = await _dio.get<dynamic>('/groups/me');
        return GroupOut.fromJson(r.data as Map<String, dynamic>);
      });

  @override
  Future<GroupOut> patchMyGroup(GroupPatch body) => callApi(() async {
        final r = await _dio.patch<dynamic>(
          '/groups/me',
          data: body.toJson(),
        );
        return GroupOut.fromJson(r.data as Map<String, dynamic>);
      });

  @override
  Future<void> leaveGroup() => callApi(() async {
        await _dio.post<dynamic>('/groups/me/leave');
      });

  @override
  Future<InviteOut> createInvite(InviteCreate body) => callApi(() async {
        final r = await _dio.post<dynamic>(
          '/groups/me/invites',
          data: body.toJson(),
        );
        return InviteOut.fromJson(r.data as Map<String, dynamic>);
      });

  @override
  Future<InviteOut> acceptInvite(String inviteId) => callApi(() async {
        final r = await _dio.post<dynamic>('/invites/$inviteId/accept');
        return InviteOut.fromJson(r.data as Map<String, dynamic>);
      });

  @override
  Future<void> rejectInvite(String inviteId) => callApi(() async {
        await _dio.post<dynamic>('/invites/$inviteId/reject');
      });
}
