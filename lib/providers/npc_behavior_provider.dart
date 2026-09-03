import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eigo/models/npc_behavior_model.dart';
import 'package:eigo/services/npc_behavior_service.dart';

final npcBehaviorServiceProvider = Provider((ref) {
  return NPCBehaviorService.getInstance();
});

/// NPCの行動状態を管理するプロバイダー（NPC ID単位）
final npcBehaviorStateProvider =
    StateNotifierProvider.family<NPCBehaviorNotifier, NPCBehaviorState, String>(
  (ref, npcId) {
    final service = ref.watch(npcBehaviorServiceProvider);
    return NPCBehaviorNotifier(
      service: service,
      npcId: npcId,
    );
  },
);

/// NPCの行動状態をシンプルに取得
final npcBehaviorProvider =
    FutureProvider.family<NPCBehaviorState, String>((ref, npcId) async {
  final state = ref.watch(npcBehaviorStateProvider(npcId));
  return state;
});

/// 複数NPCの行動状態を取得
final multipleNPCBehaviorProvider =
    FutureProvider.family<List<NPCBehaviorState>, List<String>>(
  (ref, npcIds) async {
    final states = <NPCBehaviorState>[];
    for (final id in npcIds) {
      final state = ref.watch(npcBehaviorStateProvider(id));
      states.add(state);
    }
    return states;
  },
);

/// NPCの性格要約を取得
final npcPersonalityProvider =
    FutureProvider.family<PersonalityType, String>((ref, npcId) async {
  final state = ref.watch(npcBehaviorStateProvider(npcId));
  return state.getPersonalityType();
});

/// NPCの現在のムードを取得
final npcMoodProvider = FutureProvider.family<NPCMood, String>((ref, npcId) async {
  final state = ref.watch(npcBehaviorStateProvider(npcId));
  return state.currentMood;
});

/// NPCに対するプレイヤーの親密度修正を計算
final affectionModifierProvider = FutureProvider.family<double, String>(
  (ref, npcId) async {
    final state = ref.watch(npcBehaviorStateProvider(npcId));
    return state.getAffectionModifier();
  },
);

/// NPC行動の要約を取得
final behaviorSummaryProvider =
    FutureProvider.family<BehaviorSummary, String>((ref, npcId) async {
  final service = ref.watch(npcBehaviorServiceProvider);
  final state = ref.watch(npcBehaviorStateProvider(npcId));
  return service.generateBehaviorSummary(state);
});

/// 性格マッチスコアを計算
final personalityMatchProvider = FutureProvider.family<int, (String, PersonalityTraits)>(
  (ref, params) async {
    final (npcId, playerTraits) = params;
    final service = ref.watch(npcBehaviorServiceProvider);
    final state = ref.watch(npcBehaviorStateProvider(npcId));
    return service.calculatePersonalityMatch(
      state.personalityTraits,
      playerTraits,
    );
  },
);

/// 性格別の対話オプションを取得
final personalizedDialogueProvider = FutureProvider.family<List<String>, (String, List<String>)>(
  (ref, params) async {
    final (npcId, baseOptions) = params;
    final service = ref.watch(npcBehaviorServiceProvider);
    final state = ref.watch(npcBehaviorStateProvider(npcId));
    return service.generatePersonalizedDialogueOptions(state, baseOptions);
  },
);

/// 前回のインタラクション以来の経過時間を取得
final timeSinceLastInteractionProvider =
    FutureProvider.family<Duration?, String>((ref, npcId) async {
  final service = ref.watch(npcBehaviorServiceProvider);
  final state = ref.watch(npcBehaviorStateProvider(npcId));
  return service.getTimeSinceLastInteraction(state);
});

/// 最近のインタラクション数を取得
final recentInteractionCountProvider = FutureProvider.family<int, (String, Duration)>(
  (ref, params) async {
    final (npcId, period) = params;
    final service = ref.watch(npcBehaviorServiceProvider);
    final state = ref.watch(npcBehaviorStateProvider(npcId));
    return service.getRecentInteractionCount(state, period);
  },
);

