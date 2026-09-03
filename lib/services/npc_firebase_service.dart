import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eigo/models/npc_extended_model.dart';
import 'package:eigo/models/interaction_history_model.dart';
import 'package:eigo/models/dialogue_template_model.dart';

/// NPC Firebase サービス（シングルトンパターン）
/// NPC データ、関係、テンプレートの永続化を管理
class NPCFirebaseService {
  static final NPCFirebaseService _instance = NPCFirebaseService._internal();

  factory NPCFirebaseService() {
    return _instance;
  }

  NPCFirebaseService._internal();

  final _firestore = FirebaseFirestore.instance;
  static const _npcsCollection = 'npcs';
  static const _templatesCollection = 'dialogue-templates';

  /// シングルトンインスタンスを取得
  static NPCFirebaseService getInstance() {
    return _instance;
  }

  // ==================== NPC Extended Data ====================

  /// NPC拡張データを保存
  Future<void> saveNPCExtended(NPCExtended npcExtended) async {
    try {
      await _firestore
          .collection(_npcsCollection)
          .doc(npcExtended.npcId)
          .set(npcExtended.toJson(), SetOptions(merge: true));
    } catch (e) {
      print('Error saving NPC extended data: $e');
      rethrow;
    }
  }

  /// NPC拡張データを取得
  Future<NPCExtended?> getNPCExtended(String npcId) async {
    try {
      final doc = await _firestore
          .collection(_npcsCollection)
          .doc(npcId)
          .get();

      if (!doc.exists) return null;
      return NPCExtended.fromJson(doc.data()!);
    } catch (e) {
      print('Error getting NPC extended data: $e');
      return null;
    }
  }

