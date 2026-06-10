import 'package:flutter/foundation.dart';

import '../domain/entities/match.dart';
import '../domain/entities/roommate_candidate.dart';

/// Mutual matches. In-memory for now; backed by `GET /matches` later.
class MatchesProvider extends ChangeNotifier {
  final List<RoommateMatch> _matches = [];

  List<RoommateMatch> get matches => List.unmodifiable(_matches);
  int get count => _matches.length;
  int get unreadCount => _matches.fold(0, (sum, m) => sum + m.unreadCount);

  bool isMatched(String profileId) =>
      _matches.any((m) => m.profile.id == profileId);

  /// Records a new match from a liked candidate. Returns false when the
  /// candidate was already matched.
  bool addFromCandidate(RoommateCandidate candidate) {
    if (isMatched(candidate.profile.id)) return false;
    _matches.insert(
      0,
      RoommateMatch(
        id: 'match-${candidate.profile.id}',
        profile: candidate.profile,
        matchedAt: DateTime.now(),
        lastMessagePreview: 'You matched — say hi!',
        unreadCount: 1,
        compatibilityScore: candidate.compatibilityScore,
      ),
    );
    notifyListeners();
    return true;
  }

  void markRead(String matchId) {
    final i = _matches.indexWhere((m) => m.id == matchId);
    if (i == -1 || _matches[i].unreadCount == 0) return;
    _matches[i] = _matches[i].copyWith(unreadCount: 0);
    notifyListeners();
  }

  void setPreview(String matchId, String preview) {
    final i = _matches.indexWhere((m) => m.id == matchId);
    if (i == -1) return;
    _matches[i] = _matches[i].copyWith(lastMessagePreview: preview);
    notifyListeners();
  }
}
