import 'package:json_annotation/json_annotation.dart';

part 'passport_model.g.dart';

/// 姉妹アプリの種類
enum SisterAppType {
  eigoKore('英語コレ！', 'eigo-kore', 'English learning'),
  kokugoKore('国語コレ！', 'kokugo-kore', 'Japanese language learning'),
  sansuKore('算数コレ！', 'sansu-kore', 'Math learning');

  final String displayName;
  final String appId;
  final String description;

  const SisterAppType(this.displayName, this.appId, this.description);
}

/// ユーザーの統合プロフィール（複数アプリ共通）
@JsonSerializable()
class PassportProfile {
  /// パスポートID
  final String passportId;

  /// ユーザーID（グローバル一意）
  final String userId;

  /// ユーザー名
  final String userName;

  /// プロフィール画像URL
  final String? profileImageUrl;

  /// 総合グレード（すべてのアプリから計算）
  final int overallGrade; // 1-6（小1～小6）

  /// 登録日
  final DateTime createdAt;

  /// 最終更新日
  final DateTime lastUpdatedAt;

  /// 各アプリの接続状態
  final Map<String, bool> connectedApps; // appId: isConnected

  PassportProfile({
    required this.passportId,
    required this.userId,
    required this.userName,
    this.profileImageUrl,
    required this.overallGrade,
    required this.createdAt,
    required this.lastUpdatedAt,
    required this.connectedApps,
  });

  factory PassportProfile.fromJson(Map<String, dynamic> json) =>
      _$PassportProfileFromJson(json);

  Map<String, dynamic> toJson() => _$PassportProfileToJson(this);
}

/// アプリ別XP・バッジ統計
@JsonSerializable()
class AppStatistics {
  /// 統計ID
  final String statsId;

  /// ユーザーID
  final String userId;

  /// アプリタイプ
  final String appId;

  /// 総XP
  final int totalXP;

  /// 総レベル
  final int totalLevel;

  /// 総バッジ数
  final int totalBadges;

  /// アンロック済みバッジリスト
  final List<String> unlockedBadgeIds;

  /// 最後のプレイ日時
  final DateTime? lastPlayedAt;

  /// 連続ストリーク（日数）
  final int consecutiveStreak;

  /// 最長ストリーク（日数）
  final int longestStreak;

  /// スコア（0-100点の正規化スコア）
  final int normalizedScore;

  AppStatistics({
    required this.statsId,
    required this.userId,
    required this.appId,
    required this.totalXP,
    required this.totalLevel,
    required this.totalBadges,
    required this.unlockedBadgeIds,
    this.lastPlayedAt,
    required this.consecutiveStreak,
    required this.longestStreak,
    required this.normalizedScore,
  });

  factory AppStatistics.fromJson(Map<String, dynamic> json) =>
      _$AppStatisticsFromJson(json);

  Map<String, dynamic> toJson() => _$AppStatisticsToJson(this);
}

/// グローバルバッジ（複数アプリで共通使用可能）
@JsonSerializable()
class GlobalBadge {
  /// バッジID
  final String badgeId;

  /// バッジ名
  final String name;

  /// バッジアイコン絵文字
  final String emoji;

  /// バッジの説明
  final String description;

  /// 獲得条件
  final String criteria;

  /// バッジ獲得に必要なXP
  final int requiredXP;

  /// 対応するアプリタイプ
  final String appId;

  /// シリーズ番号（例: Season 1, Season 2）
  final int seriesNumber;

  /// レア度（1-5: Common～Legendary）
  final int rarity;

  /// 親への訴求力スコア（0.0-1.0）
  final double parentalAppeal;

  /// 公開日
  final DateTime releasedAt;

  GlobalBadge({
    required this.badgeId,
    required this.name,
    required this.emoji,
    required this.description,
    required this.criteria,
    required this.requiredXP,
    required this.appId,
    required this.seriesNumber,
    required this.rarity,
    required this.parentalAppeal,
    required this.releasedAt,
  });

  factory GlobalBadge.fromJson(Map<String, dynamic> json) =>
      _$GlobalBadgeFromJson(json);

  Map<String, dynamic> toJson() => _$GlobalBadgeToJson(this);
}

/// ユーザーのバッジ獲得履歴
@JsonSerializable()
class UserBadgeAchievement {
  /// 獲得IDユニーク識別子
  final String achievementId;

  /// ユーザーID
  final String userId;

  /// バッジID
  final String badgeId;

  /// 獲得日時
  final DateTime unlockedAt;

  /// 獲得時のアプリ
  final String acquiredFromApp;

  /// シェア状態（SNSにシェアしたか）
  final bool shared;

  /// シェア日時
  final DateTime? sharedAt;

  UserBadgeAchievement({
    required this.achievementId,
    required this.userId,
    required this.badgeId,
    required this.unlockedAt,
    required this.acquiredFromApp,
    required this.shared,
    this.sharedAt,
  });