  /// すべてのNPC拡張データを取得
  Future<List<NPCExtended>> getAllNPCExtended() async {
    try {
      final snapshot = await _firestore.collection(_npcsCollection).get();
      return snapshot.docs
          .map((doc) => NPCExtended.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting all NPC extended data: $e');
      return [];
    }
  }

  /// NPC気分を更新
  Future<void> updateNPCMood(String npcId, String moodState) async {
    try {
      await _firestore
          .collection(_npcsCollection)
          .doc(npcId)
          .update({
        'currentMoodState': moodState,
        'moodLastUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating NPC mood: $e');
      rethrow;
    }
  }

  /// NPC利用可能性を更新
  Future<void> updateNPCAvailability(
    String npcId,
    NPCAvailabilitySchedule schedule,
  ) async {
    try {
      await _firestore
          .collection(_npcsCollection)
          .doc(npcId)
          .update({
        'availabilitySchedule': schedule.toJson(),
      });
    } catch (e) {
      print('Error updating NPC availability: $e');
      rethrow;
    }
  }

  // ==================== NPC Relationships ====================

  /// NPC関係を保存/更新
  Future<void> saveNPCRelationship(
    String userId,
    NPCRelationship relationship,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('npc-relationships')
          .doc(relationship.npcId)
          .set(relationship.toJson(), SetOptions(merge: true));
    } catch (e) {
      print('Error saving NPC relationship: $e');
      rethrow;
    }
  }

  /// NPC関係を取得
  Future<NPCRelationship?> getNPCRelationship(
    String userId,
    String npcId,
  ) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('npc-relationships')
          .doc(npcId)
          .get();

      if (!doc.exists) return null;
      return NPCRelationship.fromJson(doc.data()!);
    } catch (e) {
      print('Error getting NPC relationship: $e');
      return null;
    }
  }

  /// ユーザーのすべてのNPC関係を取得
  Future<List<NPCRelationship>> getUserNPCRelationships(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('npc-relationships')
          .get();

      return snapshot.docs
          .map((doc) => NPCRelationship.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting user NPC relationships: $e');
      return [];
    }
  }

  /// 親密度レベルで関係をフィルタ
  Future<List<NPCRelationship>> getRelationshipsByAffection(
    String userId,
    int minAffection,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('npc-relationships')
          .where('affectionLevel', isGreaterThanOrEqualTo: minAffection)
          .get();

      return snapshot.docs
          .map((doc) => NPCRelationship.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting relationships by affection: $e');
      return [];
    }
  }

  // ==================== Dialogue Templates ====================

  /// ダイアログテンプレートを保存
  Future<void> saveDialogueTemplate(DialogueTemplate template) async {
    try {
      await _firestore
          .collection(_templatesCollection)
          .doc(template.templateId)
          .set(template.toJson(), SetOptions(merge: true));
    } catch (e) {
      print('Error saving dialogue template: $e');
      rethrow;
    }
  }

  /// ダイアログテンプレートを取得
  Future<DialogueTemplate?> getDialogueTemplate(String templateId) async {
    try {
      final doc = await _firestore
          .collection(_templatesCollection)
          .doc(templateId)
          .get();

      if (!doc.exists) return null;
      return DialogueTemplate.fromJson(doc.data()!);
    } catch (e) {
      print('Error getting dialogue template: $e');
      return null;
    }
  }

  /// NPC別のダイアログテンプレートを取得
  Future<List<DialogueTemplate>> getDialogueTemplatesByNPC(
    String npcId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_templatesCollection)
          .where('npcId', isEqualTo: npcId)
          .get();

      return snapshot.docs
          .map((doc) => DialogueTemplate.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting dialogue templates by NPC: $e');
      return [];
    }
  }

  /// 難易度別にテンプレートを取得
  Future<List<DialogueTemplate>> getDialogueTemplatesByDifficulty(
    String npcId,
    String difficulty,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_templatesCollection)
          .where('npcId', isEqualTo: npcId)
          .where('difficulty', isEqualTo: difficulty)
          .get();

      return snapshot.docs
          .map((doc) => DialogueTemplate.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting templates by difficulty: $e');
      return [];
    }
  }

  /// トピック別にテンプレートを取得
  Future<List<DialogueTemplate>> getDialogueTemplatesByTopic(
    String npcId,
    String topic,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_templatesCollection)
          .where('npcId', isEqualTo: npcId)
          .where('topic', isEqualTo: topic)
          .get();

      return snapshot.docs
          .map((doc) => DialogueTemplate.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting templates by topic: $e');
      return [];
    }
  }

  // ==================== Interaction History ====================

  /// インタラクションレコードを保存
  Future<void> saveInteractionRecord(
    String userId,
    InteractionRecord record,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('interaction-history')
          .doc(record.recordId)
          .set(record.toJson());
    } catch (e) {
      print('Error saving interaction record: $e');
      rethrow;
    }
  }

  /// ユーザーのインタラクション履歴を取得（ページネーション）
  Future<List<InteractionRecord>> getUserInteractionHistory(
    String userId, {
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firestore
          .collection('users')
          .doc(userId)
          .collection('interaction-history')
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => InteractionRecord.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting user interaction history: $e');
      return [];
    }
  }

  /// NPC別のインタラクション履歴を取得
  Future<List<InteractionRecord>> getInteractionHistoryByNPC(
    String userId,
    String npcId, {
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('interaction-history')
          .where('npcId', isEqualTo: npcId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) =>
              InteractionRecord.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting interaction history by NPC: $e');
      return [];
    }
  }

  /// 日付範囲でインタラクション履歴を取得
  Future<List<InteractionRecord>> getInteractionHistoryByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate, {
    int limit = 100,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('interaction-history')
          .where('timestamp', isGreaterThanOrEqualTo: startDate)
          .where('timestamp', isLessThanOrEqualTo: endDate)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) =>
              InteractionRecord.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting interaction history by date: $e');
      return [];
    }
  }

  // ==================== NPC Interaction Metrics ====================

  /// NPC インタラクションメトリクスを保存
  Future<void> saveNPCInteractionMetrics(
    String userId,
    NPCInteractionMetrics metrics,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('npc-metrics')
          .doc(metrics.npcId)
          .set(metrics.toJson(), SetOptions(merge: true));
    } catch (e) {
      print('Error saving NPC metrics: $e');
      rethrow;
    }
  }

  /// NPC インタラクションメトリクスを取得
  Future<NPCInteractionMetrics?> getNPCInteractionMetrics(
    String userId,
    String npcId,
  ) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('npc-metrics')
          .doc(npcId)
          .get();

      if (!doc.exists) return null;
      return NPCInteractionMetrics.fromJson(doc.data()!);
    } catch (e) {
      print('Error getting NPC metrics: $e');
      return null;
    }
  }

  /// ユーザーのすべてのNPCメトリクスを取得
  Future<List<NPCInteractionMetrics>> getUserAllNPCMetrics(
    String userId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('npc-metrics')
          .orderBy('averageScore', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => NPCInteractionMetrics.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting all NPC metrics: $e');
      return [];
    }
  }

  // ==================== Conversation Sessions ====================

  /// 会話セッションを保存
  Future<void> saveConversationSession(
    String userId,
    ConversationSession session,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('conversation-sessions')
          .doc(session.sessionId)
          .set(session.toJson());
    } catch (e) {
      print('Error saving conversation session: $e');
      rethrow;
    }
  }

  /// ユーザーの会話セッション一覧を取得
  Future<List<ConversationSession>> getUserConversationSessions(
    String userId, {
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('conversation-sessions')
          .orderBy('startedAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) =>
              ConversationSession.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting conversation sessions: $e');
      return [];
    }
  }

  /// NPC別の会話セッション一覧を取得
  Future<List<ConversationSession>> getConversationSessionsByNPC(
    String userId,
    String npcId, {
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('conversation-sessions')
          .where('npcId', isEqualTo: npcId)
          .orderBy('startedAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) =>
              ConversationSession.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting conversation sessions by NPC: $e');
      return [];
    }
  }

  // ==================== Batch Operations ====================

  /// 複数のインタラクションレコードをバッチ保存
  Future<void> batchSaveInteractionRecords(
    String userId,
    List<InteractionRecord> records,
  ) async {
    try {
      final batch = _firestore.batch();

      for (final record in records) {
        final docRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('interaction-history')
            .doc(record.recordId);
        batch.set(docRef, record.toJson());
      }

      await batch.commit();
    } catch (e) {
      print('Error batch saving interaction records: $e');
      rethrow;
    }
  }

  /// 複数のダイアログテンプレートをバッチ保存
  Future<void> batchSaveDialogueTemplates(
    List<DialogueTemplate> templates,
  ) async {
    try {
      final batch = _firestore.batch();

      for (final template in templates) {
        final docRef =
            _firestore.collection(_templatesCollection).doc(template.templateId);
        batch.set(docRef, template.toJson());
      }

      await batch.commit();
    } catch (e) {
      print('Error batch saving templates: $e');
      rethrow;
    }
  }
}
