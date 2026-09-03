import 'package:json_annotation/json_annotation.dart';

part 'english_town_model.g.dart';

/// 町のエリアタイプ
enum TownAreaType {
  school(
    '🏫 学校',
    'School',
    'Learn classroom and educational phrases',
    1,
  ),
  market(
    '🛒 市場',
    'Market',
    'Practice shopping and transaction phrases',
    2,
  ),
  park(
    '🌳 公園',
    'Park',
    'Learn outdoor and activity phrases',
    2,
  ),
  restaurant(
    '🍽️ レストラン',
    'Restaurant',
    'Practice dining and food-related conversations',
    3,
  ),
  library(
    '📚 図書館',
    'Library',
    'Learn academic and research-related phrases',
    3,
  ),
  hospital(
    '🏥 病院',
    'Hospital',
    'Practice health and emergency phrases',
    3,
  ),
  station(
    '🚉 駅',
    'Station',
    'Learn transportation and travel phrases',
    4,
  ),
  beach(
    '🏖️ ビーチ',
    'Beach',
    'Practice vacation and leisure conversations',
    4,
  );

  final String displayName;
  final String englishName;
  final String description;
  final int difficulty;

  const TownAreaType(
    this.displayName,
    this.englishName,
    this.description,
    this.difficulty,
  );
}

/// NPC（ノンプレイヤーキャラクター）の職業
enum NPCProfession {
  teacher('先生', 'Teacher'),
  shopkeeper('店員', 'Shopkeeper'),
  doctor('医者', 'Doctor'),
  chef('シェフ', 'Chef'),
  librarian('図書館員', 'Librarian'),
  tourist('旅行者', 'Tourist'),
  student('学生', 'Student'),
  parent('親', 'Parent');

  final String japanese;
  final String english;

  const NPCProfession(this.japanese, this.english);
}

/// NPC（ノンプレイヤーキャラクター）
@JsonSerializable()
class NPC {
  /// NPC ID
  final String npcId;

  /// NPC名
  final String name;

  /// NPC職業
  final String profession; // "teacher", "shopkeeper", etc.

  /// エモジキャラクター
  final String emoji;

  /// エリアID
  final String areaId;

  /// NPCの初期位置 (x, y座標)
  final String position; // "x:100,y:200"

  /// NPCとの会話フレーズ
  final List<String> conversationPhrases;

  /// NPCの学習テーマ
  final String learningTheme;

  /// NPCレベル（難易度）
  final int difficultyLevel;

  /// NPCが学習した単語数
  final int vocabularyCount;

  /// NPCとの総会話回数
  final int talkCount;

  /// 最後に会話した日時
  final DateTime? lastTalkedAt;

  NPC({
    required this.npcId,
    required this.name,
    required this.profession,
    required this.emoji,
    required this.areaId,
    required this.position,
    required this.conversationPhrases,
    required this.learningTheme,
    required this.difficultyLevel,
    required this.vocabularyCount,
    required this.talkCount,
    this.lastTalkedAt,
  });

  factory NPC.fromJson(Map<String, dynamic> json) => _$NPCFromJson(json);

  Map<String, dynamic> toJson() => _$NPCToJson(this);
}

/// タウンエリア
@JsonSerializable()
class TownArea {
  /// エリアID
  final String areaId;

  /// エリアタイプ
  final String areaType; // "school", "market", "park", etc.

  /// エリア名（英語）
  final String englishName;

  /// エリア名（日本語）
  final String japaneseName;

  /// エリア説明
  final String description;

  /// エリアの背景画像URL/タイル
  final String backgroundTile;

  /// エリアに居るNPCのリスト
  final List<String> npcIds; // NPC IDのリスト

  /// このエリアで学習できる主なテーマ
  final List<String> learningThemes;

  /// エリアの難易度
  final int difficultyLevel;

  /// エリアにおけるユーザーの進捗（0-100）
  final int progressPercentage;

  /// ユーザーがこのエリアで学習した単語数
  final int wordsLearned;

  /// ユーザーがこのエリアで獲得したコイン
  final int coinsEarned;

  /// エリアのアンロック状態
  final bool isUnlocked;

  /// 最初に訪れた日時
  final DateTime? firstVisitedAt;

  /// 最後に訪れた日時
  final DateTime? lastVisitedAt;

  TownArea({
    required this.areaId,
    required this.areaType,
    required this.englishName,
    required this.japaneseName,
    required this.description,
    required this.backgroundTile,
    required this.npcIds,
    required this.learningThemes,
    required this.difficultyLevel,
    required this.progressPercentage,
    required this.wordsLearned,
    required this.coinsEarned,
    required this.isUnlocked,
    this.firstVisitedAt,
    this.lastVisitedAt,
  });

  factory TownArea.fromJson(Map<String, dynamic> json) =>
      _$TownAreaFromJson(json);

  Map<String, dynamic> toJson() => _$TownAreaToJson(this);
}

/// NPCとの会話
@JsonSerializable()
class Conversation {
  /// 会話ID
  final String conversationId;

  /// ユーザーID
  final String userId;

  /// NPC ID
  final String npcId;

  /// エリアID
  final String areaId;

  /// NPCが言ったフレーズ
  final String npcPhrase;

  /// NPCフレーズの日本語訳
  final String npcPhraseTranslation;

  /// ユーザーの応答（音声→テキスト化）
  final String? userResponse;

