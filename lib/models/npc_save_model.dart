import 'package:json_annotation/json_annotation.dart';
import 'package:eigo/models/npc_behavior_model.dart';
import 'package:eigo/models/npc_dialogue_model.dart';
import 'package:eigo/models/npc_event_model.dart';

part 'npc_save_model.g.dart';

/// セーブされた NPC 状態
@JsonSerializable()
class SavedNPCState {
  /// NPC ID
  final String npcId;

  /// NPC 名
  final String npcName;

  /// 性格特性
  final PersonalityTraits personalityTraits;

  /// 現在の親密度
  final int currentAffection;

  /// 現在のムード
  final NPCMood currentMood;

  /// 記憶された相互作用
  final List<MemorizedInteraction> memorizedInteractions;

  /// 実行された行動
  final List<ExecutedBehavior> executedBehaviors;

  /// 習慣
  final List<Habit> habits;

  /// 好まれるトピック
  final List<String> preferredTopics;

  /// 嫌われるトピック
  final List<String> dislikedTopics;

  /// セーブ日時
  final DateTime savedAt;

  /// ゲーム内経過時間
  final Duration gameElapsedTime;

  /// 最後の相互作用日時
  final DateTime? lastInteractionAt;

  /// ストーリーフラグ
  final Map<String, bool>? storyFlags;

  SavedNPCState({
    required this.npcId,
    required this.npcName,
    required this.personalityTraits,
    required this.currentAffection,
    required this.currentMood,
    required this.memorizedInteractions,
    required this.executedBehaviors,
    required this.habits,
    required this.preferredTopics,
    required this.dislikedTopics,
    required this.savedAt,
    required this.gameElapsedTime,
    this.lastInteractionAt,
    this.storyFlags,
  });

  factory SavedNPCState.fromJson(Map<String, dynamic> json) =>
      _$SavedNPCStateFromJson(json);

  Map<String, dynamic> toJson() => _$SavedNPCStateToJson(this);

  /// コピー関数
  SavedNPCState copyWith({
    String? npcId,
    String? npcName,
    PersonalityTraits? personalityTraits,
    int? currentAffection,
    NPCMood? currentMood,
    List<MemorizedInteraction>? memorizedInteractions,
    List<ExecutedBehavior>? executedBehaviors,
    List<Habit>? habits,
    List<String>? preferredTopics,
    List<String>? dislikedTopics,
    DateTime? savedAt,
    Duration? gameElapsedTime,
    DateTime? lastInteractionAt,
    Map<String, bool>? storyFlags,
  }) {
    return SavedNPCState(
      npcId: npcId ?? this.npcId,
      npcName: npcName ?? this.npcName,
      personalityTraits: personalityTraits ?? this.personalityTraits,
      currentAffection: currentAffection ?? this.currentAffection,
      currentMood: currentMood ?? this.currentMood,
      memorizedInteractions: memorizedInteractions ?? this.memorizedInteractions,
      executedBehaviors: executedBehaviors ?? this.executedBehaviors,
      habits: habits ?? this.habits,
      preferredTopics: preferredTopics ?? this.preferredTopics,
      dislikedTopics: dislikedTopics ?? this.dislikedTopics,
      savedAt: savedAt ?? this.savedAt,
      gameElapsedTime: gameElapsedTime ?? this.gameElapsedTime,
      lastInteractionAt: lastInteractionAt ?? this.lastInteractionAt,
      storyFlags: storyFlags ?? this.storyFlags,
    );
  }
}

/// ゲームセーブデータ
@JsonSerializable()
class SaveGameData {
  /// セーブファイル ID
  final String saveId;

  /// セーブファイル名
  final String saveName;

  /// プレイヤーレベル
  final int playerLevel;

  /// プレイヤー経験値
  final int playerExperience;

  /// プレイ時間（ゲーム内）
  final Duration gamePlayedTime;

  /// 現在地
  final String? currentLocation;

  /// セーブされたすべての NPC 状態
  final Map<String, SavedNPCState> npcStates;

  /// ストーリー進度フラグ
  final Map<String, bool> storyProgression;

  /// 完了したクエスト
  final List<String> completedQuests;

