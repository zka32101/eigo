import 'package:eigo/models/npc_extended_model.dart';
import 'package:eigo/models/dialogue_template_model.dart';
import 'package:eigo/models/npc_location_model.dart';
import 'package:eigo/services/dialogue_engine_service.dart';

/// タウンマップNPCダイアログ統合サービス
class TownNPCDialogueIntegrationService {
  static final TownNPCDialogueIntegrationService _instance =
      TownNPCDialogueIntegrationService._internal();

  final DialogueEngineService _dialogueEngine =
      DialogueEngineService.getInstance();

  factory TownNPCDialogueIntegrationService.getInstance() {
    return _instance;
  }

  TownNPCDialogueIntegrationService._internal();

  /// NPCの位置情報からダイアログテンプレートを取得
  Future<DialogueTemplate?> getDialogueTemplateForNPC(
    NPCLocation npcLocation,
    NPCExtended npcExtended,
    List<DialogueTemplate> availableTemplates,
  ) async {
    try {
      // NPCの職業またはエリアに基づいてテンプレートをフィルタリング
      final relevantTemplates = availableTemplates
          .where((template) =>
              template.npcId == npcExtended.npcId ||
              template.topic.toLowerCase().contains(npcLocation.profession.toLowerCase()))
          .toList();

      if (relevantTemplates.isEmpty) {
        return availableTemplates.isNotEmpty ? availableTemplates.first : null;
      }

      // 難易度に基づいてベストテンプレートを選択
      return _dialogueEngine.selectBestTemplate(
        templates: relevantTemplates,
        npc: npcExtended,
        userInput: 'Hello ${npcLocation.name}',
        currentPhase: ConversationPhase.greeting,
        preferredDifficulty: _getPreferredDifficulty(npcExtended),
      );
    } catch (e) {
      print('Error getting dialogue template for NPC: $e');
      return null;
    }
  }

  /// NPCとの相互作用コンテキストを作成
  NPCDialogueContext createDialogueContext(
    NPCLocation npcLocation,
    NPCExtended npcExtended,
    String userInput,
  ) {
    return NPCDialogueContext(
      npcLocation: npcLocation,
      npcExtended: npcExtended,
      initialUserInput: userInput,
      startedAt: DateTime.now(),
      interactionType: 'map_interaction',
    );
  }

  /// ダイアログ後のNPC状態更新
  NPCLocation updateNPCAfterDialogue(
    NPCLocation npc,
    DialogueInteractionResult result,
  ) {
    String newState = 'idle';
    if (result.score >= 80) {
      newState = 'happy';
    } else if (result.score < 50) {
      newState = 'neutral';
    }

    return npc.copyWith(
      currentState: newState,
      lastUpdatedAt: DateTime.now(),
    );
  }

  /// ダイアログ前のNPC状態設定
  NPCLocation prepareNPCForDialogue(NPCLocation npc) {
    return npc.copyWith(
      currentState: 'talking',
      lastUpdatedAt: DateTime.now(),
    );
  }

  /// 複数のNPCがいる場合、最適なNPCを選択
  NPCLocation? selectBestNPCForInteraction(
    List<NPCLocation> availableNPCs,
    String playerPreference,
  ) {
    if (availableNPCs.isEmpty) return null;
    if (availableNPCs.length == 1) return availableNPCs.first;

    // プレイヤーの好みに基づいてNPCを選択
    for (final npc in availableNPCs) {
      if (npc.name.toLowerCase().contains(playerPreference.toLowerCase()) ||
          npc.profession
              .toLowerCase()
              .contains(playerPreference.toLowerCase())) {
        return npc;
      }
    }

    // 好みに合うNPCがない場合は最初のNPCを返す
    return availableNPCs.first;
  }

