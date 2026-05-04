import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/profile_model.dart';

const _profileBox = 'user_profile';
const _profileKey = 'my_profile';

class ProfileNotifier extends StateNotifier<UserProfile> {
  ProfileNotifier() : super(_defaultProfile()) {
    _load();
  }

  static UserProfile _defaultProfile() => UserProfile(
        id: const Uuid().v4(),
        name: 'New User',
        avatarUrl:
            'https://ui-avatars.com/api/?name=New+User&background=FFBE21&color=fff',
        dateOfBirth: DateTime.now().subtract(const Duration(days: 365 * 18)), // default 18 years
        joinedAt: DateTime.now(),
        level: 1,
        currentXP: 0,
        isSetup: false,
      );

  Box get _box => Hive.box(_profileBox);

  void _load() {
    final data = _box.get(_profileKey) as String?;
    if (data != null) {
      state = UserProfile.fromJson(data);
    } else {
      _save(state);
    }
  }

  void _save(UserProfile profile) {
    _box.put(_profileKey, profile.toJson());
  }

  void setupProfile({
    required String name,
    required DateTime dateOfBirth,
    required String designation,
    String? customAvatarUrl,
    String? localImagePath,
  }) {
    final updated = UserProfile(
      id: state.id,
      name: name,
      avatarUrl: (customAvatarUrl != null && customAvatarUrl.trim().isNotEmpty)
          ? customAvatarUrl.trim()
          : 'https://ui-avatars.com/api/?name=${name.replaceAll(' ', '+')}&background=FFBE21&color=fff',
      localImagePath: localImagePath,
      dateOfBirth: dateOfBirth,
      designation: designation,
      level: state.level,
      currentXP: state.currentXP,
      lifetimePoints: state.lifetimePoints,
      joinedAt: state.joinedAt,
      isSetup: true,
    );
    state = updated;
    _save(updated);
  }

  void updateName(String newName) {
    final updated = UserProfile(
      id: state.id,
      name: newName,
      avatarUrl:
          'https://ui-avatars.com/api/?name=${newName.replaceAll(' ', '+')}&background=FFBE21&color=fff',
      localImagePath: state.localImagePath,
      dateOfBirth: state.dateOfBirth,
      designation: state.designation,
      level: state.level,
      currentXP: state.currentXP,
      lifetimePoints: state.lifetimePoints,
      joinedAt: state.joinedAt,
      isSetup: state.isSetup,
    );
    state = updated;
    _save(updated);
  }

  void addXP(int amount) {
    int newXp = state.currentXP + amount;
    int newLevel = state.level;
    int nextLevelThreshold = state.level * 1000;

    // Level up logic
    while (newXp >= nextLevelThreshold) {
      newXp -= nextLevelThreshold;
      newLevel++;
      nextLevelThreshold = newLevel * 1000;
    }

    final updated = UserProfile(
      id: state.id,
      name: state.name,
      avatarUrl: state.avatarUrl,
      localImagePath: state.localImagePath,
      dateOfBirth: state.dateOfBirth,
      designation: state.designation,
      level: newLevel,
      currentXP: newXp,
      lifetimePoints: state.lifetimePoints + amount,
      joinedAt: state.joinedAt,
      isSetup: state.isSetup,
    );
    
    state = updated;
    _save(updated);
  }

  void updateImage(String? newPath) {
    final updated = UserProfile(
      id: state.id,
      name: state.name,
      avatarUrl: state.avatarUrl,
      localImagePath: newPath,
      dateOfBirth: state.dateOfBirth,
      designation: state.designation,
      level: state.level,
      currentXP: state.currentXP,
      lifetimePoints: state.lifetimePoints,
      joinedAt: state.joinedAt,
      isSetup: state.isSetup,
    );
    state = updated;
    _save(updated);
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, UserProfile>((ref) => ProfileNotifier());