  factory UserBadgeAchievement.fromJson(Map<String, dynamic> json) =>
      _$UserBadgeAchievementFromJson(json);

  Map<String, dynamic> toJson() => _$UserBadgeAchievementToJson(this);
}

/// クロスアプリチャレンジ
@JsonSerializable()
class CrossAppChallenge {
  /// チャレンジID
  final String challengeId;

  /// チャレンジ名
  final String name;

  /// 説明
  final String description;

  /// 対応アプリリスト
  final List<String> participatingAppIds;

  /// 条件内容（JSON形式）
  final String conditionJson;

  /// 総XP報酬
  final int totalXPReward;

  /// ボーナスバッジID
  final String? bonusBadgeId;

  /// 開始日
  final DateTime startDate;

  /// 終了日
  final DateTime endDate;

  /// 現在のスコア（リーダーボード用）
  final Map<String, int> leaderboard; // userId: score

  CrossAppChallenge({
    required this.challengeId,
    required this.name,
    required this.description,
    required this.participatingAppIds,
    required this.conditionJson,
    required this.totalXPReward,
    this.bonusBadgeId,
    required this.startDate,
    required this.endDate,
    required this.leaderboard,
  });

  factory CrossAppChallenge.fromJson(Map<String, dynamic> json) =>
      _$CrossAppChallengeFromJson(json);

  Map<String, dynamic> toJson() => _$CrossAppChallengeToJson(this);
}

/// XP同期ログ（監査・デバッグ用）
@JsonSerializable()
class XPSyncLog {
  /// ログID
  final String logId;

  /// ユーザーID
  final String userId;

  /// 送信元アプリ
  final String sourceApp;

  /// 受信アプリリスト
  final List<String> destinationApps;

  /// 同期されたXP量
  final int syncedXP;

  /// 同期時刻
  final DateTime syncedAt;

  /// ステータス（success, pending, failed）
  final String status;

  /// エラーメッセージ（失敗時）
  final String? errorMessage;

  XPSyncLog({
    required this.logId,
    required this.userId,
    required this.sourceApp,
    required this.destinationApps,
    required this.syncedXP,
    required this.syncedAt,
    required this.status,
    this.errorMessage,
  });

  factory XPSyncLog.fromJson(Map<String, dynamic> json) =>
      _$XPSyncLogFromJson(json);

  Map<String, dynamic> toJson() => _$XPSyncLogToJson(this);
}

/// パスポート通知（新規バッジ、チャレンジ達成など）
@JsonSerializable()
class PassportNotification {
  /// 通知ID
  final String notificationId;

  /// ユーザーID
  final String userId;

  /// 通知種類（badge_unlocked, challenge_completed, friend_milestone）
  final String type;

  /// タイトル
  final String title;

  /// メッセージ
  final String message;

  /// 関連アプリID
  final String relatedAppId;

  /// ペイロード（JSON）
  final Map<String, dynamic> payload;

  /// 作成日時
  final DateTime createdAt;

  /// 読了済みフラグ
  final bool isRead;

  /// 読了日時
  final DateTime? readAt;

  PassportNotification({
    required this.notificationId,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.relatedAppId,
    required this.payload,
    required this.createdAt,
    required this.isRead,
    this.readAt,
  });

  factory PassportNotification.fromJson(Map<String, dynamic> json) =>
      _$PassportNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$PassportNotificationToJson(this);
}

/// パスポート統計サマリー（ダッシュボード用）
@JsonSerializable()
class PassportSummary {
  /// サマリーID
  final String summaryId;

  /// ユーザーID
  final String userId;

  /// 総合XP（全アプリ合計）
  final int totalXP;

  /// グローバルランキング順位
  final int globalRank;

  /// 友達順位（相対順位）
  final int friendsRank;

  /// 総バッジ数
  final int totalBadgesUnlocked;

  /// 完成度（バッジ獲得率 %）
  final int completionPercentage;

  /// 最後の同期日時
  final DateTime lastSyncedAt;

  /// 前月比XP増加量
  final int monthlyXPGrowth;

  /// 各アプリ別総XP
  final Map<String, int> xpByApp; // appId: totalXP

  /// 学習時間合計（分）
  final int totalStudyMinutes;

  PassportSummary({
    required this.summaryId,
    required this.userId,
    required this.totalXP,
    required this.globalRank,
    required this.friendsRank,
    required this.totalBadgesUnlocked,
    required this.completionPercentage,
    required this.lastSyncedAt,
    required this.monthlyXPGrowth,
    required this.xpByApp,
    required this.totalStudyMinutes,
  });

  factory PassportSummary.fromJson(Map<String, dynamic> json) =>
      _$PassportSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$PassportSummaryToJson(this);
}
