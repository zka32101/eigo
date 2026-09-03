import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../services/user_profile_service.dart';

/// Singleton provider for UserProfileService
final userProfileServiceProvider = Provider<UserProfileService>((ref) {
  return UserProfileService();
});

/// Parameter classes for actions
class UpdateBioParams {
  final String userId;
  final String bio;

  UpdateBioParams({
    required this.userId,
    required this.bio,
  });
}

class UpdateTitleParams {
  final String userId;
  final String title;

  UpdateTitleParams({
    required this.userId,
    required this.title,
  });
}

class AddXPParams {
  final String userId;
  final int xpAmount;

  AddXPParams({
    required this.userId,
    required this.xpAmount,
  });
}

class UpdatePrivacySettingsParams {
  final String userId;
  final bool? allowFriendRequests;
  final bool? showOnlineStatus;
  final bool? allowMessages;
  final bool? showAchievements;
  final bool? showStatistics;

  UpdatePrivacySettingsParams({
    required this.userId,
    this.allowFriendRequests,
    this.showOnlineStatus,
    this.allowMessages,
    this.showAchievements,
    this.showStatistics,
  });
}

/// ==================== USER PROFILE PROVIDERS ====================

/// Get user profile by ID
final userProfileProvider = FutureProvider.family<UserProfile?, String>((ref, userId) async {
  final service = ref.watch(userProfileServiceProvider);
  return service.getUserProfile(userId);
});

/// Get user profiles by list of IDs
final userProfilesProvider = FutureProvider.family<List<UserProfile>, List<String>>((ref, userIds) async {
  final service = ref.watch(userProfileServiceProvider);
  final profiles = <UserProfile>[];

  for (final userId in userIds) {
    final profile = await service.getUserProfile(userId);
    if (profile != null) {
      profiles.add(profile);
    }
  }

  return profiles;
});

/// ==================== LEADERBOARD PROVIDERS ====================

/// Get users ranked by level
final usersByLevelProvider = FutureProvider<List<UserProfile>>((ref) async {
  final service = ref.watch(userProfileServiceProvider);
  return service.getUsersByLevel();
});

/// Get top social users (most friends/followers)
final topSocialUsersProvider = FutureProvider<List<UserProfile>>((ref) async {
  final service = ref.watch(userProfileServiceProvider);
  return service.getTopSocialUsers();
});

/// ==================== SEARCH PROVIDERS ====================

/// Search users by name
final userSearchProvider = FutureProvider.family<List<UserProfile>, String>((ref, query) async {
  if (query.isEmpty) return [];

  final service = ref.watch(userProfileServiceProvider);
  return service.searchUsers(query);
});

/// ==================== ACTION PROVIDERS ====================

/// Update bio action
final updateBioActionProvider = StateProvider<UpdateBioParams?>((ref) => null);

final updateBioProvider = FutureProvider<bool>((ref) async {
  final params = ref.watch(updateBioActionProvider);
  if (params == null) return false;

  final service = ref.watch(userProfileServiceProvider);
  final result = await service.updateBio(params.userId, params.bio);

  // Invalidate profile cache
  if (result) {
    ref.invalidate(userProfileProvider(params.userId));
  }

  return result;
});

/// Update title action
final updateTitleActionProvider = StateProvider<UpdateTitleParams?>((ref) => null);

final updateTitleProvider = FutureProvider<bool>((ref) async {
  final params = ref.watch(updateTitleActionProvider);
  if (params == null) return false;

  final service = ref.watch(userProfileServiceProvider);
  final result = await service.updateTitle(params.userId, params.title);

  // Invalidate profile cache
  if (result) {
    ref.invalidate(userProfileProvider(params.userId));
  }

  return result;
});

/// Add XP action
final addXPActionProvider = StateProvider<AddXPParams?>((ref) => null);

final addXPProvider = FutureProvider<bool>((ref) async {
  final params = ref.watch(addXPActionProvider);
  if (params == null) return false;

  final service = ref.watch(userProfileServiceProvider);
  final result = await service.addXP(params.userId, params.xpAmount);

  // Invalidate profile cache
  if (result) {
    ref.invalidate(userProfileProvider(params.userId));
    ref.invalidate(usersByLevelProvider);
  }

  return result;
});

/// Update privacy settings action
final updatePrivacySettingsActionProvider = StateProvider<UpdatePrivacySettingsParams?>((ref) => null);

final updatePrivacySettingsProvider = FutureProvider<bool>((ref) async {
  final params = ref.watch(updatePrivacySettingsActionProvider);
  if (params == null) return false;

  final service = ref.watch(userProfileServiceProvider);
  final result = await service.updatePrivacySettings(
    params.userId,
    allowFriendRequests: params.allowFriendRequests,
    showOnlineStatus: params.showOnlineStatus,
    allowMessages: params.allowMessages,
    showAchievements: params.showAchievements,
    showStatistics: params.showStatistics,
  );

  // Invalidate profile cache
  if (result) {
    ref.invalidate(userProfileProvider(params.userId));
  }

  return result;
});

/// ==================== UI STATE PROVIDERS ====================

/// User search query state
final userSearchQueryProvider = StateProvider<String>((ref) => '');

/// Selected user ID for profile view
final selectedUserIdProvider = StateProvider<String?>((ref) => null);

/// Edit mode toggle for profile
final profileEditModeProvider = StateProvider<bool>((ref) => false);
