/// Single import point for the types screens and widgets work with (V17).
///
/// The API DTOs double as domain entities (SPEC §C: `lib/domain/entities/`
/// only holds types that are distinct from a DTO), so they are re-exported
/// here; presentation code imports this file, never `lib/data/` directly.
library;

export '../../data/models/asset_kind.dart';
export '../../data/models/conversation_out.dart';
export '../../data/models/conversation_type.dart';
export '../../data/models/gender.dart';
export '../../data/models/group_out.dart';
export '../../data/models/group_patch.dart';
export '../../data/models/inquiry_out.dart';
export '../../data/models/inquiry_status.dart';
export '../../data/models/invite_create.dart';
export '../../data/models/invite_out.dart';
export '../../data/models/invite_status.dart';
export '../../data/models/listing_create.dart';
export '../../data/models/listing_out.dart';
export '../../data/models/listing_patch.dart';
export '../../data/models/login_in.dart';
export '../../data/models/message_out.dart';
export '../../data/models/preferences.dart';
export '../../data/models/presign_out.dart';
export '../../data/models/register_in.dart';
export '../../data/models/register_out.dart';
export '../../data/models/role.dart';
export '../../data/models/swipe_direction.dart';
export '../../data/models/swipe_in.dart';
export '../../data/models/swipe_out.dart';
export '../../data/models/swipe_target_type.dart';
export '../../data/models/tokens_out.dart';
export '../../data/models/user_out.dart';
export 'listing_meta.dart';
export 'match_summary.dart';
export 'roommate_candidate.dart';
