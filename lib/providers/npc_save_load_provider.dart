import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eigo/models/npc_save_model.dart';
import 'package:eigo/services/npc_save_load_service.dart';

/// NPC セーブ/ロードサービス
final npcSaveLoadServiceProvider = Provider((ref) {
  return NPCSaveLoadService.getInstance();
});

/// 保存済みセーブスロット
final saveSlotListProvider = FutureProvider<List<SaveSlot>>((ref) async {
  final service = ref.watch(npcSaveLoadServiceProvider);
  return service.getSaveSlots();
});

/// ゲームセーブデータ
final saveGameDataProvider =
    FutureProvider.family<SaveGameData?, String>((ref, saveId) async {
  final service = ref.watch(npcSaveLoadServiceProvider);
  final (result, data) = await service.loadGame(saveId);
  if (result == LoadResult.success) {
    return data;
  }
  return null;
});

/// セーブファイルサイズ
final saveFileSizeProvider =
    FutureProvider.family<int?, String>((ref, saveId) async {
  final service = ref.watch(npcSaveLoadServiceProvider);
  return service.getSaveFileSize(saveId);
});

/// セーブゲーム状態 Notifier
final saveGameNotifierProvider =
    StateNotifierProvider.family<SaveGameNotifier, AsyncValue<void>, String>(
  (ref, saveId) {
    final service = ref.watch(npcSaveLoadServiceProvider);
    return SaveGameNotifier(
      service: service,
      saveId: saveId,
    );
  },
);

class SaveGameNotifier extends StateNotifier<AsyncValue<void>> {
  final NPCSaveLoadService service;
  final String saveId;

  SaveGameNotifier({
    required this.service,
    required this.saveId,
  }) : super(const AsyncValue.data(null));

  /// ゲーム状態を保存
  Future<SaveResult> saveGame(SaveGameData gameData) async {
    state = const AsyncValue.loading();
    final result = await service.saveGame(gameData);
    if (result == SaveResult.success) {
      state = const AsyncValue.data(null);
    } else {
      state = AsyncValue.error(result.toString(), StackTrace.current);
    }
    return result;
  }

  /// ゲーム状態を読み込む
  Future<(LoadResult, SaveGameData?)> loadGame() async {
    state = const AsyncValue.loading();
    final (result, data) = await service.loadGame(saveId);
    if (result == LoadResult.success) {
      state = const AsyncValue.data(null);
    } else {
      state = AsyncValue.error(result.toString(), StackTrace.current);
    }
    return (result, data);
  }

  /// NPC 状態を保存
  Future<SaveResult> saveNPCState(
    String npcId,
    SavedNPCState npcState,
  ) async {
    state = const AsyncValue.loading();
    final result = await service.saveNPCState(saveId, npcId, npcState);
    if (result == SaveResult.success) {
      state = const AsyncValue.data(null);
    } else {
      state = AsyncValue.error(result.toString(), StackTrace.current);
    }
    return result;
  }

  /// バックアップを作成
  Future<SaveResult> createBackup() async {
    return service.createBackup(saveId);
  }

  /// バックアップから復元
  Future<SaveResult> restoreFromBackup() async {
    state = const AsyncValue.loading();
    final result = await service.restoreFromBackup(saveId);
    if (result == SaveResult.success) {
      state = const AsyncValue.data(null);
    } else {
      state = AsyncValue.error(result.toString(), StackTrace.current);
    }
    return result;
  }

  /// セーブをクリア
  Future<SaveResult> clearSave() async {
    state = const AsyncValue.loading();
    final result = await service.clearSaveSlot(saveId);
    state = const AsyncValue.data(null);
    return result;
  }
}

/// セーブスロット管理 Notifier
final saveSlotManagerProvider = StateNotifierProvider<SaveSlotManager, void>(
  (ref) {
    final service = ref.watch(npcSaveLoadServiceProvider);
    return SaveSlotManager(service: service);
  },
);

class SaveSlotManager extends StateNotifier<void> {
  final NPCSaveLoadService service;

  SaveSlotManager({required this.service}) : super(null);

  /// セーブスロットをクリア
  Future<SaveResult> clearSlot(String saveId) async {
    final result = await service.clearSaveSlot(saveId);
    state = null; // 状態を更新して UI に通知
    return result;
  }

  /// すべてのセーブをリセット
  Future<SaveResult> resetAllSaves() async {
    final result = await service.resetAllSaves();
    state = null;
    return result;
  }

  /// キャッシュをクリア
  void clearCache() {
    service.clearCache();
    state = null;
  }

  /// キャッシュをクリア（特定のセーブ）
  void clearCacheForSave(String saveId) {
    service.clearCacheForSave(saveId);
    state = null;
  }
}
