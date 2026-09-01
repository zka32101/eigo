/// 広告システムのモデル

class AdPlacement {
  final String id;
  final String adUnitId; // AdMob Unit ID
  final String placement; // 広告を表示する場所: home, lesson, result, shop
  final String adType; // banner, interstitial, rewarded
  final bool isActive; // 広告を表示するか

  const AdPlacement({
    required this.id,
    required this.adUnitId,
    required this.placement,
    required this.adType,
    required this.isActive,
  });

  factory AdPlacement.fromJson(Map<String, dynamic> json) {
    return AdPlacement(
      id: json['id'] as String,
      adUnitId: json['adUnitId'] as String,
      placement: json['placement'] as String,
      adType: json['adType'] as String,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'adUnitId': adUnitId,
    'placement': placement,
    'adType': adType,
    'isActive': isActive,
  };
}

/// 広告報酬オプション
class AdReward {
  final String type; // coins, xp, hint, boost
  final int amount; // 報酬量
  final String description;

  const AdReward({
    required this.type,
    required this.amount,
    required this.description,
  });

  factory AdReward.fromJson(Map<String, dynamic> json) {
    return AdReward(
      type: json['type'] as String,
      amount: json['amount'] as int,
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'amount': amount,
    'description': description,
  };
}

/// 広告表示回数と報酬情報
class AdViewRecord {
  final String adUnitId;
  final DateTime viewedAt;
  final bool wasRewarded;
  final AdReward? reward;

  const AdViewRecord({
    required this.adUnitId,
    required this.viewedAt,
    required this.wasRewarded,
    this.reward,
  });

  factory AdViewRecord.fromJson(Map<String, dynamic> json) {
    return AdViewRecord(
      adUnitId: json['adUnitId'] as String,
      viewedAt: DateTime.parse(json['viewedAt'] as String),
      wasRewarded: json['wasRewarded'] as bool? ?? false,
      reward: json['reward'] != null
          ? AdReward.fromJson(json['reward'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'adUnitId': adUnitId,
    'viewedAt': viewedAt.toIso8601String(),
    'wasRewarded': wasRewarded,
    'reward': reward?.toJson(),
  };
}

/// 広告表示制限設定
class AdLimits {
  final int maxDailyAds; // 1日の最大広告表示回数
  final int maxAdsPerPlacement; // 1つの場所での最大表示回数
  final Duration minIntervalBetweenAds; // 最小表示間隔

  const AdLimits({
    this.maxDailyAds = 10,
    this.maxAdsPerPlacement = 3,
    this.minIntervalBetweenAds = const Duration(minutes: 2),
  });

  factory AdLimits.fromJson(Map<String, dynamic> json) {
    return AdLimits(
      maxDailyAds: json['maxDailyAds'] as int? ?? 10,
      maxAdsPerPlacement: json['maxAdsPerPlacement'] as int? ?? 3,
      minIntervalBetweenAds: Duration(
        minutes: json['minIntervalBetweenAdsMinutes'] as int? ?? 2,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'maxDailyAds': maxDailyAds,
    'maxAdsPerPlacement': maxAdsPerPlacement,
    'minIntervalBetweenAdsMinutes': minIntervalBetweenAds.inMinutes,
  };
}

/// 広告配置設定（デフォルト）
final List<AdPlacement> defaultAdPlacements = [
  AdPlacement(
    id: 'ad_001',
    adUnitId: 'ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx', // iOS Banner
    placement: 'home',
    adType: 'banner',
    isActive: true,
  ),
  AdPlacement(
    id: 'ad_002',
    adUnitId: 'ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx', // Android Banner
    placement: 'home',
    adType: 'banner',
    isActive: true,
  ),
  AdPlacement(
    id: 'ad_003',
    adUnitId: 'ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx', // iOS Interstitial
    placement: 'lesson',
    adType: 'interstitial',
    isActive: true,
  ),
  AdPlacement(
    id: 'ad_004',
    adUnitId: 'ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx', // iOS Rewarded
    placement: 'result',
    adType: 'rewarded',
    isActive: true,
  ),
];

/// 報酬広告の設定
final Map<String, AdReward> rewardedAdRewards = {
  'coins': const AdReward(
    type: 'coins',
    amount: 50,
    description: '50コインを獲得',
  ),
  'xp': const AdReward(
    type: 'xp',
    amount: 100,
    description: '100経験値を獲得',
  ),
  'hint': const AdReward(
    type: 'hint',
    amount: 1,
    description: 'ヒントを1つ獲得',
  ),
};
