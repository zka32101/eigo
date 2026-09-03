import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eigo/models/interaction_history_model.dart';
import 'package:eigo/providers/npc_firebase_provider.dart';
import 'package:eigo/providers/user_profile_provider.dart';

/// ==================== CONVERSATION SESSIONS STATE ====================

/// 会話セッションを管理するStateNotifier
class ConversationSessionsNotifier extends StateNotifier<List<ConversationSession>> {
  ConversationSessionsNotifier(
    this._firebaseService,
    this._userId,
  ) : super([]) {
    if (_userId != null) {
      _initializeSessions();
    }
  }

  final NPCFirebaseService _firebaseService;
  final String? _userId;

  /// セッションを初期化
  Future<void> _initializeSessions() async {
    if (_userId == null) return;
    try {
      final sessions =
          await _firebaseService.getUserConversationSessions(_userId!);
      state = sessions;
    } catch (e) {
      print('Error initializing conversation sessions: $e');
      state = [];
    }
  }

  /// セッションを保存
  Future<void> saveSession(ConversationSession session) async {
    if (_userId == null) return;
    try {
      await _firebaseService.saveConversationSession(_userId!, session);
      state = [
        ...state.where((s) => s.sessionId != session.sessionId),
        session,
      ];
    } catch (e) {
      print('Error saving conversation session: $e');
      rethrow;
    }
  }

  /// セッションを作成
  Future<ConversationSession> createSession({
    required String sessionId,
    required String npcId,
    required String sessionTheme,
  }) async {
    if (_userId == null) throw Exception('User ID is required');
    try {
      final session = ConversationSession(
        sessionId: sessionId,
        userId: _userId!,
        npcId: npcId,
        startedAt: DateTime.now(),
        turnCount: 0,
        averageScore: 0.0,
        totalXPEarned: 0,
        totalCoinsEarned: 0,
        discoveredTopics: [],
        relationshipChange: 0,
        sessionTheme: sessionTheme,
      );

      await saveSession(session);
      return session;
    } catch (e) {
      print('Error creating session: $e');
      rethrow;
    }
  }

  /// セッションをアップデート（ターン数、スコア等）
  Future<void> updateSession(
    String sessionId, {
    int? turnCount,
    double? averageScore,
    int? totalXPEarned,
    int? totalCoinsEarned,
    List<String>? discoveredTopics,
    int? relationshipChange,
  }) async {
    if (_userId == null) return;
    try {
      final session =
          state.firstWhere((s) => s.sessionId == sessionId);

      final updated = session.copyWith(
        turnCount: turnCount ?? session.turnCount,
        averageScore: averageScore ?? session.averageScore,
        totalXPEarned: totalXPEarned ?? session.totalXPEarned,
        totalCoinsEarned: totalCoinsEarned ?? session.totalCoinsEarned,
        discoveredTopics: discoveredTopics ?? session.discoveredTopics,
        relationshipChange: relationshipChange ?? session.relationshipChange,
      );

      await saveSession(updated);
    } catch (e) {
      print('Error updating session: $e');
      rethrow;
    }
  }

  /// セッションを終了
  Future<void> endSession(String sessionId) async {
    if (_userId == null) return;
    try {
      final session =
          state.firstWhere((s) => s.sessionId == sessionId);

      final updated = session.copyWith(
        endedAt: DateTime.now(),
      );

      await saveSession(updated);
    } catch (e) {
      print('Error ending session: $e');
      rethrow;
    }
  }

  /// NPCのセッションをロード
  Future<void> loadSessionsByNPC(String npcId) async {
    if (_userId == null) return;
    try {
      final sessions =
          await _firebaseService.getConversationSessionsByNPC(
        _userId!,
        npcId,
      );
      state = [
        ...state.where((s) => s.npcId != npcId),
        ...sessions,
      ];
    } catch (e) {
      print('Error loading sessions by NPC: $e');
      rethrow;
    }
  }

  /// リロード
  Future<void> reload() async {
    await _initializeSessions();
  }
}

