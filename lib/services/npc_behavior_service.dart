import 'package:eigo/models/npc_behavior_model.dart';

/// NPC行動・性格管理サービス
class NPCBehaviorService {
  static final NPCBehaviorService _instance =
      NPCBehaviorService._internal();

  factory NPCBehaviorService.getInstance() {
    return _instance;
  }

  NPCBehaviorService._internal();

  /// NPC行動状態を初期化
  NPCBehaviorState initializeBehaviorState(
    String npcId,
    PersonalityTraits traits,
  ) {
    return NPCBehaviorState(
      npcId: npcId,
      personalityTraits: traits,
      currentMood: NPCMood.neutral,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// NPCの現在の行動反応を取得
  String getReactionToPlayer(
    NPCBehaviorState behavior,
    int affectionScore,
    String context,
  ) {
    final baseReaction = behavior.generateReaction(context, affectionScore);
    final moodModifier = behavior.getAffectionModifier();

    if (affectionScore >= 75 && moodModifier > 1.0) {
      return '$baseReaction (Very positive mood!)';
    } else if (affectionScore < 25 && moodModifier < 1.0) {
      return '$baseReaction (Seems distant...)';
    }

    return baseReaction;
  }

  /// ムードを時間に基づいて更新
  NPCBehaviorState updateMoodByTime(
    NPCBehaviorState behavior,
    DateTime currentTime,
  ) {
    // 疲労：夜間
    if (currentTime.hour >= 21 || currentTime.hour < 5) {
      return behavior.copyWith(currentMood: NPCMood.tired);
    }

    // 興奮：朝
    if (currentTime.hour >= 8 && currentTime.hour < 12) {
      return behavior.copyWith(currentMood: NPCMood.excited);
    }

    // 中立：その他
    return behavior.copyWith(currentMood: NPCMood.neutral);
  }

  /// インタラクションに基づいてムードを更新
  NPCBehaviorState updateMoodByInteraction(
    NPCBehaviorState behavior,
    int interactionValue,
  ) {
    NPCMood newMood = behavior.currentMood;

    if (interactionValue > 50) {
      newMood = NPCMood.happy;
    } else if (interactionValue > 25) {
      newMood = NPCMood.excited;
    } else if (interactionValue < -50) {
      newMood = NPCMood.angry;
    } else if (interactionValue < -25) {
      newMood = NPCMood.sad;
    }

    return behavior.copyWith(currentMood: newMood);
  }

  /// 性格特性に基づいた親密度修正を計算
  int applyPersonalityModifier(
    int baseAffectionChange,
    PersonalityTraits traits,
    String interactionType,
  ) {
    double modifier = 1.0;

    // 協調性が高いと親密度変更が増加
    if (traits.agreeableness > 70 && baseAffectionChange > 0) {
      modifier *= 1.3;
    }

    // 神経症傾向が高いと親密度変更が減少
    if (traits.neuroticism > 60) {
      modifier *= 0.8;
    }

    // 外向性が高いと社交的インタラクションが有効
    if (traits.extraversion > 70 &&
        (interactionType == 'greeting' || interactionType == 'dialogue')) {
      modifier *= 1.2;
    }

    return (baseAffectionChange * modifier).toInt();
  }

  /// インタラクション履歴を追加
  NPCBehaviorState memorizeInteraction(
    NPCBehaviorState behavior,
    String type,
    String description,
    int value,
  ) {
    final interaction = MemorizedInteraction(
      interactionId: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      description: description,
      occurredAt: DateTime.now(),
      value: value,
    );

    final updated = behavior.copyWith();
    updated.memorizeInteraction(interaction);

    return updated;
  }

  /// 性格に基づいた対話選択肢を生成
  List<String> generatePersonalizedDialogueOptions(
    NPCBehaviorState behavior,
    List<String> baseOptions,
  ) {
    final personalityType = behavior.getPersonalityType();
    final options = <String>[...baseOptions];

    // 性格に基づいたオプション追加
    switch (personalityType) {
      case PersonalityType.cheerful:
        options.add('😊 Tell them something funny');
        break;
      case PersonalityType.kind:
        options.add('💝 Compliment their kindness');
        break;
      case PersonalityType.ambitious:
        options.add('🎯 Ask about their goals');
        break;
      case PersonalityType.timid:
        options.add('🤗 Be gentle and encouraging');
        break;
      case PersonalityType.sarcastic:
        options.add('😏 Use witty humor');
        break;
      case PersonalityType.calm:
        options.add('🧘 Have a peaceful conversation');
        break;
    }

    return options;
  }

  /// 性格マッチスコアを計算（0-100）
  int calculatePersonalityMatch(
    PersonalityTraits npcTraits,
    PersonalityTraits playerTraits,
  ) {
    int match = 50; // ベーススコア

    // 協調性が共に高いと相性が良い
    if (npcTraits.agreeableness > 60 && playerTraits.agreeableness > 60) {
      match += 20;
    }

    // 外向性が一致すると相性が良い
    final extraversionDiff =
        (npcTraits.extraversion - playerTraits.extraversion).abs();
    if (extraversionDiff < 30) {
      match += 15;
    }

    // 開放性が一致すると相性が良い
    final opennessDiff = (npcTraits.openness - playerTraits.openness).abs();
    if (opennessDiff < 30) {
      match += 10;
    }

    return match.clamp(0, 100);
  }

  /// 習慣を実行
  NPCBehaviorState executHabit(
    NPCBehaviorState behavior,
    String habitId,
  ) {
    final updated = behavior.copyWith();

    for (int i = 0; i < behavior.habits.length; i++) {
      if (behavior.habits[i].habitId == habitId) {
        final habit = behavior.habits[i];
        final updatedHabits = [...behavior.habits];
        updatedHabits[i] = Habit(
          habitId: habit.habitId,
          name: habit.name,
          description: habit.description,
          frequency: habit.frequency,
          lastExecutedAt: DateTime.now(),
          executionCount: habit.executionCount + 1,
        );
        return updated.copyWith(habits: updatedHabits);
      }
    }

    return updated;
  }

  /// 行動パターンを実行
  NPCBehaviorState executeBehaviorPattern(
    NPCBehaviorState behavior,
    BehaviorPattern pattern,
  ) {
    final executedBehavior = ExecutedBehavior(
      behaviorId: pattern.patternId,
      behaviorName: pattern.name,
      executedAt: DateTime.now(),
      result: pattern.reaction,
    );

    final updated = behavior.copyWith();
    updated.executeBehavior(executedBehavior);

    return updated;
  }

  /// 最近のインタラクション数を取得
  int getRecentInteractionCount(
    NPCBehaviorState behavior,
    Duration period,
  ) {
    final threshold = DateTime.now().subtract(period);
    return behavior.memorizedInteractions
        .where((i) => i.occurredAt.isAfter(threshold))
        .length;
  }

  /// 前回のインタラクション以来の経過時間を取得
  Duration? getTimeSinceLastInteraction(NPCBehaviorState behavior) {
    if (behavior.memorizedInteractions.isEmpty) {
      return null;
    }

    final lastInteraction = behavior.memorizedInteractions.last;
    return DateTime.now().difference(lastInteraction.occurredAt);
  }

  /// NPCが望む話題かどうかを確認
  bool isPreferredTopic(
    NPCBehaviorState behavior,
    String topic,
  ) {
    if (behavior.preferredTopics.contains(topic)) {
      return true;
    }
    return false;
  }

  /// NPCが避ける話題かどうかを確認
  bool isDislikedTopic(
    NPCBehaviorState behavior,
    String topic,
  ) {
    if (behavior.dislikedTopics.contains(topic)) {
      return true;
    }
    return false;
  }

  /// 話題に基づいた親密度修正を計算
  int getTopicModifier(
    NPCBehaviorState behavior,
    String topic,
  ) {
    if (isPreferredTopic(behavior, topic)) {
      return 5; // ボーナス
    }
    if (isDislikedTopic(behavior, topic)) {
      return -5; // ペナルティ
    }
    return 0;
  }

  /// 行動の要約を生成
  BehaviorSummary generateBehaviorSummary(NPCBehaviorState behavior) {
    final personality = behavior.getPersonalityType();
    final recentInteractions = getRecentInteractionCount(
      behavior,
      const Duration(days: 7),
    );
    final timeSinceLast = getTimeSinceLastInteraction(behavior);

    return BehaviorSummary(
      npcId: behavior.npcId,
      personality: personality,
      currentMood: behavior.currentMood,
      recentInteractionCount: recentInteractions,
      timeSinceLastInteraction: timeSinceLast,
      memorizedInteractionCount: behavior.memorizedInteractions.length,
      executedBehaviorCount: behavior.executedBehaviors.length,
      habitCount: behavior.habits.length,
    );
  }

  /// 行動状態をリセット
  NPCBehaviorState resetBehavior(NPCBehaviorState behavior) {
    return NPCBehaviorState(
      npcId: behavior.npcId,
      personalityTraits: behavior.personalityTraits,
      currentMood: NPCMood.neutral,
      createdAt: behavior.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

/// 行動要約
class BehaviorSummary {
  final String npcId;
  final PersonalityType personality;
  final NPCMood currentMood;
  final int recentInteractionCount;
  final Duration? timeSinceLastInteraction;
  final int memorizedInteractionCount;
  final int executedBehaviorCount;
  final int habitCount;

  BehaviorSummary({
    required this.npcId,
    required this.personality,
    required this.currentMood,
    required this.recentInteractionCount,
    this.timeSinceLastInteraction,
    required this.memorizedInteractionCount,
    required this.executedBehaviorCount,
    required this.habitCount,
  });

  /// 性格の説明を取得
  String getPersonalityDescription() {
    switch (personality) {
      case PersonalityType.cheerful:
        return 'Very cheerful and outgoing personality';
      case PersonalityType.calm:
        return 'Calm and composed personality';
      case PersonalityType.timid:
        return 'Shy and timid personality';
      case PersonalityType.ambitious:
        return 'Ambitious and driven personality';
      case PersonalityType.kind:
        return 'Warm and kind personality';
      case PersonalityType.sarcastic:
        return 'Witty and sarcastic personality';
    }
  }

  /// ムードの説明を取得
  String getMoodDescription() {
    switch (currentMood) {
      case NPCMood.happy:
        return 'Feeling very happy';
      case NPCMood.neutral:
        return 'Feeling neutral';
      case NPCMood.sad:
        return 'Seems a bit sad';
      case NPCMood.angry:
        return 'Appears angry';
      case NPCMood.excited:
        return 'Very excited';
      case NPCMood.tired:
        return 'Looking tired';
    }
  }
}
