import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:eigo/models/npc_save_model.dart';
import 'package:eigo/models/npc_behavior_model.dart';

const String _gameVersion = '1.0.0';
const int _maxSaveSlots = 3;

/// NPC セーブ/ロードサービス
class NPCSaveLoadService {
  static final NPCSaveLoadService _instance = NPCSaveLoadService._internal();

  factory NPCSaveLoadService.getInstance() {
    return _instance;
  }

  NPCSaveLoadService._internal();

  // キャッシュ
  final Map<String, SaveGameData> _saveCache = {};

  /// アプリケーションドキュメントディレクトリを取得
  Future<Directory> _getApplicationDocumentsDirectory() async {
    return getApplicationDocumentsDirectory();
  }

  /// セーブディレクトリを取得
  Future<Directory> _getSaveDirectory() async {
    final appDir = await _getApplicationDocumentsDirectory();
    final saveDir = Directory('${appDir.path}/saves');
    if (!await saveDir.exists()) {
      await saveDir.create(recursive: true);
    }
    return saveDir;
  }

  /// セーブファイルパスを取得
  Future<String> _getSaveFilePath(String saveId) async {
    final saveDir = await _getSaveDirectory();
    return '${saveDir.path}/$saveId.json';
  }

  /// メタデータファイルパスを取得
  Future<String> _getMetadataFilePath(String saveId) async {
    final saveDir = await _getSaveDirectory();
    return '${saveDir.path}/$saveId.meta.json';
  }

  /// ゲーム状態を保存
  Future<SaveResult> saveGame(SaveGameData gameData) async {
    try {
      // キャッシュに追加
      _saveCache[gameData.saveId] = gameData;

      // ファイルパスを取得
      final filePath = await _getSaveFilePath(gameData.saveId);
      final metadataPath = await _getMetadataFilePath(gameData.saveId);

      // メインデータを保存
      final jsonString = jsonEncode(gameData.toJson());
      final file = File(filePath);
      await file.writeAsString(jsonString);

      // メタデータを保存
      final metadata = SaveMetadata(
        saveId: gameData.saveId,
        saveName: gameData.saveName,
        savedAt: gameData.savedAt,
        lastPlayedAt: gameData.lastPlayedAt,
        playerLevel: gameData.playerLevel,
        gamePlayedTime: gameData.gamePlayedTime,
        currentLocation: gameData.currentLocation,
        fileSizeBytes: jsonString.length,
      );

      final metadataJsonString = jsonEncode(metadata.toJson());
      final metadataFile = File(metadataPath);
      await metadataFile.writeAsString(metadataJsonString);

      return SaveResult.success;
    } on PermissionDeniedException {
      return SaveResult.permissionDenied;
    } on FileSystemException {
      return SaveResult.fileError;
    } catch (e) {
      return SaveResult.unknown;
    }
  }

  /// ゲーム状態を読み込む
  Future<(LoadResult, SaveGameData?)> loadGame(String saveId) async {
    try {
      // キャッシュから確認
      if (_saveCache.containsKey(saveId)) {
        return (LoadResult.success, _saveCache[saveId]);
      }

      final filePath = await _getSaveFilePath(saveId);
      final file = File(filePath);

      if (!await file.exists()) {
        return (LoadResult.fileNotFound, null);
      }

      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final gameData = SaveGameData.fromJson(jsonData);

      // キャッシュに追加
      _saveCache[saveId] = gameData;

      // バージョン確認
      if (gameData.gameVersion != _gameVersion) {
        return (LoadResult.versionMismatch, null);
      }

      return (LoadResult.success, gameData);
    } on FormatException {
      return (LoadResult.deserializationError, null);
    } on PermissionDeniedException {
      return (LoadResult.permissionDenied, null);
    } catch (e) {
      return (LoadResult.unknown, null);
    }
  }

