import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart' show matchmakingHandlersProvider, matchHandlersProvider;

import '../services/eigo_matchmaking_service.dart';
import 'profile_provider.dart';

final List<Override> eigoMultiplayerProviderOverrides = [
  matchmakingHandlersProvider.overrideWithValue(EigoMatchmakingService.matchmakingHandlers),
  matchHandlersProvider.overrideWithValue(EigoMatchmakingService.matchHandlers),
];

/// マルチプレイで使う自分の userId / displayName。
///
/// 既存のマルチプレイ以外の機能と同じく
/// `profileProvider` の現在のプロフィール（[UserProfile.id] / [UserProfile.name]）を
/// そのまま使う。プロフィール未選択時は null。
class EigoPlayerIdentity {
  final String userId;
  final String displayName;
  final int grade;

  const EigoPlayerIdentity({
    required this.userId,
    required this.displayName,
    required this.grade,
  });
}

final eigoPlayerIdentityProvider = Provider<EigoPlayerIdentity?>((ref) {
  final profile = ref.watch(profileProvider).currentProfile;
  if (profile == null) return null;
  return EigoPlayerIdentity(
    userId: profile.id,
    displayName: profile.name,
    grade: profile.grade,
  );
});