/// 話題が好みかどうかを確認
final isPreferredTopicProvider = FutureProvider.family<bool, (String, String)>(
  (ref, params) async {
    final (npcId, topic) = params;
    final service = ref.watch(npcBehaviorServiceProvider);
    final state = ref.watch(npcBehaviorStateProvider(npcId));
    return service.isPreferredTopic(state, topic);
  },
);

/// 話題が嫌いかどうかを確認
final isDislikedTopicProvider = FutureProvider.family<bool, (String, String)>(
  (ref, params) async {
    final (npcId, topic) = params;
    final service = ref.watch(npcBehaviorServiceProvider);
    final state = ref.watch(npcBehaviorStateProvider(npcId));
    return service.isDislikedTopic(state, topic);
  },
);

/// 話題に基づいた親密度修正を取得
final topicModifierProvider = FutureProvider.family<int, (String, String)>(
  (ref, params) async {
    final (npcId, topic) = params;
    final service = ref.watch(npcBehaviorServiceProvider);
    final state = ref.watch(npcBehaviorStateProvider(npcId));
    return service.getTopicModifier(state, topic);
  },
);

/// NPCの反応を生成
final npcReactionProvider = FutureProvider.family<String, (String, int, String)>(
  (ref, params) async {
    final (npcId, affectionScore, context) = params;
    final service = ref.watch(npcBehaviorServiceProvider);
    final state = ref.watch(npcBehaviorStateProvider(npcId));
    return service.getReactionToPlayer(state, affectionScore, context);
  },
);

/// NPCの行動状態を管理するNotifier
class NPCBehaviorNotifier extends StateNotifier<NPCBehaviorState> {
  final NPCBehaviorService service;
  final String npcId;

  NPCBehaviorNotifier({
    required this.service,
    required this.npcId,
  }) : super(NPCBehaviorState(
    npcId: npcId,
    personalityTraits: PersonalityTraits(
      openness: 50,
      conscientiousness: 50,
      extraversion: 50,
      agreeableness: 50,
      neuroticism: 50,
    ),
    currentMood: NPCMood.neutral,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ));

  /// 性格特性を設定
  void setPersonalityTraits(PersonalityTraits traits) {
    state = state.copyWith(personalityTraits: traits);
  }

  /// ムードを変更
  void changeMood(NPCMood mood) {
    state = service.updateMoodByInteraction(state, 0);
    state = state.copyWith(currentMood: mood);
  }

  /// 時刻に基づいてムードを更新
  void updateMoodByTime(DateTime time) {
    state = service.updateMoodByTime(state, time);
  }

  /// インタラクションに基づいてムードを更新
  void updateMoodByInteraction(int value) {
    state = service.updateMoodByInteraction(state, value);
  }

  /// インタラクションを記憶
  void recordInteraction(String type, String description, int value) {
    state = service.memorizeInteraction(state, type, description, value);
  }

  /// 習慣を実行
  void executeHabit(String habitId) {
    state = service.executHabit(state, habitId);
  }

  /// 行動パターンを実行
  void executeBehaviorPattern(BehaviorPattern pattern) {
    state = service.executeBehaviorPattern(state, pattern);
  }

  /// 行動状態をリセット
  void reset() {
    state = service.resetBehavior(state);
  }

  /// 好みのトピックを追加
  void addPreferredTopic(String topic) {
    final updated = [...state.preferredTopics, topic];
    state = state.copyWith(preferredTopics: updated);
  }

  /// 嫌いなトピックを追加
  void addDislikedTopic(String topic) {
    final updated = [...state.dislikedTopics, topic];
    state = state.copyWith(dislikedTopics: updated);
  }

  /// 習慣を追加
  void addHabit(Habit habit) {
    final updated = [...state.habits, habit];
    state = state.copyWith(habits: updated);
  }
}