  /// NPC 状態を保存
  Future<SaveResult> saveNPCState(
    String saveId,
    String npcId,
    SavedNPCState npcState,
  ) async {
    try {
      final filePath = await _getSaveFilePath(saveId);
      final file = File(filePath);

      if (!await file.exists()) {
        return SaveResult.fileNotFound;
      }

      // 既存のゲーム状態を読み込む
      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final gameData = SaveGameData.fromJson(jsonData);

      // NPC 状態を更新
      final updatedNpcStates = {
        ...gameData.npcStates,
        npcId: npcState,
      };

      final updatedGameData = gameData.copyWith(
        npcStates: updatedNpcStates,
        lastPlayedAt: DateTime.now(),
      );

      // キャッシュを更新
      _saveCache[saveId] = updatedGameData;

      // ファイルに保存
      final updatedJsonString = jsonEncode(updatedGameData.toJson());
      await file.writeAsString(updatedJsonString);

      return SaveResult.success;
    } catch (e) {
      return SaveResult.unknown;
    }
  }

  /// 保存済みセーブスロット一覧を取得
  Future<List<SaveSlot>> getSaveSlots() async {
    try {
      final saveDir = await _getSaveDirectory();
      final slots = <SaveSlot>[];

      for (int i = 1; i <= _maxSaveSlots; i++) {
        final metadataPath = await _getMetadataFilePath('save_$i');
        final metadataFile = File(metadataPath);

        if (await metadataFile.exists()) {
          final jsonString = await metadataFile.readAsString();
          final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
          final metadata = SaveMetadata.fromJson(jsonData);

          slots.add(SaveSlot(
            slotNumber: i,
            metadata: metadata,
            isUsed: true,
          ));
        } else {
          slots.add(SaveSlot(
            slotNumber: i,
            metadata: null,
            isUsed: false,
          ));
        }
      }

      return slots;
    } catch (e) {
      return [];
    }
  }

  /// セーブスロットをクリア
  Future<SaveResult> clearSaveSlot(String saveId) async {
    try {
      final filePath = await _getSaveFilePath(saveId);
      final metadataPath = await _getMetadataFilePath(saveId);

      final file = File(filePath);
      final metadataFile = File(metadataPath);

      if (await file.exists()) {
        await file.delete();
      }
      if (await metadataFile.exists()) {
        await metadataFile.delete();
      }

      _saveCache.remove(saveId);
      return SaveResult.success;
    } catch (e) {
      return SaveResult.fileError;
    }
  }

  /// バックアップを作成
  Future<SaveResult> createBackup(String saveId) async {
    try {
      final filePath = await _getSaveFilePath(saveId);
      final backupPath = '${filePath}.backup';

      final file = File(filePath);
      if (!await file.exists()) {
        return SaveResult.fileNotFound;
      }

      await file.copy(backupPath);
      return SaveResult.success;
    } catch (e) {
      return SaveResult.fileError;
    }
  }

  /// バックアップから復元
  Future<SaveResult> restoreFromBackup(String saveId) async {
    try {
      final filePath = await _getSaveFilePath(saveId);
      final backupPath = '${filePath}.backup';

      final backupFile = File(backupPath);
      if (!await backupFile.exists()) {
        return SaveResult.fileNotFound;
      }

      await backupFile.copy(filePath);
      _saveCache.remove(saveId);
      return SaveResult.success;
    } catch (e) {
      return SaveResult.fileError;
    }
  }

  /// セーブファイルサイズを取得
  Future<int?> getSaveFileSize(String saveId) async {
    try {
      final filePath = await _getSaveFilePath(saveId);
      final file = File(filePath);

      if (await file.exists()) {
        return await file.length();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// すべてのセーブをリセット
  Future<SaveResult> resetAllSaves() async {
    try {
      final saveDir = await _getSaveDirectory();
      if (await saveDir.exists()) {
        await saveDir.delete(recursive: true);
      }
      _saveCache.clear();
      return SaveResult.success;
    } catch (e) {
      return SaveResult.fileError;
    }
  }

  /// キャッシュをクリア
  void clearCache() {
    _saveCache.clear();
  }

  /// キャッシュをクリア（特定のセーブ）
  void clearCacheForSave(String saveId) {
    _saveCache.remove(saveId);
  }
}
