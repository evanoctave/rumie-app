import 'package:flutter/material.dart';

import '../models/user_profile.dart';

class ProfileProvider extends ChangeNotifier {
  UserProfile _profile = const UserProfile(
    name: '',
    age: 0,
    bio: '',
    location: '',
    budgetMin: 800,
    budgetMax: 1500,
  );

  UserProfile get profile => _profile;
  bool get hasProfile => _profile.isComplete;

  void update(UserProfile updated) {
    _profile = updated;
    notifyListeners();
  }

  void setPhoto(String path) {
    _profile = _profile.copyWith(photoPath: path);
    notifyListeners();
  }
}
