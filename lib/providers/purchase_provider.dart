import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/purchase_model.dart';
import '../services/purchase_service.dart';

// Subscription plan enum (legacy support)
enum PurchasePlan {
  free,
  lite,
  pro,
  plus,
  premium,
}

class PurchaseState {
  final PurchasePlan activePlan;
  final bool isLoading;
  final String? errorMessage;

  const PurchaseState({
    this.activePlan = PurchasePlan.free,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get hasProFeatures => activePlan.index >= PurchasePlan.pro.index;
  bool get hasPlusFeatures => activePlan.index >= PurchasePlan.plus.index;
  bool get hasPremiumFeatures => activePlan == PurchasePlan.premium;

  String get planDisplayName {
    switch (activePlan) {
      case PurchasePlan.free:
        return '無料プラン';
      case PurchasePlan.lite:
        return 'Lite';
      case PurchasePlan.pro:
        return 'Pro';
      case PurchasePlan.plus:
        return 'Plus';
      case PurchasePlan.premium:
        return 'Premium';
    }
  }

  PurchaseState copyWith({
    PurchasePlan? activePlan,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PurchaseState(
      activePlan: activePlan ?? this.activePlan,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseState &&
          runtimeType == other.runtimeType &&
          activePlan == other.activePlan &&
          isLoading == other.isLoading &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode =>
      activePlan.hashCode ^ isLoading.hashCode ^ errorMessage.hashCode;
}

// Service provider
final purchaseServiceProvider = Provider((ref) {
  return PurchaseService();
});

// Available products provider
final availableProductsProvider =
    FutureProvider<List<Product>>((ref) async {
  final service = ref.watch(purchaseServiceProvider);
  return service.getAvailableProducts();
});

// Products by type provider
final productsByTypeProvider =
    FutureProvider.family<List<Product>, ProductType>((ref, type) async {
  final service = ref.watch(purchaseServiceProvider);
  return service.getProductsByType(type);
});

// Subscription plans provider
final subscriptionPlansProvider =
    FutureProvider<List<SubscriptionPlan>>((ref) async {
  final service = ref.watch(purchaseServiceProvider);
  return service.getSubscriptionPlans();
});

// Featured packages provider
final featuredPackagesProvider =
    FutureProvider<List<PurchasePackage>>((ref) async {
  final service = ref.watch(purchaseServiceProvider);
  return service.getFeaturedPackages();
});

// User purchases provider
final userPurchasesProvider =
    FutureProvider.family<List<Purchase>, String>((ref, userId) async {
  final service = ref.watch(purchaseServiceProvider);
  return service.getUserPurchases(userId);
});

// User's active subscriptions provider
final activeSubscriptionsProvider =
    FutureProvider.family<List<Purchase>, String>((ref, userId) async {
  final service = ref.watch(purchaseServiceProvider);
  return service.getActiveSubscriptions(userId);
});

// User purchase history provider
final userPurchaseHistoryProvider =
    FutureProvider.family<PurchaseHistory, String>((ref, userId) async {
  final service = ref.watch(purchaseServiceProvider);
  return service.getPurchaseHistory(userId);
});

// User account value (total spent) provider
final userAccountValueProvider =
    FutureProvider.family<double, String>((ref, userId) async {
  final service = ref.watch(purchaseServiceProvider);
  return service.getUserAccountValue(userId);
});

// Check if user owns product provider
final userOwnsProductProvider = FutureProvider.family<bool, ({String userId, String productId})>(
  (ref, params) async {
    final service = ref.watch(purchaseServiceProvider);
    return service.userOwnsProduct(params.userId, params.productId);
  },
);

// Create purchase action provider
class CreatePurchaseParams {
  final String userId;
  final String productId;
  final String transactionId;
  final double amount;
  final String currency;
  final String? receiptData;
  final String? platform;

  CreatePurchaseParams({
    required this.userId,
    required this.productId,
    required this.transactionId,
    required this.amount,
    required this.currency,
    this.receiptData,
    this.platform,
  });
}

final createPurchaseActionProvider =
    FutureProvider.family<Purchase, CreatePurchaseParams>(
  (ref, params) async {
    final service = ref.watch(purchaseServiceProvider);
    final purchase = await service.createPurchase(
      userId: params.userId,
      productId: params.productId,
      transactionId: params.transactionId,
      amount: params.amount,
      currency: params.currency,
      receiptData: params.receiptData,
      platform: params.platform,
    );
    
    // Invalidate related providers
    ref.invalidate(userPurchasesProvider(params.userId));
    ref.invalidate(userPurchaseHistoryProvider(params.userId));
    ref.invalidate(userAccountValueProvider(params.userId));
    
    return purchase;
  },
);

// Restore purchases action provider
final restorePurchasesActionProvider =
    FutureProvider.family<List<Purchase>, String>((ref, userId) async {
  final service = ref.watch(purchaseServiceProvider);
  final purchases = await service.restorePurchases(userId);
  
  // Invalidate related providers
  ref.invalidate(userPurchasesProvider(userId));
  ref.invalidate(activeSubscriptionsProvider(userId));
  ref.invalidate(userPurchaseHistoryProvider(userId));
  ref.invalidate(userAccountValueProvider(userId));
  
  return purchases;
});

// Cancel subscription action provider
final cancelSubscriptionActionProvider =
    FutureProvider.family<void, ({String purchaseId, String userId})>(
  (ref, params) async {
    final service = ref.watch(purchaseServiceProvider);
    await service.cancelSubscription(params.purchaseId);
    
    // Invalidate related providers
    ref.invalidate(userPurchasesProvider(params.userId));
    ref.invalidate(activeSubscriptionsProvider(params.userId));
    ref.invalidate(userPurchaseHistoryProvider(params.userId));
  },
);

// Apply promo code action provider
class ApplyPromoCodeParams {
  final String userId;
  final String promoCode;
  final double originalPrice;

  ApplyPromoCodeParams({
    required this.userId,
    required this.promoCode,
    required this.originalPrice,
  });
}

final applyPromoCodeActionProvider =
    FutureProvider.family<double, ApplyPromoCodeParams>(
  (ref, params) async {
    final service = ref.watch(purchaseServiceProvider);
    return service.applyPromoCode(
      params.userId,
      params.promoCode,
      params.originalPrice,
    );
  },
);

// Legacy purchase notifier (for backward compatibility)
class PurchaseNotifier extends StateNotifier<PurchaseState> {
  PurchaseNotifier() : super(const PurchaseState()) {
    _init();
  }

  final _service = PurchaseService();

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    // Initialize legacy behavior if needed
    state = state.copyWith(
      activePlan: PurchasePlan.free,
      isLoading: false,
    );
  }

  Future<void> purchase(String productId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // Legacy purchase handling
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '購入処理に失敗しました。再度お試しください。',
      );
    }
  }

  Future<void> restore() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // Legacy restore handling
      state = state.copyWith(
        activePlan: PurchasePlan.free,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final purchaseProvider =
    StateNotifierProvider.autoDispose<PurchaseNotifier, PurchaseState>(
  (ref) => PurchaseNotifier(),
);
