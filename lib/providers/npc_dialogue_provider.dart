import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eigo/models/npc_dialogue_model.dart';
import 'package:eigo/models/npc_behavior_model.dart';
import 'package:eigo/services/npc_dialogue_service.dart';
import 'package:eigo/providers/npc_behavior_provider.dart';

final npcDialogueServiceProvider = Provider((ref) {
  return NPCDialogueService.getInstance();
});

/// 対話セッションを管理するプロバイダー
final dialogueSessionProvider =
    StateNotifierProvider.family<DialogueSessionNotifier, DialogueSession?, String>(
  (ref, sessionId) {
    final service = ref.watch(npcDialogueServiceProvider);
    return DialogueSessionNotifier(
      service: service,
      sessionId: sessionId,
    );
  },
);

/// 対話セッションの情報を取得
final currentDialogueNodeProvider =
    FutureProvider.family<DialogueNode?, (String, DialogueTree)>(
  (ref, params) async {
    final (sessionId, tree) = params;
    final service = ref.watch(npcDialogueServiceProvider);
    final session = service.getSession(sessionId);

    if (session == null) {
      return null;
    }

    return tree.getNode(session.currentNodeId);
  },
);

/// 対話オプションを取得（フィルター済み）
final availableDialogueOptionsProvider =
    FutureProvider.family<List<DialogueOption>, (DialogueNode, int, String)>(
  (ref, params) async {
    final (node, affection, npcId) = params;
    final service = ref.watch(npcDialogueServiceProvider);
    final npcState = ref.watch(npcBehaviorStateProvider(npcId));

    return node.options;
  },
);

/// 性格別の推奨対話タイプ
final recommendedDialogueTypesProvider =
    FutureProvider.family<List<DialogueType>, String>((ref, npcId) async {
  final service = ref.watch(npcDialogueServiceProvider);
  final npcState = ref.watch(npcBehaviorStateProvider(npcId));

  return service.getRecommendedDialogueTypes(npcState);
});

/// 対話セッション統計
final dialogueStatisticsProvider =
    FutureProvider.family<DialogueStatistics, String>((ref, npcId) async {
  final service = ref.watch(npcDialogueServiceProvider);

  // Mock implementation - in a real app, would fetch from database
  return DialogueStatistics(
    npcId: npcId,
    totalConversations: 0,
    uniqueTreesUsed: 0,
    totalAffectionChange: 0,
  );
});

/// 対話ノードのレンダリング（感情表現付き）
final renderedDialogueProvider =
    FutureProvider.family<String, (DialogueNode, String)>(
  (ref, params) async {
    final (node, npcId) = params;
    final service = ref.watch(npcDialogueServiceProvider);
    final npcState = ref.watch(npcBehaviorStateProvider(npcId));

    return service.renderDialogueNode(node, npcState);
  },
);

/// セッションのアフィニティ変化
final sessionAffectionChangeProvider =
    FutureProvider.family<int, String>((ref, sessionId) async {
  final service = ref.watch(npcDialogueServiceProvider);
  final session = service.getSession(sessionId);

  if (session == null) {
    return 0;
  }

  return service.getSessionAffectionChange(session);
});

/// 対話セッション Notifier
class DialogueSessionNotifier extends StateNotifier<DialogueSession?> {
  final NPCDialogueService service;
  final String sessionId;

  DialogueSessionNotifier({
    required this.service,
    required this.sessionId,
  }) : super(null);

  /// セッションを開始
  void startSession(DialogueTree tree, String npcId) {
    final session = service.startDialogue(tree, npcId);
    state = session;
  }

  /// オプションを選択
  void selectOption(
    String optionId,
    DialogueTree tree,
    int currentAffection,
    NPCBehaviorState npcState,
  ) {
    if (state == null) return;

    final updated = service.selectOption(
      state!,
      optionId,
      tree,
      currentAffection,
      npcState,
    );

    state = updated;
  }

  /// セッションを続行
  void continueSession(DialogueTree tree) {
    if (state == null) return;

    final node = service.continueDialogue(state!, tree);
    if (node != null) {
      state = state!.copyWith(
        currentNodeId: node.nodeId,
        updatedAt: DateTime.now(),
      );
    }
  }

  /// セッションを終了
  void endSession(NPCBehaviorState npcState, int initialAffection) {
    if (state == null) return;

    service.endDialogue(state!, npcState, initialAffection);
    state = state!.copyWith(
      isComplete: true,
      updatedAt: DateTime.now(),
    );
  }

  /// セッションをリセット
  void resetSession() {
    state = null;
  }
}

/// 対話フロー管理
final dialogueFlowProvider =
    StateNotifierProvider.family<DialogueFlowNotifier, DialogueFlow?, String>(
  (ref, npcId) {
    final service = ref.watch(npcDialogueServiceProvider);
    return DialogueFlowNotifier(
      service: service,
      npcId: npcId,
    );
  },
);

/// DialogueFlow Notifier
class DialogueFlowNotifier extends StateNotifier<DialogueFlow?> {
  final NPCDialogueService service;
  final String npcId;

  DialogueFlowNotifier({
    required this.service,
    required this.npcId,
  }) : super(null);

  /// フローを初期化
  void initializeFlow(
    String flowId,
    List<String> treeIds,
    String defaultTreeId,
  ) {
    final flow = service.createDialogueFlow(
      flowId,
      npcId,
      treeIds,
      defaultTreeId,
    );
    state = flow;
  }

  /// フローをアクティベート
  void activateFlow() {
    if (state == null) return;
    state = state!.copyWith(isActive: true);
  }

  /// フローをディアクティベート
  void deactivateFlow() {
    if (state == null) return;
    state = state!.copyWith(isActive: false);
  }
}

/// 複数NPCの対話統計
final multipleDialogueStatisticsProvider =
    FutureProvider.family<List<DialogueStatistics>, List<String>>(
  (ref, npcIds) async {
    final service = ref.watch(npcDialogueServiceProvider);

    return npcIds
        .map((id) => DialogueStatistics(
              npcId: id,
              totalConversations: 0,
              uniqueTreesUsed: 0,
              totalAffectionChange: 0,
            ))
        .toList();
  },
);

/// 対話ツリーキャッシュ
final dialogueTreeCacheProvider = Provider.family<DialogueTree?, String>(
  (ref, treeId) {
    final service = ref.watch(npcDialogueServiceProvider);
    return service.getTree(treeId);
  },
);
