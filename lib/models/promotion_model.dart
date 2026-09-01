/// クロスプロモーション・キャンペーンモデル

class PromotionalCampaign {
  final String id;
  final String title;
  final String description;
  final String imageUrl; // キャンペーン画像
  final String promotedApp; // プロモ対象アプリ名
  final String appStoreUrl; // App Store URL
  final String playStoreUrl; // Google Play Store URL
  final String category; // new_app, limited_time, seasonal, exclusive
  final DateTime startDate;
  final DateTime? endDate;
  final int priority; // 表示優先度（高い方が先に表示）
  final bool isActive;
  final bool isFeatured; // トップに表示するか
  final int viewCount; // 表示回数
  final int clickCount; // クリック回数

  const PromotionalCampaign({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.promotedApp,
    required this.appStoreUrl,
    required this.playStoreUrl,
    required this.category,
    required this.startDate,
    this.endDate,
    this.priority = 0,
    this.isActive = true,
    this.isFeatured = false,
    this.viewCount = 0,
    this.clickCount = 0,
  });

  factory PromotionalCampaign.fromJson(Map<String, dynamic> json) {
    return PromotionalCampaign(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      promotedApp: json['promotedApp'] as String,
      appStoreUrl: json['appStoreUrl'] as String,
      playStoreUrl: json['playStoreUrl'] as String,
      category: json['category'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      priority: json['priority'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      isFeatured: json['isFeatured'] as bool? ?? false,
      viewCount: json['viewCount'] as int? ?? 0,
      clickCount: json['clickCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'imageUrl': imageUrl,
    'promotedApp': promotedApp,
    'appStoreUrl': appStoreUrl,
    'playStoreUrl': playStoreUrl,
    'category': category,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'priority': priority,
    'isActive': isActive,
    'isFeatured': isFeatured,
    'viewCount': viewCount,
    'clickCount': clickCount,
  };

  bool get isExpired => endDate != null && DateTime.now().isAfter(endDate!);

  double get clickThroughRate => viewCount > 0 ? (clickCount / viewCount) * 100 : 0;

  PromotionalCampaign copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? promotedApp,
    String? appStoreUrl,
    String? playStoreUrl,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    int? priority,
    bool? isActive,
    bool? isFeatured,
    int? viewCount,
    int? clickCount,
  }) {
    return PromotionalCampaign(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      promotedApp: promotedApp ?? this.promotedApp,
      appStoreUrl: appStoreUrl ?? this.appStoreUrl,
      playStoreUrl: playStoreUrl ?? this.playStoreUrl,
      category: category ?? this.category,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      priority: priority ?? this.priority,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      viewCount: viewCount ?? this.viewCount,
      clickCount: clickCount ?? this.clickCount,
    );
  }
}

/// ユーザーのプロモーション相互作用記録
class PromotionInteraction {
  final String campaignId;
  final String campaignTitle;
  final DateTime interactedAt;
  final String interactionType; // viewed, clicked, installed
  final bool completedAction; // 最終的にアプリをインストールしたか

  const PromotionInteraction({
    required this.campaignId,
    required this.campaignTitle,
    required this.interactedAt,
    required this.interactionType,
    this.completedAction = false,
  });

  factory PromotionInteraction.fromJson(Map<String, dynamic> json) {
    return PromotionInteraction(
      campaignId: json['campaignId'] as String,
      campaignTitle: json['campaignTitle'] as String,
      interactedAt: DateTime.parse(json['interactedAt'] as String),
      interactionType: json['interactionType'] as String,
      completedAction: json['completedAction'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'campaignId': campaignId,
    'campaignTitle': campaignTitle,
    'interactedAt': interactedAt.toIso8601String(),
    'interactionType': interactionType,
    'completedAction': completedAction,
  };
}

/// プロモーション配置（どこに表示するか）
enum PromotionPlacement {
  homeScreen,
  homeBottom,
  dailyChallengeScreen,
  resultScreen,
  settingsScreen,
}

/// デフォルトキャンペーン（デモ用）
final List<PromotionalCampaign> defaultPromotionalCampaigns = [
  PromotionalCampaign(
    id: 'promo_001',
    title: '🎓 数学コレ！',
    description: '英語を学んだら、数学も一緒に学ぼう！全く新しい学習体験',
    imageUrl: '🧮',
    promotedApp: '数学コレ',
    appStoreUrl: 'https://apps.apple.com/app/id000000000',
    playStoreUrl: 'https://play.google.com/store/apps/details?id=com.math.kore',
    category: 'new_app',
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 30)),
    priority: 10,
    isActive: true,
    isFeatured: true,
  ),
  PromotionalCampaign(
    id: 'promo_002',
    title: '⏰ 限定キャンペーン',
    description: 'このアプリと一緒にプレイして、特別ボーナスをゲット！',
    imageUrl: '🎁',
    promotedApp: 'パズルマスター',
    appStoreUrl: 'https://apps.apple.com/app/id111111111',
    playStoreUrl: 'https://play.google.com/store/apps/details?id=com.puzzle.master',
    category: 'limited_time',
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 7)),
    priority: 8,
    isActive: true,
    isFeatured: false,
  ),
  PromotionalCampaign(
    id: 'promo_003',
    title: '🎪 クイズの王様',
    description: '様々なジャンルのクイズで頭を鍛えよう！',
    imageUrl: '❓',
    promotedApp: 'クイズの王様',
    appStoreUrl: 'https://apps.apple.com/app/id222222222',
    playStoreUrl: 'https://play.google.com/store/apps/details?id=com.quiz.king',
    category: 'new_app',
    startDate: DateTime.now().subtract(const Duration(days: 5)),
    endDate: DateTime.now().add(const Duration(days: 25)),
    priority: 5,
    isActive: true,
    isFeatured: false,
  ),
];
