import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eigo/models/dialogue_template_model.dart';

/// ==================== DIALOGUE CONTEXT STATE ====================

/// 現在のダイアログコンテキストを管理するStateNotifier
class DialogueContextNotifier extends StateNotifier<DialogueContext?> {
  DialogueContextNotifier() : super(null);

  /// ダイアログコンテキストを設定
  void setContext(DialogueContext context) {
    state = context;
  }

  /// ダイアログコンテキストを更新
  void updateContext({
    String? npcId,
    String? locationId,
    String? timeOfDay,
    String? currentMood,
    Map<String, dynamic>? relationshipData,
    List<DialogueMessage>? conversationHistory,
    String? weatherEffect,
    String? playerInput,
  }) {
    if (state == null) return;

    state = state!.copyWith(
      npcId: npcId ?? state!.npcId,
      locationId: locationId ?? state!.locationId,
      timeOfDay: timeOfDay ?? state!.timeOfDay,
      currentMood: currentMood ?? state!.currentMood,
      relationshipData: relationshipData ?? state!.relationshipData,
      conversationHistory: conversationHistory ?? state!.conversationHistory,
      weatherEffect: weatherEffect ?? state!.weatherEffect,
      playerInput: playerInput ?? state!.playerInput,
    );
  }

  /// 会話履歴にメッセージを追加
  void addMessageToHistory(DialogueMessage message) {
    if (state == null) return;

    final history = state!.conversationHistory ?? [];
    state = state!.copyWith(
      conversationHistory: [...history, message],
    );
  }

  /// プレイヤー入力を更新
  void setPlayerInput(String input) {
    if (state == null) return;
    state = state!.copyWith(playerInput: input);
  }

  /// コンテキストをクリア
  void clearContext() {
    state = null;
  }
}

/// 現在のダイアログコンテキストプロバイダー
final dialogueContextProvider =
    StateNotifierProvider<DialogueContextNotifier, DialogueContext?>((ref) {
  return DialogueContextNotifier();
});

/// 現在のNPC IDを取得
final currentNPCIdProvider = Provider<String?>((ref) {
  final context = ref.watch(dialogueContextProvider);
  return context?.npcId;
});

/// 現在のロケーション IDを取得
final currentLocationIdProvider = Provider<String?>((ref) {
  final context = ref.watch(dialogueContextProvider);
  return context?.locationId;
});

/// 現在の時間帯を取得
final currentTimeOfDayProvider = Provider<String?>((ref) {
  final context = ref.watch(dialogueContextProvider);
  return context?.timeOfDay;
});

/// 現在のNPC気分を取得
final currentNPCMoodProvider = Provider<String?>((ref) {
  final context = ref.watch(dialogueContextProvider);
  return context?.currentMood;
});

/// 現在の関係データを取得
final currentRelationshipDataProvider = Provider<Map<String, dynamic>?>((ref) {
  final context = ref.watch(dialogueContextProvider);
  return context?.relationshipData;
});

/// 会話履歴を取得
final conversationHistoryProvider = Provider<List<DialogueMessage>>((ref) {
  final context = ref.watch(dialogueContextProvider);
  return context?.conversationHistory ?? [];
});

/// 天気効果を取得
final weatherEffectProvider = Provider<String?>((ref) {
  final context = ref.watch(dialogueContextProvider);
  return context?.weatherEffect;
});

/// プレイヤー入力を取得
final playerInputProvider = Provider<String?>((ref) {
  final context = ref.watch(dialogueContextProvider);
  return context?.playerInput;
});

/// 会話ターン数（履歴のサイズ）
final conversationTurnCountProvider = Provider<int>((ref) {
  final history = ref.watch(conversationHistoryProvider);
  return history.length;
});

/// 最新のメッセージを取得
final latestMessageProvider = Provider<DialogueMessage?>((ref) {
  final history = ref.watch(conversationHistoryProvider);
  return history.isNotEmpty ? history.last : null;
});

/// NPC側のメッセージのみをフィルタ
final npcMessagesProvider = Provider<List<DialogueMessage>>((ref) {
  final history = ref.watch(conversationHistoryProvider);
  return history.where((msg) => msg.speaker == 'npc').toList();
});

/// プレイヤー側のメッセージのみをフィルタ
final playerMessagesProvider = Provider<List<DialogueMessage>>((ref) {
  final history = ref.watch(conversationHistoryProvider);
  return history.where((msg) => msg.speaker == 'player').toList();
});

/// 特定トピックのメッセージをフィルタ
final messagesByTopicProvider =
    Provider.family<List<DialogueMessage>, String>((ref, topic) {
  final history = ref.watch(conversationHistoryProvider);
  return history.where((msg) => msg.topic == topic).toList();
});

/// 会話の進行率（会話フェーズの完了度合い）
final conversationProgressProvider = Provider<double>((ref) {
  final turnCount = ref.watch(conversationTurnCountProvider);
  // 仮定: フルの会話は約10ターン（5往復）
  return (turnCount / 10).clamp(0.0, 1.0);
});

/// 平均メッセージ長さ（文字数）
final averageMessageLengthProvider = Provider<int>((ref) {
  final history = ref.watch(conversationHistoryProvider);
  if (history.isEmpty) return 0;
  final totalLength = history.fold<int>(0, (sum, msg) => sum + msg.text.length);
  return totalLength ~/ history.length;
});

/// 感情表現の多様性（ユニークな感情数）
final emotionalDiversityProvider = Provider<int>((ref) {
  final npcMessages = ref.watch(npcMessagesProvider);
  final emotions = <String>{};
  for (final msg in npcMessages) {
    if (msg.emotion != null) {
      emotions.add(msg.emotion!);
    }
  }
  return emotions.length;
});

/// NPCの支配的な感情
final dominantNPCEmotionProvider = Provider<String?>((ref) {
  final npcMessages = ref.watch(npcMessagesProvider);
  if (npcMessages.isEmpty) return null;

  final emotionCount = <String, int>{};
  for (final msg in npcMessages) {
    if (msg.emotion != null) {
      emotionCount[msg.emotion!] = (emotionCount[msg.emotion!] ?? 0) + 1;
    }
  }

  if (emotionCount.isEmpty) return null;
  return emotionCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
});

/// ダイアログコンテキストが存在するか
final hasActiveDialogueProvider = Provider<bool>((ref) {
  final context = ref.watch(dialogueContextProvider);
  return context != null;
});
