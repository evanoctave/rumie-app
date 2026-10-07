import 'dart:io';

import 'package:flutter/material.dart';

import '../di/locator.dart';
import '../domain/entities/entities.dart';
import '../domain/repositories/asset_repository.dart';
import '../domain/repositories/groups_repository.dart';
import '../models/user_profile.dart';
import '../utils/content_type.dart';

/// Owns the signed-in user's profile.
///
/// The API only models part of it: account basics (`UserOut`: age, photo)
/// and the roommate group's shared preferences (`GroupOut.preferences`:
/// budget, tags). Name, bio, location, schedule, tidiness, move-in and pets
/// have no server fields yet and stay on-device for the session.
class ProfileProvider extends ChangeNotifier {
  UserProfile _profile = const UserProfile(
    name: '',
    age: 0,
    bio: '',
    location: '',
    budgetMin: 800,
    budgetMax: 1500,
  );

  GroupOut? _group;
  Role? _role;
  String? _userId;

  UserProfile get profile => _profile;
  bool get hasProfile => _profile.isComplete;

  /// Landlords have no roommate group; preferences are not synced for them.
  bool get _syncsGroup => _role != Role.landlord;

  /// Pulls server-side fields into the local profile. Best effort: a failure
  /// (offline, no group yet) leaves the local profile untouched.
  Future<void> load(UserOut? user) async {
    // A different account signed in on this device: drop the previous
    // user's on-device fields.
    if (user != null && _userId != null && user.id != _userId) clear();
    _userId = user?.id;
    _role = user?.role;
    if (user != null) {
      _profile = _profile.copyWith(
        age: _profile.age > 0 ? _profile.age : user.age,
        photoPath: _profile.photoPath.isNotEmpty
            ? _profile.photoPath
            : (user.profilePhotoUrl ?? ''),
      );
      notifyListeners();
    }
    if (!_syncsGroup) return;
    try {
      _group = await locator<GroupsRepository>().getMyGroup();
      final prefs = _group!.preferences;
      _profile = _profile.copyWith(
        budgetMax: prefs.budget ?? _profile.budgetMax,
        budgetMin: (prefs.budget != null && prefs.budget! < _profile.budgetMin)
            ? prefs.budget
            : _profile.budgetMin,
        traits: prefs.tags.isNotEmpty ? prefs.tags : _profile.traits,
      );
      notifyListeners();
    } catch (_) {
      // Non-fatal; the profile screen still works from local state.
    }
  }

  /// Uploads a newly picked photo (2-step presign → PUT, V8) and patches the
  /// group's preferences. Throws the repository's typed `ApiException` on
  /// failure (`ValidationException` carries per-field errors, V5) and leaves
  /// the current profile unchanged.
  Future<void> save(UserProfile updated) async {
    var photo = updated.photoPath;
    if (photo.isNotEmpty && !_isRemote(photo)) {
      final bytes = await File(photo).readAsBytes();
      photo = await locator<AssetRepository>().upload(
        kind: AssetKind.avatar,
        bytes: bytes,
        contentType: contentTypeForPath(photo),
      );
    }

    if (_syncsGroup) {
      final current = _group?.preferences;
      _group = await locator<GroupsRepository>().patchMyGroup(
        GroupPatch(
          preferences: Preferences(
            budget: updated.budgetMax,
            genderPref: current?.genderPref,
            ageRange: current?.ageRange,
            tags: updated.traits,
          ),
        ),
      );
    }

    _profile = updated.copyWith(photoPath: photo);
    notifyListeners();
  }

  void clear() {
    _profile = const UserProfile(
      name: '',
      age: 0,
      bio: '',
      location: '',
      budgetMin: 800,
      budgetMax: 1500,
    );
    _group = null;
    _role = null;
    _userId = null;
    notifyListeners();
  }

  static bool _isRemote(String p) =>
      p.startsWith('http://') || p.startsWith('https://');
}
