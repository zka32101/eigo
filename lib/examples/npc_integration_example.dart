import 'package:eigo/models/npc_behavior_model.dart';
import 'package:eigo/models/npc_dialogue_model.dart';
import 'package:eigo/models/npc_event_model.dart';
import 'package:eigo/models/npc_quest_model.dart';
import 'package:eigo/models/npc_skill_model.dart';
import 'package:eigo/models/npc_save_model.dart';
import 'package:eigo/services/npc_behavior_service.dart';
import 'package:eigo/services/npc_dialogue_service.dart';
import 'package:eigo/services/npc_event_service.dart';
import 'package:eigo/services/npc_quest_service.dart';
import 'package:eigo/services/npc_skill_service.dart';
import 'package:eigo/services/npc_save_load_service.dart';

/// NPC システム統合例
///
/// このクラスは、すべての NPC システムが連携して動作する完全な例を示します：
/// 1. NPC の性格と行動
/// 2. 対話システム
/// 3. イベントシステム
/// 4. クエストシステム
/// 5. スキル教えるシステム
/// 6. セーブ/ロード
class NPCIntegrationExample {
  late NPCBehaviorService behaviorService;
  late NPCDialogueService dialogueService;
  late NPCEventService eventService;
  late NPCQuestService questService;
  late NPCSkillService skillService;
  late NPCSaveLoadService saveLoadService;

  NPCIntegrationExample() {
    behaviorService = NPCBehaviorService.getInstance();
    dialogueService = NPCDialogueService.getInstance();
    eventService = NPCEventService.getInstance();
    questService = NPCQuestService.getInstance();
    skillService = NPCSkillService.getInstance();
    saveLoadService = NPCSaveLoadService.getInstance();
  }

  /// 完全な NPC ゲームループの例
  ///
  /// シーン:
  /// プレイヤーが魔法使いの NPC "Aria" に会い、
  /// ファイアボールスキルを学ぶクエストを受け取り、
  /// 完了して報酬を得る
  Future<void> runCompleteGameLoop() async {
    print('=== NPC Integration Example ===\n');

    // ステップ 1: NPC を初期化
    print('Step 1: Initialize NPC Personality and Behavior');
    final ariaBehavior = _initializeAria();
    print('✓ Aria initialized with personality traits\n');

    // ステップ 2: 対話ツリーを設定
    print('Step 2: Setup Dialogue Tree');
    final dialogueTree = _setupDialogueTree();
    print('✓ Dialogue tree created\n');

    // ステップ 3: クエストを作成
    print('Step 3: Create Fireball Quest');
    final fireballQuest = _createFireballQuest();
    print('✓ Quest created: ${fireballQuest.questName}\n');

    // ステップ 4: スキルを登録
    print('Step 4: Register Fireball Skill');
    final fireballSkill = _registerFireballSkill();
    print('✓ Skill registered: ${fireballSkill.skillName}\n');

    // ステップ 5: 対話を開始
    print('Step 5: Start Dialogue with Aria');
    final session = _startDialogue(dialogueTree);
    print('✓ Dialogue started\n');

    // ステップ 6: クエストを受け入れる
    print('Step 6: Accept Quest');
    _acceptQuest(fireballQuest);
    print('✓ Quest accepted\n');

    // ステップ 7: クエスト進行
    print('Step 7: Progress Through Quest Steps');
    _progressQuest(fireballQuest);
    print('✓ All quest steps completed\n');

    // ステップ 8: スキルを習得
    print('Step 8: Learn Fireball Skill');
    _learnSkill(fireballSkill);
    print('✓ Skill learned\n');

    // ステップ 9: イベント報酬を配布
    print('Step 9: Distribute Rewards');
    _distributeRewards(ariaBehavior, fireballQuest);
    print('✓ Rewards distributed\n');

    // ステップ 10: ゲーム状態を保存
    print('Step 10: Save Game State');
    await _saveGameState(ariaBehavior, fireballQuest);
    print('✓ Game saved\n');

    // ステップ 11: ゲーム状態を読み込む
    print('Step 11: Load Game State');
    await _loadGameState();
    print('✓ Game loaded\n');

    print('=== Integration Complete ===');
  }

  /// Aria の NPC 行動状態を初期化
  NPCBehaviorState _initializeAria() {
    final personalityTraits = PersonalityTraits(
      openness: 75, // 新しい経験に開かれている
      conscientiousness: 60, // 責任感がある
      extraversion: 50, // 中間
      agreeableness: 80, // 協力的で親切
      neuroticism: 30, // 感情的に安定している
    );

    final ariaBehavior = behaviorService.initializeBehaviorState(
      'aria',
      personalityTraits,
    );

    // 習慣を追加
    behaviorService.addHabit(
      ariaBehavior.copyWith(),
      Habit(
        habitId: 'daily-meditation',
        habitName: 'Daily Meditation',
        frequency: HabitFrequency.daily,
      ),
    );

    return ariaBehavior;
  }