/// 会話セッションプロバイダー（ユーザーIDに基づく）
final conversationSessionsProvider =
    StateNotifierProvider<ConversationSessionsNotifier, List<ConversationSession>>(
        (ref) {
  final firebaseService = ref.watch(npcFirebaseServiceProvider);
  final userProfile = ref.watch(userProfileProvider);

  final userId = userProfile.when(
    data: (profile) => profile?['uid'] as String?,
    loading: () => null,
    error: (_, __) => null,
  );

  return ConversationSessionsNotifier(firebaseService, userId);
});

/// IDでセッション詳細を取得
final sessionByIdProvider =
    Provider.family<ConversationSession?, String>((ref, sessionId) {
  final sessions = ref.watch(conversationSessionsProvider);
  try {
    return sessions.firstWhere((s) => s.sessionId == sessionId);
  } catch (e) {
    return null;
  }
});

/// 特定NPCのセッションを取得
final sessionsByNPCProvider =
    Provider.family<List<ConversationSession>, String>((ref, npcId) {
  final sessions = ref.watch(conversationSessionsProvider);
  return sessions.where((s) => s.npcId == npcId).toList();
});

/// アクティブなセッション（終了していない）
final activeSessions = Provider<List<ConversationSession>>((ref) {
  final sessions = ref.watch(conversationSessionsProvider);
  return sessions.where((s) => s.endedAt == null).toList();
});

/// 完了したセッション（終了している）
final completedSessions = Provider<List<ConversationSession>>((ref) {
  final sessions = ref.watch(conversationSessionsProvider);
  return sessions.where((s) => s.endedAt != null).toList();
});

/// テーマ別セッション
final sessionsByThemeProvider =
    Provider.family<List<ConversationSession>, String>((ref, theme) {
  final sessions = ref.watch(conversationSessionsProvider);
  return sessions.where((s) => s.sessionTheme == theme).toList();
});

/// 平均セッション期間（分）
final averageSessionDurationProvider = Provider<int>((ref) {
  final sessions = ref.watch(conversationSessionsProvider);
  if (sessions.isEmpty) return 0;
  final totalDuration =
      sessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
  return totalDuration ~/ sessions.length;
});

/// 最長セッション
final longestSessionProvider = Provider<ConversationSession?>((ref) {
  final sessions = ref.watch(conversationSessionsProvider);
  if (sessions.isEmpty) return null;
  return sessions.reduce((a, b) =>
      a.durationMinutes > b.durationMinutes ? a : b);
});

/// 平均スコア（全セッション）
final averageScoreAcrossSessionsProvider = Provider<double>((ref) {
  final sessions = ref.watch(conversationSessionsProvider);
  if (sessions.isEmpty) return 0.0;
  final sum = sessions.fold<double>(0, (sum, s) => sum + s.averageScore);
  return sum / sessions.length;
});

/// 総セッション数
final totalSessionsProvider = Provider<int>((ref) {
  return ref.watch(conversationSessionsProvider).length;
});

/// 総セッションXP獲得
final totalSessionXPProvider = Provider<int>((ref) {
  final sessions = ref.watch(conversationSessionsProvider);
  return sessions.fold<int>(0, (sum, s) => sum + s.totalXPEarned);
});

/// 総セッションコイン獲得
final totalSessionCoinsProvider = Provider<int>((ref) {
  final sessions = ref.watch(conversationSessionsProvider);
  return sessions.fold<int>(0, (sum, s) => sum + s.totalCoinsEarned);
});

/// セッション別平均ターン数
final averageTurnsPerSessionProvider = Provider<double>((ref) {
  final sessions = ref.watch(conversationSessionsProvider);
  if (sessions.isEmpty) return 0.0;
  final totalTurns = sessions.fold<int>(0, (sum, s) => sum + s.turnCount);
  return totalTurns / sessions.length;
});

/// 最近のセッション（直近10個）
final recentSessionsProvider = Provider<List<ConversationSession>>((ref) {
  final sessions = ref.watch(conversationSessionsProvider);
  return sessions.take(10).toList();
});