  /// ユーザーの応答が正しいか
  final bool isResponseCorrect;

  /// 応答スコア（0-100）
  final int responseScore;

  /// 会話時の学習ポイント
  final int learningPoints;

  /// 会話時の獲得コイン
  final int coinsEarned;

  /// 会話日時
  final DateTime conversationAt;

  Conversation({
    required this.conversationId,
    required this.userId,
    required this.npcId,
    required this.areaId,
    required this.npcPhrase,
    required this.npcPhraseTranslation,
    this.userResponse,
    required this.isResponseCorrect,
    required this.responseScore,
    required this.learningPoints,
    required this.coinsEarned,
    required this.conversationAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationToJson(this);
}

/// ユーザーの町での進捗
@JsonSerializable()
class TownProgress {
  /// 進捗ID
  final String progressId;

  /// ユーザーID
  final String userId;

  /// 総エリア数
  final int totalAreas;

  /// アンロック済みエリア数
  final int unlockedAreas;

  /// 訪問済みエリア数
  final int visitedAreas;

  /// 総会話数
  final int totalConversations;

  /// 正解会話数
  final int correctConversations;

  /// 平均スコア（0-100）
  final double averageScore;

  /// 総獲得ポイント
  final int totalLearningPoints;

  /// 総獲得コイン
  final int totalCoinsEarned;

  /// 現在のエリアID
  final String? currentAreaId;

  /// 現在のNPC ID
  final String? currentNPCId;

  /// 最初に町を訪れた日時
  final DateTime? firstVisitedAt;

  /// 最後に町を訪れた日時
  final DateTime? lastVisitedAt;

  /// 最終更新日時
  final DateTime lastUpdatedAt;

  TownProgress({
    required this.progressId,
    required this.userId,
    required this.totalAreas,
    required this.unlockedAreas,
    required this.visitedAreas,
    required this.totalConversations,
    required this.correctConversations,
    required this.averageScore,
    required this.totalLearningPoints,
    required this.totalCoinsEarned,
    this.currentAreaId,
    this.currentNPCId,
    this.firstVisitedAt,
    this.lastVisitedAt,
    required this.lastUpdatedAt,
  });

  factory TownProgress.fromJson(Map<String, dynamic> json) =>
      _$TownProgressFromJson(json);

  Map<String, dynamic> toJson() => _$TownProgressToJson(this);
}

/// ユーザープロフィール（町内）
@JsonSerializable()
class TownPlayerProfile {
  /// プロフィールID
  final String profileId;

  /// ユーザーID
  final String userId;

  /// プレイヤーのキャラクター（使用するエモジ）
  final String playerCharacter; // 🧒, 👦, 👧

  /// 現在のレベル
  final int level;

  /// 現在の経験値
  final int experience;

  /// 総獲得コイン
  final int totalCoinsEarned;

  /// 現在のコイン
  final int currentCoins;

  /// 学習したユニークな単語数
  final int uniqueWordsLearned;

  /// 親友NPCのID
  final String? bestFriendNPCId;

  /// 達成したマイルストーン
  final List<String> milestonesClaimed;

  /// バッジコレクション
  final List<String> badgesEarned;

  /// 最終更新日時
  final DateTime lastUpdatedAt;

  TownPlayerProfile({
    required this.profileId,
    required this.userId,
    required this.playerCharacter,
    required this.level,
    required this.experience,
    required this.totalCoinsEarned,
    required this.currentCoins,
    required this.uniqueWordsLearned,
    this.bestFriendNPCId,
    required this.milestonesClaimed,
    required this.badgesEarned,
    required this.lastUpdatedAt,
  });

  factory TownPlayerProfile.fromJson(Map<String, dynamic> json) =>
      _$TownPlayerProfileFromJson(json);

  Map<String, dynamic> toJson() => _$TownPlayerProfileToJson(this);
}

/// 町の統計
@JsonSerializable()
class TownStats {
  /// 統計ID
  final String statsId;

  /// ユーザーID
  final String userId;

  /// 総訪問時間（分）
  final int totalPlayTime;

  /// 総会話数
  final int totalConversations;

  /// 平均スコア（0-100）
  final double averageScore;

  /// 高スコア（0-100）
  final int highScore;

  /// 訪問日数
  final int visitDays;

  /// 連続訪問日数
  final int consecutiveVisitDays;

  /// 最も訪問したエリア
  final String? mostVisitedArea;

  /// 最も会話したNPC
  final String? mostTalkedNPC;

  /// 学習した総単語数
  final int totalWordsLearned;

  /// 獲得した総コイン
  final int totalCoinsEarned;

  /// 獲得したバッジ数
  final int badgesCount;

  /// 達成したマイルストーン数
  final int milestonesCount;

  /// 最終更新日時
  final DateTime lastUpdatedAt;

  TownStats({
    required this.statsId,
    required this.userId,
    required this.totalPlayTime,
    required this.totalConversations,
    required this.averageScore,
    required this.highScore,
    required this.visitDays,
    required this.consecutiveVisitDays,
    this.mostVisitedArea,
    this.mostTalkedNPC,
    required this.totalWordsLearned,
    required this.totalCoinsEarned,
    required this.badgesCount,
    required this.milestonesCount,
    required this.lastUpdatedAt,
  });

  factory TownStats.fromJson(Map<String, dynamic> json) =>
      _$TownStatsFromJson(json);

  Map<String, dynamic> toJson() => _$TownStatsToJson(this);
}
