import 'package:flutter/foundation.dart';

import '../di/locator.dart';
import '../domain/entities/roommate_group.dart';
import '../domain/repositories/roommate_group_repository.dart';

/// Drives the Groups surface.
class GroupProvider extends ChangeNotifier {
  GroupProvider({RoommateGroupRepository? repository})
    : _repo = repository ?? locator<RoommateGroupRepository>();

  final RoommateGroupRepository _repo;

  RoommateGroup? _group;
  bool _loading = true;

  RoommateGroup? get group => _group;
  bool get loading => _loading;

  Future<void> load() async {
    // No pre-notify: load() is kicked off from initState while the first
    // build is in flight, and _loading already starts true.
    if (!_loading) {
      _loading = true;
      notifyListeners();
    }
    _group = await _repo.myGroup();
    _loading = false;
    notifyListeners();
  }

  Future<void> attachListing(String listingId) async {
    _group = await _repo.attachListing(listingId);
    notifyListeners();
  }
}
