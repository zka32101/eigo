import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eigo/models/npc_extended_model.dart';
import 'package:eigo/providers/npc_firebase_provider.dart';
import 'package:eigo/providers/user_profile_provider.dart';

/// ==================== NPC RELATIONSHIP STATE ====================

/// NPC関係を管理するStateNotifier
class NPCRelationshipsNotifier extends StateNotifier<List<NPCRelationship>> {
  NPCRelationshipsNotifier(
    this._firebaseService,
    this._userId,
  ) : super([]) {
    if (_userId != null) {
      _initializeRelationships();
    }
  }

  final NPCFirebaseService _firebaseService;
  final String? _userId;

  /// 関係データを初期化
  Future<void> _initializeRelationships() async {
    if (_userId == null) return;
    try {
      final relationships =
          await _firebaseService.getUserNPCRelationships(_userId!);
      state = relationships;
    } catch (e) {
      print('Error initializing NPC relationships: $e');
      state = [];
    }
  }

  /// NPC関係を保存/更新
  Future<void> saveRelationship(NPCRelationship relationship) async {
    if (_userId == null) return;
    try {
      await _firebaseService.saveNPCRelationship(_userId!, relationship);
      state = [
        ...state.where((r) => r.npcId != relationship.npcId),
        relationship,
      ];
    } catch (e) {
      print('Error saving NPC relationship: $e');
      rethrow;
    }
  }

  /// 親密度レベルを増加
  Future<void> increaseAffection(String npcId, int amount) async {
    if (_userId == null) return;
    try {
      final existing = state.firstWhere(
        (r) => r.npcId == npcId,
        orElse: () => NPCRelationship(
          userId: _userId!,
          npcId: npcId,
          affectionLevel: 0,
          conversationCount: 0,
          discoveredTopics: [],
          conversationHistory: {},
          currentStreak: 0,
          maxStreak: 0,
          relationshipEpisodes: [],
          earnedBadgesWithNPC: [],
        ),
      );

      final newAffection = (existing.affectionLevel + amount).clamp(0, 100);
      final updated = existing.copyWith(
        affectionLevel: newAffection,
        lastInteractionAt: DateTime.now(),
      );

      await saveRelationship(updated);
    } catch (e) {
      print('Error increasing affection: $e');
      rethrow;
    }
  }

  /// 会話数を増加
  Future<void> incrementConversationCount(String npcId) async {
    if (_userId == null) return;
    try {
      final existing = state.firstWhere(
        (r) => r.npcId == npcId,
        orElse: () => NPCRelationship(
          userId: _userId!,
          npcId: npcId,
          affectionLevel: 0,
          conversationCount: 0,
          discoveredTopics: [],
          conversationHistory: {},
          currentStreak: 0,
          maxStreak: 0,
          relationshipEpisodes: [],
          earnedBadgesWithNPC: [],
        ),
      );

      final updated = existing.copyWith(
        conversationCount: existing.conversationCount + 1,
        lastInteractionAt: DateTime.now(),
      );

      await saveRelationship(updated);
    } catch (e) {
      print('Error incrementing conversation count: $e');
      rethrow;
    }
  }

  /// トピックを発見
  Future<void> discoverTopic(String npcId, String topic) async {
    if (_userId == null) return;
    try {
      final existing = state.firstWhere(
        (r) => r.npcId == npcId,
        orElse: () => NPCRelationship(
          userId: _userId!,
          npcId: npcId,
          affectionLevel: 0,
          conversationCount: 0,
          discoveredTopics: [],
          conversationHistory: {},
          currentStreak: 0,
          maxStreak: 0,
          relationshipEpisodes: [],
          earnedBadgesWithNPC: [],
        ),
      );

      if (!existing.discoveredTopics.contains(topic)) {
        final updated = existing.copyWith(
          discoveredTopics: [...existing.discoveredTopics, topic],
        );
        await saveRelationship(updated);
      }
    } catch (e) {
      print('Error discovering topic: $e');
      rethrow;
    }
  }

  /// リロード
  Future<void> reload() async {
    await _initializeRelationships();
  }
}

/// NPC関係プロバイダー（ユーザーIDに基づく）
final npcRelationshipsProvider = StateNotifierProvider<
    NPCRelationshipsNotifier,
    List<NPCRelationship>>((ref) {
  final firebaseService = ref.watch(npcFirebaseServiceProvider);
  final userProfile = ref.watch(userProfileProvider);

  final userId = userProfile.when(
    data: (profile) => profile?['uid'] as String?,
    loading: () => null,
    error: (_, __) => null,
  );

  return NPCRelationshipsNotifier(firebaseService, userId);
});

/// 特定NPCの関係を取得
final npcRelationshipProvider =
    Provider.family<NPCRelationship?, String>((ref, npcId) {
  final relationships = ref.watch(npcRelationshipsProvider);
  try {
    return relationships.firstWhere((r) => r.npcId == npcId);
  } catch (e) {
    return null;
  }
});

/// 親密度レベル別に関係をフィルタリング
final relationshipsByAffectionProvider =
    Provider.family<List<NPCRelationship>, int>((ref, minAffection) {
  final relationships = ref.watch(npcRelationshipsProvider);
  return relationships
      .where((r) => r.affectionLevel >= minAffection)
      .toList();
});

/// 最も親密なNPC
final closestNPCProvider = Provider<NPCRelationship?>((ref) {
  final relationships = ref.watch(npcRelationshipsProvider);
  if (relationships.isEmpty) return null;
  return relationships.reduce((a, b) =>
      a.affectionLevel > b.affectionLevel ? a : b);
});

/// 最も会話したNPC
final mostConversedNPCProvider = Provider<NPCRelationship?>((ref) {
  final relationships = ref.watch(npcRelationshipsProvider);
  if (relationships.isEmpty) return null;
  return relationships.reduce((a, b) =>
      a.conversationCount > b.conversationCount ? a : b);
});

/// 最長ストリーク
final longestStreakProvider = Provider<int>((ref) {
  final relationships = ref.watch(npcRelationshipsProvider);
  if (relationships.isEmpty) return 0;
  return relationships.fold<int>(
    0,
    (max, r) => r.maxStreak > max ? r.maxStreak : max,
  );
});

/// 総関係エピソード数
final totalRelationshipEpisodesProvider = Provider<int>((ref) {
  final relationships = ref.watch(npcRelationshipsProvider);
  return relationships.fold<int>(
    0,
    (sum, r) => sum + r.relationshipEpisodes.length,
  );
});