  /// 現在のクエスト
  final List<String> activeQuests;

  /// 所持アイテム
  final Map<String, int> inventory;

  /// 所持ゴール
  final int gold;

  /// セーブ日時
  final DateTime savedAt;

  /// 最後にプレイした日時
  final DateTime lastPlayedAt;

  /// ゲームバージョン
  final String gameVersion;

  SaveGameData({
    required this.saveId,
    required this.saveName,
    required this.playerLevel,
    required this.playerExperience,
    required this.gamePlayedTime,
    this.currentLocation,
    required this.npcStates,
    required this.storyProgression,
    required this.completedQuests,
    required this.activeQuests,
    required this.inventory,
    required this.gold,
    required this.savedAt,
    required this.lastPlayedAt,
    required this.gameVersion,
  });

  factory SaveGameData.fromJson(Map<String, dynamic> json) =>
      _$SaveGameDataFromJson(json);

  Map<String, dynamic> toJson() => _$SaveGameDataToJson(this);

  /// コピー関数
  SaveGameData copyWith({
    String? saveId,
    String? saveName,
    int? playerLevel,
    int? playerExperience,
    Duration? gamePlayedTime,
    String? currentLocation,
    Map<String, SavedNPCState>? npcStates,
    Map<String, bool>? storyProgression,
    List<String>? completedQuests,
    List<String>? activeQuests,
    Map<String, int>? inventory,
    int? gold,
    DateTime? savedAt,
    DateTime? lastPlayedAt,
    String? gameVersion,
  }) {
    return SaveGameData(
      saveId: saveId ?? this.saveId,
      saveName: saveName ?? this.saveName,
      playerLevel: playerLevel ?? this.playerLevel,
      playerExperience: playerExperience ?? this.playerExperience,
      gamePlayedTime: gamePlayedTime ?? this.gamePlayedTime,
      currentLocation: currentLocation ?? this.currentLocation,
      npcStates: npcStates ?? this.npcStates,
      storyProgression: storyProgression ?? this.storyProgression,
      completedQuests: completedQuests ?? this.completedQuests,
      activeQuests: activeQuests ?? this.activeQuests,
      inventory: inventory ?? this.inventory,
      gold: gold ?? this.gold,
      savedAt: savedAt ?? this.savedAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      gameVersion: gameVersion ?? this.gameVersion,
    );
  }
}

/// セーブファイルメタデータ
@JsonSerializable()
class SaveMetadata {
  /// セーブファイル ID
  final String saveId;

  /// セーブファイル名
  final String saveName;

  /// セーブ日時
  final DateTime savedAt;

  /// 最後にプレイした日時
  final DateTime lastPlayedAt;

  /// プレイヤーレベル
  final int playerLevel;

  /// ゲーム内プレイ時間
  final Duration gamePlayedTime;

  /// 現在地
  final String? currentLocation;

  /// ファイルサイズ（バイト）
  final int fileSizeBytes;

  SaveMetadata({
    required this.saveId,
    required this.saveName,
    required this.savedAt,
    required this.lastPlayedAt,
    required this.playerLevel,
    required this.gamePlayedTime,
    this.currentLocation,
    required this.fileSizeBytes,
  });

  factory SaveMetadata.fromJson(Map<String, dynamic> json) =>
      _$SaveMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$SaveMetadataToJson(this);
}

/// セーブ操作結果
enum SaveResult {
  success,
  fileError,
  serializationError,
  permissionDenied,
  unknown,
}

/// ロード操作結果
enum LoadResult {
  success,
  fileNotFound,
  deserializationError,
  versionMismatch,
  permissionDenied,
  unknown,
}

/// セーブスロット情報
@JsonSerializable()
class SaveSlot {
  /// スロット番号（1-3）
  final int slotNumber;

  /// セーブメタデータ
  final SaveMetadata? metadata;

  /// スロットが使用中か
  final bool isUsed;

  SaveSlot({
    required this.slotNumber,
    this.metadata,
    required this.isUsed,
  });

  factory SaveSlot.fromJson(Map<String, dynamic> json) =>
      _$SaveSlotFromJson(json);

  Map<String, dynamic> toJson() => _$SaveSlotToJson(this);
}
