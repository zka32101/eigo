import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/user_profile.dart';

final userProfilesProvider = StateNotifierProvider<UserProfileNotifier, List<UserProfile>>((ref) {
  return UserProfileNotifier(ref);
});

final currentUserIdProvider = StateNotifierProvider<CurrentUserIdNotifier, String?>((ref) {
  return CurrentUserIdNotifier(ref);
});

/// 起動時、SharedPreferencesからのプロフィール一覧・現在ユーザーIDの読み込みが
/// 両方完了したかどうか。完了前にプロフィール選択画面を出してしまうと、
/// 既存プロフィールがあっても毎回プロフィール選択画面が表示されてしまうため、
/// 起動フローで参照する。
final profileLoadCompleteProvider = StateProvider<bool>((ref) => false);

/// UserProfileNotifier / CurrentUserIdNotifier 両方のSharedPreferences読み込みが
/// 完了した時点で profileLoadCompleteProvider を true にする。
void _markLoadedIfReady(Ref ref) {
  final profilesLoaded = ref.read(userProfilesProvider.notifier)._loaded;
  final currentUserLoaded = ref.read(currentUserIdProvider.notifier)._loaded;
  if (profilesLoaded && currentUserLoaded) {
    ref.read(profileLoadCompleteProvider.notifier).state = true;
  }
}

final currentUserProvider = Provider<UserProfile?>((ref) {
  final currentUserId = ref.watch(currentUserIdProvider);
  final profiles = ref.watch(userProfilesProvider);
  if (profiles.isEmpty) return null;
  for (final p in profiles) {
    if (p.id == currentUserId) return p;
  }
  return profiles.first;
});

class UserProfileNotifier extends StateNotifier<List<UserProfile>> {
  static const String _storageKey = 'eigo_kore_profiles';
  final Ref _ref;
  bool _loaded = false;

  UserProfileNotifier(this._ref) : super([]) {
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
    _loaded = true;
    _markLoadedIfReady(_ref);
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
  final Ref _ref;
  bool _loaded = false;

  CurrentUserIdNotifier(this._ref) : super(null) {
    _loadCurrentUserId();
  }

  Future<void> _loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_currentUserKey);
    state = userId;
    _loaded = true;
    _markLoadedIfReady(_ref);
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
