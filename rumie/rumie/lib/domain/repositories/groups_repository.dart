import '../../data/models/group_out.dart';
import '../../data/models/group_patch.dart';
import '../../data/models/invite_create.dart';
import '../../data/models/invite_out.dart';

abstract class GroupsRepository {
  Future<GroupOut> getMyGroup();
  Future<GroupOut> patchMyGroup(GroupPatch body);
  Future<void> leaveGroup();

  Future<InviteOut> createInvite(InviteCreate body);
  Future<InviteOut> acceptInvite(String inviteId);
  Future<void> rejectInvite(String inviteId);
}
