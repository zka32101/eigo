import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eigo/models/dialogue_template_model.dart';
import 'package:eigo/providers/npc_firebase_provider.dart';

/// ==================== DIALOGUE TEMPLATES STATE ====================

/// ダイアログテンプレートを管理するStateNotifier
class DialogueTemplatesNotifier extends StateNotifier<List<DialogueTemplate>> {
  DialogueTemplatesNotifier(this._firebaseService) : super([]) {
    _initializeTemplates();
  }

  final NPCFirebaseService _firebaseService;

  /// テンプレートを初期化
  Future<void> _initializeTemplates() async {
    try {
      // すべてのテンプレートを取得（フェッチ専用メソッドが必要な場合）
      // ここではメモリ内キャッシュのみ使用
      state = [];
    } catch (e) {
      print('Error initializing dialogue templates: $e');
      state = [];
    }
  }

  /// テンプレートを保存/更新
  Future<void> saveTemplate(DialogueTemplate template) async {
    try {
      await _firebaseService.saveDialogueTemplate(template);
      state = [
        ...state.where((t) => t.templateId != template.templateId),
        template,
      ];
    } catch (e) {
      print('Error saving dialogue template: $e');
      rethrow;
    }
  }

  /// NPCのテンプレートをロード
  Future<void> loadTemplatesByNPC(String npcId) async {
    try {
      final templates = await _firebaseService.getDialogueTemplatesByNPC(npcId);
      state = [
        ...state.where((t) => t.npcId != npcId),
        ...templates,
      ];
    } catch (e) {
      print('Error loading templates by NPC: $e');
      rethrow;
    }
  }

  /// 難易度別にテンプレートをロード
  Future<void> loadTemplatesByDifficulty(
    String npcId,
    String difficulty,
  ) async {
    try {
      final templates =
          await _firebaseService.getDialogueTemplatesByDifficulty(
        npcId,
        difficulty,
      );
      state = [
        ...state.where(
          (t) => !(t.npcId == npcId && t.difficulty == difficulty),
        ),
        ...templates,
      ];
    } catch (e) {
      print('Error loading templates by difficulty: $e');
      rethrow;
    }
  }

  /// トピック別にテンプレートをロード
  Future<void> loadTemplatesByTopic(
    String npcId,
    String topic,
  ) async {
    try {
      final templates =
          await _firebaseService.getDialogueTemplatesByTopic(
        npcId,
        topic,
      );
      state = [
        ...state.where(
          (t) => !(t.npcId == npcId && t.topic == topic),
        ),
        ...templates,
      ];
    } catch (e) {
      print('Error loading templates by topic: $e');
      rethrow;
    }
  }

  /// リロード
  Future<void> reload() async {
    await _initializeTemplates();
  }
}

/// ダイアログテンプレートプロバイダー
final dialogueTemplatesProvider =
    StateNotifierProvider<DialogueTemplatesNotifier, List<DialogueTemplate>>(
        (ref) {
  final firebaseService = ref.watch(npcFirebaseServiceProvider);
  return DialogueTemplatesNotifier(firebaseService);
});

/// IDでテンプレート詳細を取得
final dialogueTemplateByIdProvider =
    Provider.family<DialogueTemplate?, String>((ref, templateId) {
  final templates = ref.watch(dialogueTemplatesProvider);
  try {
    return templates.firstWhere((t) => t.templateId == templateId);
  } catch (e) {
    return null;
  }
});

/// 特定NPCのテンプレートを取得（キャッシュから）
final templatesByNPCProvider =
    Provider.family<List<DialogueTemplate>, String>((ref, npcId) {
  final templates = ref.watch(dialogueTemplatesProvider);
  return templates.where((t) => t.npcId == npcId).toList();
});

/// 特定NPCと難易度のテンプレートを取得（キャッシュから）
final templatesByNPCAndDifficultyProvider = Provider.family<
    List<DialogueTemplate>,
    ({String npcId, String difficulty})>((ref, params) {
  final templates = ref.watch(dialogueTemplatesProvider);
  return templates
      .where((t) => t.npcId == params.npcId && t.difficulty == params.difficulty)
      .toList();
});

/// 特定NPCとトピックのテンプレートを取得（キャッシュから）
final templatesByNPCAndTopicProvider = Provider.family<
    List<DialogueTemplate>,
    ({String npcId, String topic})>((ref, params) {
  final templates = ref.watch(dialogueTemplatesProvider);
  return templates
      .where((t) => t.npcId == params.npcId && t.topic == params.topic)
      .toList();
});

/// ストーリー関連テンプレートをフィルタリング
final storyRelatedTemplatesProvider = Provider<List<DialogueTemplate>>((ref) {
  final templates = ref.watch(dialogueTemplatesProvider);
  return templates.where((t) => t.isStoryRelated).toList();
});

/// 会話フェーズ別にテンプレートをフィルタリング
final templatesByPhaseProvider =
    Provider.family<List<DialogueTemplate>, String>((ref, phase) {
  final templates = ref.watch(dialogueTemplatesProvider);
  return templates.where((t) => t.conversationPhase == phase).toList();
});

/// 難易度別にテンプレートをフィルタリング
final templatesByDifficultyProvider =
    Provider.family<List<DialogueTemplate>, String>((ref, difficulty) {
  final templates = ref.watch(dialogueTemplatesProvider);
  return templates.where((t) => t.difficulty == difficulty).toList();
});

/// 推奨XP報酬でソートされたテンプレート
final templatesByXPRewardProvider = Provider<List<DialogueTemplate>>((ref) {
  final templates = ref.watch(dialogueTemplatesProvider);
  return templates.toList()
    ..sort((a, b) => b.recommendedXPReward.compareTo(a.recommendedXPReward));
});

/// トピック一覧（ユニーク）
final uniqueTopicsProvider = Provider<List<String>>((ref) {
  final templates = ref.watch(dialogueTemplatesProvider);
  final topics = <String>{};
  for (final template in templates) {
    topics.add(template.topic);
  }
  return topics.toList()..sort();
});
