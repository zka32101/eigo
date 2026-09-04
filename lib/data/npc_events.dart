import 'package:eigo/models/event_system.dart';
import 'package:eigo/models/npc_relationship_system.dart';

/// NPC関連のイベントとトリガーの定義

class NPCEventRegistry {
  static final NPCEventRegistry _instance = NPCEventRegistry._internal();

  factory NPCEventRegistry.getInstance() {
    return _instance;
  }

  NPCEventRegistry._internal();

  /// すべてのNPCイベントトリガーを初期化
  void initializeEventTriggers() {
    final triggerManager = EventTriggerManager.getInstance();

    // Aria：親密度90到達時のイベント
    triggerManager.registerTrigger(
      AffectionTrigger(
        id: 'aria_close_bond',
        eventType: EventType.affectionMilestone,
        npcId: 'aria_001',
        affectionThreshold: 90,
      ),
    );

    // Luna：親密度70到達時のイベント
    triggerManager.registerTrigger(
      AffectionTrigger(
        id: 'luna_research_unlocked',
        eventType: EventType.affectionMilestone,
        npcId: 'luna_002',
        affectionThreshold: 70,
      ),
    );

    // Kai：親密度80到達時のイベント
    triggerManager.registerTrigger(
      AffectionTrigger(
        id: 'kai_warrior_bond',
        eventType: EventType.affectionMilestone,
        npcId: 'kai_004',
        affectionThreshold: 80,
      ),
    );

    // Thorn：親密度75到達時のイベント
    triggerManager.registerTrigger(
      AffectionTrigger(
        id: 'thorn_healer_trust',
        eventType: EventType.affectionMilestone,
        npcId: 'thorn_006',
        affectionThreshold: 75,
      ),
    );

    // Isabella：親密度85到達時のイベント
    triggerManager.registerTrigger(
      AffectionTrigger(
        id: 'isabella_bard_inspiration',
        eventType: EventType.affectionMilestone,
        npcId: 'isabella_010',
        affectionThreshold: 85,
      ),
    );
  }

  /// NPC関係が変わった時のイベントを生成
  static GameEvent createRelationshipChangedEvent(
    String npcId1,
    String npcId2,
    int relationshipValue,
    String statusBefore,
  ) {
    return GameEvent(
      id: 'relationship_${npcId1}_${npcId2}_${DateTime.now().millisecondsSinceEpoch}',
      type: EventType.relationshipChanged,
      title: 'NPC Relationship Changed',
      description: '$npcId1 and $npcId2 relationship changed to $relationshipValue',
      data: {
        'npcId1': npcId1,
        'npcId2': npcId2,
        'relationshipValue': relationshipValue,
        'statusBefore': statusBefore,
      },
    );
  }

  /// NPC親密度マイルストーンイベントを生成
  static GameEvent createAffectionMilestoneEvent(
    String npcId,
    int affectionLevel,
    String npcName,
  ) {
    return GameEvent(
      id: 'affection_milestone_${npcId}_$affectionLevel',
      type: EventType.affectionMilestone,
      title: 'Affection Milestone Reached!',
      description: 'Your affection with $npcName reached $affectionLevel!',
      data: {
        'npcId': npcId,
        'affectionLevel': affectionLevel,
        'npcName': npcName,
      },
    );
  }

  /// マルチNPC対話イベントを生成
  static GameEvent createNPCMeetingEvent(
    List<String> npcIds,
    String scenario,
  ) {
    return GameEvent(
      id: 'npc_meeting_${npcIds.join('_')}_${DateTime.now().millisecondsSinceEpoch}',
      type: EventType.npcMeeting,
      title: 'NPC Meeting: $scenario',
      description: 'A special encounter between NPCs: ${npcIds.join(", ")}',
      data: {
        'npcIds': npcIds,
        'scenario': scenario,
      },
    );
  }

  /// パーティメンバー間の相互作用
  static List<String> getPartyInteractionDialogue(
    String leaderId,
    String companionId,
    int relationshipValue,
  ) {
    // 関係に基づいて対話を返す
    if (relationshipValue >= 80) {
      return [
        'We make a great team!',
        'I trust you completely.',
        'Let\'s show them our power!',
      ];
    } else if (relationshipValue >= 60) {
      return [
        'I\'m glad we\'re working together.',
        'You\'re reliable.',
        'Let\'s do this.',
      ];
    } else if (relationshipValue >= 40) {
      return [
        'I suppose we can work together.',
        'Let\'s not mess this up.',
        'Stay focused.',
      ];
    } else {
      return [
        'We don\'t get along, but we need to cooperate.',
        'Try not to get in my way.',
        'This is strictly business.',
      ];
    }
  }

  /// NPC関係に基づいた敵対行動
  static List<String> getHotilityDialogue(
    String npcId1,
    String npcId2,
    int relationshipValue,
  ) {
    if (relationshipValue <= 20) {
      return [
        'I can\'t stand to be near you!',
        'Stay away from me!',
        'Don\'t even look at me.',
      ];
    } else if (relationshipValue <= 40) {
      return [
        'I don\'t trust you.',
        'Why are you here?',
        'Let\'s keep our distance.',
      ];
    }
    return [];
  }
}

