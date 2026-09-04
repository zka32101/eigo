import 'package:eigo/models/npc_dialogue_model.dart';
import 'package:eigo/models/npc_behavior_model.dart';
import 'package:eigo/services/npc_behavior_service.dart';

/// NPC 対話管理サービス
class NPCDialogueService {
  static final NPCDialogueService _instance =
      NPCDialogueService._internal();

  factory NPCDialogueService.getInstance() {
    return _instance;
  }

  NPCDialogueService._internal();

  final NPCBehaviorService _behaviorService = NPCBehaviorService.getInstance();

  // 対話ツリーキャッシュ
  final Map<String, DialogueTree> _treeCache = {};

  // 対話セッションキャッシュ
  final Map<String, DialogueSession> _sessionCache = {};

  /// 対話セッションを開始
  DialogueSession startDialogue(
    DialogueTree tree,
    String npcId,
  ) {
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    final rootNode = tree.getRootNode();

    if (rootNode == null) {
      throw Exception('Root node not found for tree ${tree.treeId}');
    }

    final session = DialogueSession(
      sessionId: sessionId,
      treeId: tree.treeId,
      npcId: npcId,
      currentNodeId: rootNode.nodeId,
      startedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _sessionCache[sessionId] = session;
    return session;
  }

  /// 条件をチェック
  bool checkCondition(
    DialogueCondition? condition,
    int currentAffection,
    NPCBehaviorState npcState,
  ) {
    if (condition == null) {
      return true;
    }

    // 親密度チェック
    if (condition.minAffection != null &&
        currentAffection < condition.minAffection!) {
      return false;
    }
    if (condition.maxAffection != null &&
        currentAffection > condition.maxAffection!) {
      return false;
    }

    // ムードチェック
    if (condition.requiredMoods != null &&
        !condition.requiredMoods!.contains(npcState.currentMood)) {
      return false;
    }

    // 性格タイプチェック
    if (condition.requiredPersonalities != null) {
      final currentPersonality = npcState.getPersonalityType();
      if (!condition.requiredPersonalities!.contains(currentPersonality)) {
        return false;
      }
    }

    // 性格特性チェック
    if (condition.minOpenness != null &&
        npcState.personalityTraits.openness < condition.minOpenness!) {
      return false;
    }
    if (condition.minAgreeableness != null &&
        npcState.personalityTraits.agreeableness < condition.minAgreeableness!) {
      return false;
    }
    if (condition.minExtraversion != null &&
        npcState.personalityTraits.extraversion < condition.minExtraversion!) {
      return false;
    }

    // インタラクション数チェック
    if (condition.minInteractionCount != null) {
      if (npcState.memorizedInteractions.length <
          condition.minInteractionCount!) {
        return false;
      }
    }

    return true;
  }

  /// 選択肢を選ぶ
  DialogueSession selectOption(
    DialogueSession session,
    String optionId,
    DialogueTree tree,
    int currentAffection,
    NPCBehaviorState npcState,
  ) {
    final currentNode = tree.getNode(session.currentNodeId);
    if (currentNode == null) {
      throw Exception('Current node not found');
    }

    final selectedOption = currentNode.options
        .firstWhere((opt) => opt.optionId == optionId);

    // 新しい交換を記録
    final exchange = DialogueExchange(
      npcText: currentNode.npcText,
      playerChoice: selectedOption.text,
      chosenOptionId: optionId,
      timestamp: DateTime.now(),
      affectionDelta: selectedOption.affectionChange,
    );

    // 次のノードを決定
    final nextNodeId = selectedOption.nextNodeId ?? currentNode.autoNextNodeId;

    return session.copyWith(
      currentNodeId: nextNodeId ?? session.currentNodeId,
      history: [...session.history, exchange],
      isComplete: nextNodeId == null,
      updatedAt: DateTime.now(),
    );
  }

  /// 性格に基づいた対話オプションの修正
  DialogueOption modifyOptionByPersonality(
    DialogueOption option,
    NPCBehaviorState npcState,
  ) {
    var affectionChange = option.affectionChange;
    final personality = npcState.getPersonalityType();

    // 性格に基づいた親密度修正
    final modifier = _behaviorService.applyPersonalityModifier(
      affectionChange,
      npcState.personalityTraits,
      'dialogue',
    );

    // 好みの話題がある場合のボーナス
    if (option.textJa != null || option.text.isNotEmpty) {
      final topicModifier =
          _behaviorService.getTopicModifier(npcState, option.text);
      affectionChange = modifier + topicModifier;
    } else {
      affectionChange = modifier;
    }

    return DialogueOption(
      optionId: option.optionId,
      text: option.text,
      textJa: option.textJa,
      affectionChange: affectionChange,
      nextNodeId: option.nextNodeId,
      setFlags: option.setFlags,
      moodChange: option.moodChange,
      tooltip: option.tooltip,
    );
  }

  /// 対話ノードをレンダリング（性格・ムード考慮）
  String renderDialogueNode(
    DialogueNode node,
    NPCBehaviorState npcState,
  ) {
    var text = node.npcTextJa ?? node.npcText;
    final emoticon = node.emoticon ?? _getMoodEmoticon(npcState.currentMood);

    // 性格に基づいたテキスト修正
    switch (npcState.getPersonalityType()) {
      case PersonalityType.cheerful:
        text = '$emoticon $text 😊';
        break;
      case PersonalityType.calm:
        text = '$emoticon $text 🧘';
        break;
      case PersonalityType.timid:
        text = '$emoticon $text 😳';
        break;
      case PersonalityType.ambitious:
        text = '$emoticon $text 🎯';
        break;
      case PersonalityType.kind:
        text = '$emoticon $text 💝';
        break;
      case PersonalityType.sarcastic:
        text = '$emoticon $text 😏';
        break;
    }

    return text;
  }

  /// 対話セッションを続行
  DialogueNode? continueDialogue(
    DialogueSession session,
    DialogueTree tree,
  ) {
    return tree.getNode(session.currentNodeId);
  }

  /// 対話セッションを終了
  DialogueStatistics endDialogue(
    DialogueSession session,
    NPCBehaviorState npcState,
    int initialAffection,
  ) {
    int totalAffectionChange = 0;
    final treeIds = <String>{session.treeId};

    for (final exchange in session.history) {
      totalAffectionChange += exchange.affectionDelta;
    }

    return DialogueStatistics(
      npcId: session.npcId,
      totalConversations: 1,
      uniqueTreesUsed: treeIds.length,
      totalAffectionChange: totalAffectionChange,
      lastDialogueTime: DateTime.now(),
    );
  }

  /// ムードに基づいた絵文字を取得
  String _getMoodEmoticon(NPCMood mood) {
    switch (mood) {
      case NPCMood.happy:
        return '😊';
      case NPCMood.neutral:
        return '😐';
      case NPCMood.sad:
        return '😢';
      case NPCMood.angry:
        return '😠';
      case NPCMood.excited:
        return '🤩';
      case NPCMood.tired:
        return '😴';
    }
  }

  /// セッションのノード数を取得
  int getSessionNodeCount(DialogueSession session) {
    return session.history.length;
  }

  /// セッションでのアフィニティ変化を取得
  int getSessionAffectionChange(DialogueSession session) {
    return session.history.fold<int>(
      0,
      (sum, exchange) => sum + exchange.affectionDelta,
    );
  }

  /// 対話ツリーをレジスター
  void registerTree(DialogueTree tree) {
    _treeCache[tree.treeId] = tree;
  }

  /// 対話ツリーを取得
  DialogueTree? getTree(String treeId) {
    return _treeCache[treeId];
  }

  /// セッションを取得
  DialogueSession? getSession(String sessionId) {
    return _sessionCache[sessionId];
  }

  /// セッションを削除
  void removeSession(String sessionId) {
    _sessionCache.remove(sessionId);
  }

  /// 対話フローを作成
  DialogueFlow createDialogueFlow(
    String flowId,
    String npcId,
    List<String> treeIds,
    String defaultTreeId,
  ) {
    return DialogueFlow(
      flowId: flowId,
      npcId: npcId,
      treeIds: treeIds,
      defaultTreeId: defaultTreeId,
    );
  }

  /// 対話オプションをフィルタリング（条件による）
  List<DialogueOption> filterOptions(
    DialogueNode node,
    int currentAffection,
    NPCBehaviorState npcState,
  ) {
    return node.options
        .where((opt) => checkCondition(
              null, // オプションレベルの条件は未実装
              currentAffection,
              npcState,
            ))
        .toList();
  }

  /// 性格による対話タイプの推奨を取得
  List<DialogueType> getRecommendedDialogueTypes(
    NPCBehaviorState npcState,
  ) {
    final personality = npcState.getPersonalityType();
    final types = <DialogueType>[];

    switch (personality) {
      case PersonalityType.cheerful:
        types.addAll([
          DialogueType.greeting,
          DialogueType.small_talk,
          DialogueType.romance,
        ]);
        break;
      case PersonalityType.calm:
        types.addAll([
          DialogueType.small_talk,
          DialogueType.quest_offer,
        ]);
        break;
      case PersonalityType.timid:
        types.addAll([
          DialogueType.greeting,
          DialogueType.small_talk,
        ]);
        break;
      case PersonalityType.ambitious:
        types.addAll([
          DialogueType.quest_offer,
          DialogueType.quest_complete,
        ]);
        break;
      case PersonalityType.kind:
        types.addAll([
          DialogueType.greeting,
          DialogueType.small_talk,
          DialogueType.romance,
        ]);
        break;
      case PersonalityType.sarcastic:
        types.addAll([
          DialogueType.small_talk,
          DialogueType.custom,
        ]);
        break;
    }

    return types;
  }

  /// 対話ノードの可用性をチェック
  bool isNodeAvailable(
    DialogueNode node,
    int currentAffection,
    NPCBehaviorState npcState,
  ) {
    return checkCondition(node.condition, currentAffection, npcState);
  }

  /// 対話ツリーをクローン（カスタマイズ用）
  DialogueTree cloneTree(DialogueTree original, String newTreeId) {
    return DialogueTree(
      treeId: newTreeId,
      npcId: original.npcId,
      title: original.title,
      description: original.description,
      rootNodeId: original.rootNodeId,
      nodes: Map.from(original.nodes),
      isActive: original.isActive,
      createdAt: original.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// 対話セッション統計を生成
  DialogueStatistics generateSessionStatistics(
    String npcId,
    List<DialogueSession> sessions,
  ) {
    int totalConversations = sessions.length;
    final treeIds = <String>{};
    int totalAffectionChange = 0;

    for (final session in sessions) {
      treeIds.add(session.treeId);
      totalAffectionChange += getSessionAffectionChange(session);
    }

    final lastSession = sessions.isNotEmpty ? sessions.last : null;

    return DialogueStatistics(
      npcId: npcId,
      totalConversations: totalConversations,
      uniqueTreesUsed: treeIds.length,
      totalAffectionChange: totalAffectionChange,
      lastDialogueTime: lastSession?.updatedAt,
    );
  }
}
