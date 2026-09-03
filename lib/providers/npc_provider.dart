import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eigo/models/npc_extended_model.dart';
import 'package:eigo/providers/npc_firebase_provider.dart';

/// ==================== NPC EXTENDED DATA STATE ====================

/// NPC拡張データを管理するStateNotifier
class NPCsNotifier extends StateNotifier<List<NPCExtended>> {
  NPCsNotifier(this._firebaseService) : super([]) {
    _initializeNPCs();
  }

  final NPCFirebaseService _firebaseService;

  /// NPCデータを初期化
  Future<void> _initializeNPCs() async {
    try {
      final npcs = await _firebaseService.getAllNPCExtended();
      state = npcs;
    } catch (e) {
      print('Error initializing NPCs: $e');
      state = [];
    }
  }

  /// NPCの拡張データを保存
  Future<void> saveNPC(NPCExtended npc) async {
    try {
      await _firebaseService.saveNPCExtended(npc);
      state = [
        ...state.where((n) => n.npcId != npc.npcId),
        npc,
      ];
    } catch (e) {
      print('Error saving NPC: $e');
      rethrow;
    }
  }

  /// NPCの気分を更新
  Future<void> updateNPCMood(String npcId, String moodState) async {
    try {
      await _firebaseService.updateNPCMood(npcId, moodState);
      state = state.map((npc) {
        if (npc.npcId == npcId) {
          return npc.copyWith(
            currentMoodState: moodState,
            moodLastUpdatedAt: DateTime.now(),
          );
        }
        return npc;
      }).toList();
    } catch (e) {
      print('Error updating NPC mood: $e');
      rethrow;
    }
  }

  /// NPCの利用可能性スケジュールを更新
  Future<void> updateNPCAvailability(
    String npcId,
    NPCAvailabilitySchedule schedule,
  ) async {
    try {
      await _firebaseService.updateNPCAvailability(npcId, schedule);
      state = state.map((npc) {
        if (npc.npcId == npcId) {
          return npc.copyWith(availabilitySchedule: schedule);
        }
        return npc;
      }).toList();
    } catch (e) {
      print('Error updating NPC availability: $e');
      rethrow;
    }
  }

  /// NPCデータをリロード
  Future<void> reloadNPCs() async {
    await _initializeNPCs();
  }
}

/// NPC拡張データプロバイダー
final npcsProvider =
    StateNotifierProvider<NPCsNotifier, List<NPCExtended>>((ref) {
  final firebaseService = ref.watch(npcFirebaseServiceProvider);
  return NPCsNotifier(firebaseService);
});

/// IDでNPC詳細を取得
final npcByIdProvider = Provider.family<NPCExtended?, String>((ref, npcId) {
  final npcs = ref.watch(npcsProvider);
  try {
    return npcs.firstWhere((npc) => npc.npcId == npcId);
  } catch (e) {
    return null;
  }
});

/// 特定の気分のNPCをフィルタリング
final npcsByMoodProvider =
    Provider.family<List<NPCExtended>, String>((ref, moodState) {
  final npcs = ref.watch(npcsProvider);
  return npcs.where((npc) => npc.currentMoodState == moodState).toList();
});

/// 現在利用可能なNPCをフィルタリング
final availableNPCsProvider = Provider<List<NPCExtended>>((ref) {
  final npcs = ref.watch(npcsProvider);
  return npcs.where((npc) => npc.availabilitySchedule.isCurrentlyAvailable()).toList();
});

/// インタラクション能力でソートされたNPCリスト
final npcsByInteractionCapabilityProvider = Provider<List<NPCExtended>>((ref) {
  final npcs = ref.watch(npcsProvider);
  return npcs.toList()
    ..sort((a, b) => b.interactionCapability.compareTo(a.interactionCapability));
});

/// 学習率でソートされたNPCリスト
final npcsByLearningRateProvider = Provider<List<NPCExtended>>((ref) {
  final npcs = ref.watch(npcsProvider);
  return npcs.toList()
    ..sort((a, b) => b.learningRate.compareTo(a.learningRate));
});