/// マルチNPC対話シーン用のデータ構造
class MultiNPCDialogueScene {
  final String id;
  final String title;
  final List<String> participantNpcIds;
  final List<DialogueExchange> exchanges;
  final String? triggerCondition; // 対話が発生する条件

  MultiNPCDialogueScene({
    required this.id,
    required this.title,
    required this.participantNpcIds,
    required this.exchanges,
    this.triggerCondition,
  });
}

/// 複数NPC間の対話交換
class DialogueExchange {
  final String speakerId;
  final String speakerName;
  final String dialogue;
  final List<String>? responses; // 他のNPCの応答（オプション）

  DialogueExchange({
    required this.speakerId,
    required this.speakerName,
    required this.dialogue,
    this.responses,
  });
}

/// マルチNPC対話シーンの例
class MultiNPCDialogueExamples {
  static final ariaMeetsLuna = MultiNPCDialogueScene(
    id: 'aria_luna_meeting_001',
    title: 'Knowledge Exchange',
    participantNpcIds: ['aria_001', 'luna_002'],
    exchanges: [
      DialogueExchange(
        speakerId: 'aria_001',
        speakerName: 'Aria',
        dialogue: 'Luna, I\'ve been experimenting with that spell you suggested!',
        responses: [
          'That\'s wonderful. Show me what you\'ve learned.',
        ],
      ),
      DialogueExchange(
        speakerId: 'luna_002',
        speakerName: 'Luna',
        dialogue: 'That\'s wonderful. Show me what you\'ve learned.',
      ),
      DialogueExchange(
        speakerId: 'aria_001',
        speakerName: 'Aria',
        dialogue: 'Watch this! *demonstrates spell*',
      ),
      DialogueExchange(
        speakerId: 'luna_002',
        speakerName: 'Luna',
        dialogue: 'Excellent form. Your understanding of the arcane structure is impressive.',
      ),
    ],
  );

  static final kaiMeetsEloise = MultiNPCDialogueScene(
    id: 'kai_eloise_meeting_001',
    title: 'Unlikely Alliance',
    participantNpcIds: ['kai_004', 'eloise_005'],
    exchanges: [
      DialogueExchange(
        speakerId: 'kai_004',
        speakerName: 'Kai',
        dialogue: 'I heard you\'ve been causing trouble in the city.',
      ),
      DialogueExchange(
        speakerId: 'eloise_005',
        speakerName: 'Eloise',
        dialogue: 'Only from those who deserve it. Besides, who\'s asking?',
      ),
      DialogueExchange(
        speakerId: 'kai_004',
        speakerName: 'Kai',
        dialogue: 'Someone who thinks you\'re wasting your talents. Join our cause.',
      ),
      DialogueExchange(
        speakerId: 'eloise_005',
        speakerName: 'Eloise',
        dialogue: 'Interesting proposal. What\'s in it for me?',
      ),
    ],
  );

  static final thornMeetsZephyr = MultiNPCDialogueScene(
    id: 'thorn_zephyr_meeting_001',
    title: 'Business and Heart',
    participantNpcIds: ['thorn_006', 'zephyr_007'],
    exchanges: [
      DialogueExchange(
        speakerId: 'zephyr_007',
        speakerName: 'Zephyr',
        dialogue: 'Thorn, those rare herbs you promised would fetch good prices.',
      ),
      DialogueExchange(
        speakerId: 'thorn_006',
        speakerName: 'Thorn',
        dialogue: 'The herbs are for the sick villagers. I won\'t profit from their suffering.',
      ),
      DialogueExchange(
        speakerId: 'zephyr_007',
        speakerName: 'Zephyr',
        dialogue: 'Your kindness is admirable, though it makes little business sense.',
      ),
      DialogueExchange(
        speakerId: 'thorn_006',
        speakerName: 'Thorn',
        dialogue: 'Some things matter more than profit, my friend.',
      ),
    ],
  );

  static final isabellaGroups = MultiNPCDialogueScene(
    id: 'isabella_gathering_001',
    title: 'Bard\'s Festival',
    participantNpcIds: ['isabella_010', 'kai_004', 'thorn_006'],
    exchanges: [
      DialogueExchange(
        speakerId: 'isabella_010',
        speakerName: 'Isabella',
        dialogue: 'Friends! I\'m organizing a festival. Will you help?',
        responses: ['Of course!', 'For you, always.'],
      ),
      DialogueExchange(
        speakerId: 'kai_004',
        speakerName: 'Kai',
        dialogue: 'Of course! The village needs some joy.',
      ),
      DialogueExchange(
        speakerId: 'thorn_006',
        speakerName: 'Thorn',
        dialogue: 'A gathering to celebrate life. I love it.',
      ),
      DialogueExchange(
        speakerId: 'isabella_010',
        speakerName: 'Isabella',
        dialogue: 'Wonderful! Together we can make this unforgettable!',
      ),
    ],
  );
}
