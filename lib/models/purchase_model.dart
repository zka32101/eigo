import 'package:json_annotation/json_annotation.dart';

part 'purchase_model.g.dart';

enum ProductType {
  consumable, // One-time purchase (coins, boosters)
  nonConsumable, // Permanent unlock
  subscription, // Recurring subscription
}

enum SubscriptionPeriod {
  monthly,
  quarterly,
  annual,
  lifetime,
}

enum PurchaseStatus {
  pending,
  completed,
  failed,
  cancelled,
  refunded,
}

@JsonSerializable()
class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String currency;
  final ProductType type;
  final String? icon;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final int? rewardCoins;
  final int? rewardXp;
  final String? rewardBadgeId;
  final List<String> tags; // 'daily', 'popular', 'limited', 'new'

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    required this.type,
    this.icon,
    this.imageUrl,
    required this.isActive,
    required this.createdAt,
    this.rewardCoins,
    this.rewardXp,
    this.rewardBadgeId,
    required this.tags,
  });

  String get displayPrice => '$currency ${price.toStringAsFixed(2)}';

  Product copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? currency,
    ProductType? type,
    String? icon,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    int? rewardCoins,
    int? rewardXp,
    String? rewardBadgeId,
    List<String>? tags,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      rewardCoins: rewardCoins ?? this.rewardCoins,
      rewardXp: rewardXp ?? this.rewardXp,
      rewardBadgeId: rewardBadgeId ?? this.rewardBadgeId,
      tags: tags ?? this.tags,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);
}

@JsonSerializable()
class SubscriptionPlan {
  final String id;
  final String title;
  final String description;
  final double price;
  final String currency;
  final SubscriptionPeriod period;
  final int? discountPercentage;
  final double? discountedPrice;
  final String? benefits; // Comma-separated benefits
  final bool isMostPopular;
  final DateTime createdAt;

  SubscriptionPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    required this.period,
    this.discountPercentage,
    this.discountedPrice,
    this.benefits,
    required this.isMostPopular,
    required this.createdAt,
  });

  String get displayPrice {
    if (discountedPrice != null) {
      return '$currency ${discountedPrice!.toStringAsFixed(2)}';
    }
    return '$currency ${price.toStringAsFixed(2)}';
  }

  String get periodLabel {
    switch (period) {
      case SubscriptionPeriod.monthly:
        return '月額';
      case SubscriptionPeriod.quarterly:
        return '3ヶ月ごと';
      case SubscriptionPeriod.annual:
        return '年額';
      case SubscriptionPeriod.lifetime:
        return '永久';
    }
  }

  SubscriptionPlan copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? currency,
    SubscriptionPeriod? period,
    int? discountPercentage,
    double? discountedPrice,
    String? benefits,
    bool? isMostPopular,
    DateTime? createdAt,
  }) {
    return SubscriptionPlan(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      period: period ?? this.period,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      benefits: benefits ?? this.benefits,
      isMostPopular: isMostPopular ?? this.isMostPopular,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionPlanFromJson(json);
  Map<String, dynamic> toJson() => _$SubscriptionPlanToJson(this);
}

@JsonSerializable()
class Purchase {
  final String id;
  final String userId;
  final String productId;
  final String transactionId;
  final double amount;
  final String currency;
  final PurchaseStatus status;
  final DateTime purchasedAt;
  final DateTime? expiresAt;
  final bool isSubscriptionActive;
  final String? receiptData;
  final String? platform; // 'android', 'ios', 'web'

  Purchase({
    required this.id,
    required this.userId,
    required this.productId,
    required this.transactionId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.purchasedAt,
    this.expiresAt,
    required this.isSubscriptionActive,
    this.receiptData,
    this.platform,
  });

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isValid {
    return status == PurchaseStatus.completed && !isExpired;
  }

  Purchase copyWith({
    String? id,
    String? userId,
    String? productId,
    String? transactionId,
    double? amount,
    String? currency,
    PurchaseStatus? status,
    DateTime? purchasedAt,
    DateTime? expiresAt,
    bool? isSubscriptionActive,
    String? receiptData,
    String? platform,
  }) {
    return Purchase(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      transactionId: transactionId ?? this.transactionId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isSubscriptionActive: isSubscriptionActive ?? this.isSubscriptionActive,
      receiptData: receiptData ?? this.receiptData,
      platform: platform ?? this.platform,
    );
  }

  factory Purchase.fromJson(Map<String, dynamic> json) =>
      _$PurchaseFromJson(json);
  Map<String, dynamic> toJson() => _$PurchaseToJson(this);
}

@JsonSerializable()
class Transaction {
  final String id;
  final String userId;
  final String purchaseId;
  final double amount;
  final String currency;
  final DateTime transactionDate;
  final String transactionId; // Platform transaction ID
  final String status;
  final String? failureReason;
  final String? paymentMethod;

  Transaction({
    required this.id,
    required this.userId,
    required this.purchaseId,
    required this.amount,
    required this.currency,
    required this.transactionDate,
    required this.transactionId,
    required this.status,
    this.failureReason,
    this.paymentMethod,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);
}

@JsonSerializable()
class PurchaseHistory {
  final String userId;
  final int totalPurchases;
  final double totalSpent;
  final String currency;
  final List<Purchase> purchases;
  final DateTime? firstPurchaseDate;
  final DateTime? lastPurchaseDate;
  final List<String> purchasedProductIds;

  PurchaseHistory({
    required this.userId,
    required this.totalPurchases,
    required this.totalSpent,
    required this.currency,
    required this.purchases,
    this.firstPurchaseDate,
    this.lastPurchaseDate,
    required this.purchasedProductIds,
  });

  bool hasPurchased(String productId) => purchasedProductIds.contains(productId);

  factory PurchaseHistory.fromJson(Map<String, dynamic> json) =>
      _$PurchaseHistoryFromJson(json);
  Map<String, dynamic> toJson() => _$PurchaseHistoryToJson(this);
}

@JsonSerializable()
class PurchasePackage {
  final String id;
  final String title;
  final String description;
  final List<Product> products;
  final double totalValue;
  final double discountedPrice;
  final int discountPercentage;
  final String? icon;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime? expiresAt;

  PurchasePackage({
    required this.id,
    required this.title,
    required this.description,
    required this.products,
    required this.totalValue,
    required this.discountedPrice,
    required this.discountPercentage,
    this.icon,
    required this.isFeatured,
    required this.createdAt,
    this.expiresAt,
  });

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  int get totalCoins {
    return products.fold(0, (sum, p) => sum + (p.rewardCoins ?? 0));
  }

  PurchasePackage copyWith({
    String? id,
    String? title,
    String? description,
    List<Product>? products,
    double? totalValue,
    double? discountedPrice,
    int? discountPercentage,
    String? icon,
    bool? isFeatured,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return PurchasePackage(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      products: products ?? this.products,
      totalValue: totalValue ?? this.totalValue,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      icon: icon ?? this.icon,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  factory PurchasePackage.fromJson(Map<String, dynamic> json) =>
      _$PurchasePackageFromJson(json);
  Map<String, dynamic> toJson() => _$PurchasePackageToJson(this);
}