  /// 対話ツリーを設定
  DialogueTree _setupDialogueTree() {
    final greeting = DialogueNode(
      nodeId: 'greeting',
      npcText: 'Welcome, student. I sense magical potential in you.',
      options: [
        DialogueOption(
          text: 'Can you teach me magic?',
          affectionChange: 10,
          nextNodeId: 'teach-offer',
        ),
        DialogueOption(
          text: 'I am just passing through.',
          affectionChange: -5,
          nextNodeId: 'farewell',
        ),
      ],
      emoticon: '✨',
    );

    final teachOffer = DialogueNode(
      nodeId: 'teach-offer',
      npcText: 'I would be happy to teach you the art of fire magic. It requires dedication and practice.',
      options: [
        DialogueOption(
          text: 'I accept this challenge.',
          affectionChange: 20,
          nextNodeId: 'quest-start',
          eventId: 'quest-offered-event',
        ),
        DialogueOption(
          text: 'Perhaps later.',
          affectionChange: 0,
          nextNodeId: 'farewell',
        ),
      ],
      emoticon: '🔥',
    );

    final questStart = DialogueNode(
      nodeId: 'quest-start',
      npcText: 'Excellent. Your first task is to gather the necessary components.',
      options: [
        DialogueOption(
          text: 'I will begin immediately.',
          affectionChange: 15,
          nextNodeId: 'farewell',
        ),
      ],
      emoticon: '📚',
    );

    final farewell = DialogueNode(
      nodeId: 'farewell',
      npcText: 'Farewell, student.',
      options: [],
      emoticon: '👋',
    );

    return DialogueTree(
      treeId: 'aria-main',
      npcId: 'aria',
      rootNodeId: 'greeting',
      nodes: {
        'greeting': greeting,
        'teach-offer': teachOffer,
        'quest-start': questStart,
        'farewell': farewell,
      },
    );
  }

  /// ファイアボールクエストを作成
  NPCQuest _createFireballQuest() {
    final step1 = QuestStep(
      stepId: 'gather-components',
      description: 'Gather magical components from the forest.',
      objective: 'Find 5 Mana Crystals and 3 Fire Essence',
    );

    final step2 = QuestStep(
      stepId: 'prepare-ritual',
      description: 'Prepare the ritual area.',
      objective: 'Create a circle in the designated location',
    );

    final step3 = QuestStep(
      stepId: 'learn-incantation',
      description: 'Learn the fire incantation.',
      objective: 'Memorize and recite the spell words',
    );

    final reward = QuestReward(
      xpReward: 1000,
      goldReward: 500,
      affectionBonus: 50,
      skillRewards: ['fireball'],
    );

    return questService.createQuest(
      questId: 'fireball-quest',
      npcId: 'aria',
      questName: 'Learn Fireball Magic',
      description: 'Master the ancient art of casting fireball spells',
      steps: [step1, step2, step3],
      reward: reward,
      condition: QuestCondition(minAffection: 20),
    );
  }

  /// ファイアボールスキルを登録
  NPCSkill _registerFireballSkill() {
    final directTeaching = SkillTeachingMethod(
      methodId: 'direct-teaching',
      name: 'Direct Instruction',
      description: 'Learn from Aria through direct magical instruction',
      requiredInteractionCount: 5,
      requiredAffection: 40,
      teachingDurationMinutes: 120,
      efficiencyMultiplier: 1.3,
    );

    const practiceMethod = SkillTeachingMethod(
      methodId: 'practice',
      name: 'Practice and Repetition',
      description: 'Learn by practicing the spell',
      requiredInteractionCount: 10,
      requiredAffection: 30,
      teachingDurationMinutes: 180,
      efficiencyMultiplier: 1.0,
    );

    return skillService.registerSkill(
      skillId: 'fireball',
      skillName: 'Fireball',
      description: 'Cast a massive fireball at your target',
      category: SkillCategory.magic,
      teachingNpcId: 'aria',
      maxLevel: SkillLevel.master,
      teachingMethods: [directTeaching, practiceMethod],
      experienceRequired: 1000,
      effectDescription: 'Deals 75 fire damage, AOE 3m radius',
    );
  }

