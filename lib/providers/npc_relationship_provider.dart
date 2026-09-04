import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eigo/models/npc_relationship_model.dart';
import 'package:eigo/services/npc_relationship_service.dart';

/// NPC関係管理サービスプロバイダー
final npcRelationshipServiceProvider =
    Provider<NPCRelationshipService>((ref) {
  return NPCRelationshipService.getInstance();
});

/// NPC関係データプロバイダー（NPC単位）
final npcRelationshipProvider =
    StateNotifierProvider.family<NPCRelationshipNotifier, NPCRelationship?, String>(
        (ref, npcId) {
  final service = ref.watch(npcRelationshipServiceProvider);
  return NPCRelationshipNotifier(
    service: service,
    npcId: npcId,
    userId: 'current-user',
  );
});

/// NPC関係Notifier
class NPCRelationshipNotifier extends StateNotifier<NPCRelationship?> {
  final NPCRelationshipService _service;
  final String _npcId;
  final String _userId;

  NPCRelationshipNotifier({
    required NPCRelationshipService service,
    required String npcId,
    required String userId,
  })  : _service = service,
        _npcId = npcId,
        _userId = userId,
        super(null) {
    _initialize();
  }

  void _initialize() {
    state = _service.initializeRelationship(_npcId, _userId);
  }

  void updateAfterDialogue(int score, String? feedback) {
    if (state == null) return;
    state = _service.updateAffectionAfterDialogue(state!, score, feedback);
  }

  void unlockDialogue(String dialogueId) {
    if (state == null) return;
    state = state!.copyWith(
      unlockedDialogues: [...state!.unlockedDialogues, dialogueId],
      updatedAt: DateTime.now(),
    );
  }

  void recordChoice(String dialogueId, String choicePath) {
    if (state == null) return;
    state = _service.recordDialogueChoice(state!, dialogueId, choicePath);
  }

  void updateNPCAffection(int changeAmount, String reason) {
    if (state == null) return;
    state = _service.updateNPCAffection(state!, changeAmount, reason);
  }

  void updatePlayerAffection(int changeAmount, String reason) {
    if (state == null) return;
    state = _service.updatePlayerAffection(state!, changeAmount, reason);
  }

  void unlockSpecialDialogue(String dialogueId) {
    if (state == null) return;
    state = _service.unlockSpecialDialogue(state!, dialogueId);
  }

  void achieveSpecialEvent(String eventId) {
    if (state == null) return;
    state!.achieveSpecialEvent(eventId);
    state = state!.copyWith(
      updatedAt: DateTime.now(),
    );
  }

  void reset() {
    _initialize();
  }
}

/// 関係ステータスプロバイダー
final relationshipStatusProvider =
    Provider.family<RelationshipStatus?, String>((ref, npcId) {
  final relationship = ref.watch(npcRelationshipProvider(npcId));
  return relationship?.getStatus();
});

/// 親密度スコアプロバイダー
final affectionScoreProvider =
    Provider.family<int, String>((ref, npcId) {
  final relationship = ref.watch(npcRelationshipProvider(npcId));
  return relationship?.affectionScore ?? 0;
});

/// アンロック済みダイアログプロバイダー
final unlockedDialoguesProvider =
    Provider.family<List<String>, String>((ref, npcId) {
  final relationship = ref.watch(npcRelationshipProvider(npcId));
  return relationship?.unlockedDialogues ?? [];
});

/// 関係サマリープロバイダー
final relationshipSummaryProvider =
    Provider.family<RelationshipSummary?, String>((ref, npcId) {
  final relationship = ref.watch(npcRelationshipProvider(npcId));
  if (relationship == null) return null;

  final service = ref.watch(npcRelationshipServiceProvider);
  return service.generateRelationshipSummary(relationship);
});
