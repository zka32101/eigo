import 'package:eigo/models/npc_registry.dart';

/// NPCリレーションシップシステム
/// NPCs間の関係を管理し、相互作用を追跡
class NPCRelationshipSystem {
  static final NPCRelationshipSystem _instance =
      NPCRelationshipSystem._internal();

  factory NPCRelationshipSystem.getInstance() {
    return _instance;
  }

  NPCRelationshipSystem._internal();

  // NPC間の関係を保存: 'npc1_npc2' -> relationship value
  final Map<String, int> _relationships = {};

  // NPCペアの互換性スコアをキャッシュ
  final Map<String, double> _compatibilityCache = {};

  /// システムを初期化
  void initialize() {
    _relationships.clear();
    _compatibilityCache.clear();
    _initializeAllRelationships();
  }

  /// すべてのNPC間の初期関係を初期化
  void _initializeAllRelationships() {
    final registry = NPCRegistry.getInstance();
    final npcs = registry.getAllNPCs();

    // すべてのNPCペアについて初期関係を設定
    for (int i = 0; i < npcs.length; i++) {
      for (int j = i + 1; j < npcs.length; j++) {
        final npc1 = npcs[i];
        final npc2 = npcs[j];

        // 互換性スコアに基づいて初期関係を計算
        final compatibility =
            calculateCompatibility(npc1.personality, npc2.personality);
        final initialRelationship = (compatibility * 50).toInt() + 30; // 30-80

        _setRelationship(npc1.id, npc2.id, initialRelationship);
      }
    }
  }

  /// 2つのパーソナリティ特性間の互換性を計算 (0.0-1.0)
  double calculateCompatibility(
      PersonalityTraits trait1, PersonalityTraits trait2) {
    // Big Five互換性スコア計算
    final opennessDiff = (trait1.openness - trait2.openness).abs();
    final conscientiousnessDiff =
        (trait1.conscientiousness - trait2.conscientiousness).abs();
    final extraversionDiff = (trait1.extraversion - trait2.extraversion).abs();
    final agreeablenessDiff = (trait1.agreeableness - trait2.agreeableness).abs();
    final neuroticismDiff = (trait1.neuroticism - trait2.neuroticism).abs();

    // 差分が小さいほど互換性が高い (最大差 = 100)
    final compatibilityScore = 1.0 -
        (opennessDiff +
                conscientiousnessDiff +
                extraversionDiff +
                agreeablenessDiff +
                neuroticismDiff) /
            (100 * 5);

    return compatibilityScore.clamp(0.0, 1.0);
  }

  /// NPC間の関係を設定（内部用）
  void _setRelationship(String npcId1, String npcId2, int value) {
    final key = _getRelationshipKey(npcId1, npcId2);
    _relationships[key] = value.clamp(0, 100);
    _compatibilityCache.remove(key); // キャッシュをクリア
  }

  /// NPC間の関係を取得
  int getRelationship(String npcId1, String npcId2) {
    final key = _getRelationshipKey(npcId1, npcId2);
    return _relationships[key] ?? 50; // デフォルト: 中立
  }

  /// NPC間の関係を更新
  void updateRelationship(String npcId1, String npcId2, int delta) {
    final current = getRelationship(npcId1, npcId2);
    final newValue = (current + delta).clamp(0, 100);
    _setRelationship(npcId1, npcId2, newValue);
  }

  /// 関係キーを生成（順序に依存しない）
  String _getRelationshipKey(String npcId1, String npcId2) {
    final ids = [npcId1, npcId2];
    ids.sort();
    return '${ids[0]}_${ids[1]}';
  }

  /// 関係の説明を取得
  String getRelationshipStatus(String npcId1, String npcId2) {
    final value = getRelationship(npcId1, npcId2);

    if (value >= 80) return 'very_close';
    if (value >= 60) return 'friendly';
    if (value >= 40) return 'neutral';
    if (value >= 20) return 'distant';
    return 'hostile';
  }

  /// NPCの気分を別のNPCの存在に基づいて取得
  NPCMood getNPCMoodWithOther(String npcId, String otherNpcId) {
    final relationship = getRelationship(npcId, otherNpcId);
    final registry = NPCRegistry.getInstance();
    final npc = registry.getNPC(npcId);

    if (npc == null) return NPCMood.neutral;

    // 関係の質に基づいて気分を決定
    if (relationship >= 80) return NPCMood.happy;
    if (relationship >= 60) return NPCMood.friendly;
    if (relationship >= 40) return NPCMood.neutral;
    if (relationship >= 20) return NPCMood.uncomfortable;
    return NPCMood.hostile;
  }

  /// 互いに最も親しいNPCペアを取得
  List<NPCPair> getClosestPairs({int limit = 5}) {
    final pairs = <NPCPair>[];

    _relationships.forEach((key, value) {
      final parts = key.split('_');
      if (parts.length == 2) {
        pairs.add(NPCPair(
          npcId1: parts[0],
          npcId2: parts[1],
          relationship: value,
        ));
      }
    });

    pairs.sort((a, b) => b.relationship.compareTo(a.relationship));
    return pairs.take(limit).toList();
  }

  /// 特定のNPCの友好的な関係を取得
  List<String> getAllyNPCs(String npcId, {int threshold = 60}) {
    final allies = <String>[];

    _relationships.forEach((key, value) {
      if (value >= threshold) {
        final parts = key.split('_');
        if (parts.length == 2) {
          if (parts[0] == npcId) {
            allies.add(parts[1]);
          } else if (parts[1] == npcId) {
            allies.add(parts[0]);
          }
        }
      }
    });

    return allies;
  }

  /// 特定のNPCの敵対的な関係を取得
  List<String> getEnemyNPCs(String npcId, {int threshold = 40}) {
    final enemies = <String>[];

    _relationships.forEach((key, value) {
      if (value <= threshold) {
        final parts = key.split('_');
        if (parts.length == 2) {
          if (parts[0] == npcId) {
            enemies.add(parts[1]);
          } else if (parts[1] == npcId) {
            enemies.add(parts[0]);
          }
        }
      }
    });

    return enemies;
  }

  /// すべての関係を取得
  Map<String, int> getAllRelationships() {
    return Map.from(_relationships);
  }
}

/// NPC関係ペア
class NPCPair {
  final String npcId1;
  final String npcId2;
  final int relationship;

  NPCPair({
    required this.npcId1,
    required this.npcId2,
    required this.relationship,
  });

  String getStatusText() {
    if (relationship >= 80) return 'very close';
    if (relationship >= 60) return 'friendly';
    if (relationship >= 40) return 'neutral';
    if (relationship >= 20) return 'distant';
    return 'hostile';
  }
}

/// NPC気分の種類
enum NPCMood {
  hostile,
  uncomfortable,
  neutral,
  friendly,
  happy,
}