  /// 対話を開始
  DialogueSession _startDialogue(DialogueTree tree) {
    dialogueService.registerTree(tree);
    final session = DialogueSession(
      sessionId: 'session-aria-1',
      npcId: 'aria',
      treeId: 'aria-main',
      isActive: true,
      startedAt: DateTime.now(),
      currentNodeId: 'greeting',
    );
    return session;
  }

  /// クエストを受け入れる
  void _acceptQuest(NPCQuest quest) {
    questService.acceptQuest(quest.questId);
    questService.startQuest(quest.questId);
  }

  /// クエスト進行
  void _progressQuest(NPCQuest quest) {
    for (final step in quest.steps) {
      questService.completeQuestStep(quest.questId, step.stepId);
    }
  }

  /// スキルを習得
  void _learnSkill(NPCSkill skill) {
    // スキル習得セッション開始
    final session = skillService.startLearningSession(
      sessionId: 'skill-session-1',
      npcId: 'aria',
      skillId: skill.skillId,
      teachingMethodId: 'direct-teaching',
    );

    // セッション完了
    skillService.completeLearningSession(
      session.sessionId,
      experienceGained: 500,
    );

    // スキルを習得
    skillService.learnSkill(
      skillId: skill.skillId,
      skillName: skill.skillName,
    );

    // 経験値を追加
    skillService.addSkillExperience(skill.skillId, 500);
  }

  /// 報酬を配布
  void _distributeRewards(NPCBehaviorState ariaBehavior, NPCQuest quest) {
    // 親密度を増加
    final newAffection = ariaBehavior.currentAffection + quest.reward.affectionBonus;
    print('Affection increased: ${ariaBehavior.currentAffection} → $newAffection');

    // 気分を更新
    print('Aria\'s mood: ${ariaBehavior.currentMood.english}');

    // イベントを作成
    final completionEvent = eventService.createEvent(
      'aria',
      EventType.quest_completed,
      'Fireball Quest Completed',
      'Successfully learned the Fireball spell from Aria',
      'quest',
      priority: EventPriority.high,
      reward: EventReward(
        affectionBonus: quest.reward.affectionBonus,
        xpReward: quest.reward.xpReward,
        goldReward: quest.reward.goldReward,
        skillRewardId: 'fireball',
      ),
    );

    eventService.processEvent(completionEvent.eventId);
  }

  /// ゲーム状態を保存
  Future<void> _saveGameState(
    NPCBehaviorState ariaBehavior,
    NPCQuest quest,
  ) async {
    final savedNpcState = SavedNPCState(
      npcId: 'aria',
      npcName: 'Aria the Mage',
      personalityTraits: ariaBehavior.personalityTraits,
      currentAffection: ariaBehavior.currentAffection + 50, // Quest bonus
      currentMood: ariaBehavior.currentMood,
      memorizedInteractions: ariaBehavior.memorizedInteractions,
      executedBehaviors: ariaBehavior.executedBehaviors,
      habits: ariaBehavior.habits,
      preferredTopics: ariaBehavior.preferredTopics,
      dislikedTopics: ariaBehavior.dislikedTopics,
      savedAt: DateTime.now(),
      gameElapsedTime: const Duration(hours: 3),
    );

    final gameData = SaveGameData(
      saveId: 'save-1',
      saveName: 'Quest Complete',
      playerLevel: 5,
      playerExperience: 1000,
      gamePlayedTime: const Duration(hours: 3),
      currentLocation: 'Aria\'s Tower',
      npcStates: {'aria': savedNpcState},
      storyProgression: {'learned-fireball': true},
      completedQuests: ['fireball-quest'],
      activeQuests: [],
      inventory: {'mana-crystal': 5, 'fire-essence': 3},
      gold: 500,
      savedAt: DateTime.now(),
      lastPlayedAt: DateTime.now(),
      gameVersion: '1.0.0',
    );

    final result = await saveLoadService.saveGame(gameData);
    print('Save result: ${result.name}');
  }

  /// ゲーム状態を読み込む
  Future<void> _loadGameState() async {
    final (result, gameData) = await saveLoadService.loadGame('save-1');
    if (result == LoadResult.success && gameData != null) {
      print('Loaded save: ${gameData.saveName}');
      print('Player Level: ${gameData.playerLevel}');
      print('Completed Quests: ${gameData.completedQuests.length}');
      print('Gold: ${gameData.gold}');

      // Aria の状態を復元
      if (gameData.npcStates.containsKey('aria')) {
        final ariaState = gameData.npcStates['aria']!;
        print('Aria\'s Affection: ${ariaState.currentAffection}');
        print('Aria\'s Mood: ${ariaState.currentMood.english}');
      }
    }
  }
}

/// 実行例
void main() async {
  final example = NPCIntegrationExample();
  await example.runCompleteGameLoop();
}