  /// 推奨される難易度を取得
  DialogueDifficulty _getPreferredDifficulty(NPCExtended npc) {
    if (npc.learningProgress < 0.3) {
      return DialogueDifficulty.easy;
    } else if (npc.learningProgress < 0.6) {
      return DialogueDifficulty.intermediate;
    } else if (npc.learningProgress < 0.8) {
      return DialogueDifficulty.advanced;
    } else {
      return DialogueDifficulty.expert;
    }
  }

  /// NPC相互作用の履歴を記録
  NPCInteractionHistory recordInteraction(
    NPCLocation npcLocation,
    DialogueInteractionResult result,
  ) {
    return NPCInteractionHistory(
      npcId: npcLocation.npcId,
      npcName: npcLocation.name,
      interactionType: 'dialogue',
      score: result.score,
      xpEarned: result.xpEarned,
      coinsEarned: result.coinsEarned,
      timestamp: DateTime.now(),
      qualityBreakdown: result.qualityBreakdown,
    );
  }
}

/// NPCダイアログコンテキスト
class NPCDialogueContext {
  /// NPC位置情報
  final NPCLocation npcLocation;

  /// NPC拡張情報
  final NPCExtended npcExtended;

  /// 初期ユーザー入力
  final String initialUserInput;

  /// ダイアログ開始時刻
  final DateTime startedAt;

  /// 相互作用タイプ（map_interaction, quick_action等）
  final String interactionType;

  /// 会話ターン数
  int turnCount = 0;

  /// 現在のスコア
  int currentScore = 0;

  NPCDialogueContext({
    required this.npcLocation,
    required this.npcExtended,
    required this.initialUserInput,
    required this.startedAt,
    required this.interactionType,
  });

  /// 経過時間を取得
  Duration get elapsedTime => DateTime.now().difference(startedAt);

  /// コンテキストをコピー
  NPCDialogueContext copyWith({
    NPCLocation? npcLocation,
    NPCExtended? npcExtended,
    String? initialUserInput,
    DateTime? startedAt,
    String? interactionType,
    int? turnCount,
    int? currentScore,
  }) {
    return NPCDialogueContext(
      npcLocation: npcLocation ?? this.npcLocation,
      npcExtended: npcExtended ?? this.npcExtended,
      initialUserInput: initialUserInput ?? this.initialUserInput,
      startedAt: startedAt ?? this.startedAt,
      interactionType: interactionType ?? this.interactionType,
    )
      ..turnCount = turnCount ?? this.turnCount
      ..currentScore = currentScore ?? this.currentScore;
  }
}

/// ダイアログ相互作用結果
class DialogueInteractionResult {
  /// スコア（0-100）
  final int score;

  /// XP獲得量
  final int xpEarned;

  /// コイン獲得量
  final int coinsEarned;

  /// フィードバック
  final String feedback;

  /// 品質評価
  final Map<String, double> qualityBreakdown;

  /// ユーザー応答
  final String userResponse;

  /// NPCのレスポンス
  final String npcResponse;

  /// 相互作用に成功したか
  final bool success;

  DialogueInteractionResult({
    required this.score,
    required this.xpEarned,
    required this.coinsEarned,
    required this.feedback,
    required this.qualityBreakdown,
    required this.userResponse,
    required this.npcResponse,
    required this.success,
  });
}

/// NPC相互作用履歴
class NPCInteractionHistory {
  /// NPC ID
  final String npcId;

  /// NPC名
  final String npcName;

  /// 相互作用タイプ
  final String interactionType;

  /// スコア
  final int score;

  /// XP獲得量
  final int xpEarned;

  /// コイン獲得量
  final int coinsEarned;

  /// タイムスタンプ
  final DateTime timestamp;

  /// 品質評価
  final Map<String, double> qualityBreakdown;

  NPCInteractionHistory({
    required this.npcId,
    required this.npcName,
    required this.interactionType,
    required this.score,
    required this.xpEarned,
    required this.coinsEarned,
    required this.timestamp,
    required this.qualityBreakdown,
  });
}
