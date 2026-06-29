import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/user_profile.dart';

final userProfilesProvider = StateNotifierProvider<UserProfileNotifier, List<UserProfile>>((ref) {
  return UserProfileNotifier();
});

final currentUserIdProvider = StateNotifierProvider<CurrentUserIdNotifier, String?>((ref) {
  return CurrentUserIdNotifier();
});

final currentUserProvider = Provider<UserProfile?>((ref) {
  final currentUserId = ref.watch(currentUserIdProvider);
  final profiles = ref.watch(userProfilesProvider);
  return profiles.firstWhere((p) => p.id == currentUserId, orElse: () => profiles.isNotEmpty ? profiles.first : null as UserProfile);
});

class UserProfileNotifier extends StateNotifier<List<UserProfile>> {
  static const String _storageKey = 'eigo_kore_profiles';

  UserProfileNotifier() : super([]) {
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      final List<dynamic> decoded = jsonDecode(jsonString);
      final profiles = decoded.map((json) => UserProfile.fromJson(json as Map<String, dynamic>)).toList();
      state = profiles;
    }
  }

  Future<void> _saveProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(state.map((p) => p.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  Future<void> addProfile(String name, int grade, String avatar) async {
    const uuid = Uuid();
    final newProfile = UserProfile(
      id: uuid.v4(),
      name: name,
      grade: grade,
      avatar: avatar,
      createdAt: DateTime.now(),
      lastAccessedAt: DateTime.now(),
    );
    state = [...state, newProfile];
    await _saveProfiles();
  }

  Future<void> deleteProfile(String profileId) async {
    state = state.where((p) => p.id != profileId).toList();
    await _saveProfiles();
  }

  Future<void> updateProfile(UserProfile updatedProfile) async {
    state = state.map((p) => p.id == updatedProfile.id ? updatedProfile : p).toList();
    await _saveProfiles();
  }

  Future<void> updateLastAccessed(String profileId) async {
    final profile = state.firstWhere((p) => p.id == profileId, orElse: () => state.first);
    final updated = profile.copyWith(lastAccessedAt: DateTime.now());
    await updateProfile(updated);
  }
}

class CurrentUserIdNotifier extends StateNotifier<String?> {
  static const String _currentUserKey = 'eigo_kore_current_user_id';

  CurrentUserIdNotifier() : super(null) {
    _loadCurrentUserId();
  }

  Future<void> _loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_currentUserKey);
    state = userId;
  }

  Future<void> setCurrentUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, userId);
    state = userId;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
    state = null;
  }
}
