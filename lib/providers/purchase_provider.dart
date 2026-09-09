import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../config/revenuecat_config.dart';
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

/// RevenueCatのエンタイトルメント状態をアプリのプラン管理に橋渡しする notifier。
///
/// プラン判定はローカルの状態フラグではなく、RevenueCatから取得した
/// [CustomerInfo.entitlements] を唯一の情報源（source of truth）として行う。
class PurchaseNotifier extends StateNotifier<PurchaseState> {
  PurchaseNotifier() : super(const PurchaseState()) {
    _init();
  }

  final _service = PurchaseService();
  StreamSubscription<CustomerInfo>? _customerInfoSub;

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    try {
      // main.dart で既に初期化されている想定だが、未初期化なら念のため試みる
      // （APIキー未設定なら内部でスキップされ何も起きない）。
      await PurchaseService.initializeRevenueCat();
      await _refreshFromCustomerInfo();
      _customerInfoSub = _service.customerInfoStream.listen(_applyCustomerInfo);
    } catch (_) {
      // RevenueCat未設定・オフライン等 → フリープランのまま動作を継続
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _refreshFromCustomerInfo() async {
    final info = await _service.getCustomerInfo();
    if (info != null) _applyCustomerInfo(info);
  }

  void _applyCustomerInfo(CustomerInfo info) {
    final activeEntitlements = info.entitlements.active.keys.toSet();
    state = state.copyWith(activePlan: _planFromEntitlements(activeEntitlements));
  }

  PurchasePlan _planFromEntitlements(Set<String> active) {
    if (active.contains(RevenueCatConfig.entitlementPremium)) return PurchasePlan.premium;
    if (active.contains(RevenueCatConfig.entitlementPlus)) return PurchasePlan.plus;
    if (active.contains(RevenueCatConfig.entitlementPro)) return PurchasePlan.pro;
    if (active.contains(RevenueCatConfig.entitlementLite)) return PurchasePlan.lite;
    return PurchasePlan.free;
  }

  /// ストア商品ID（例: `eigo_kore_pro_monthly`）に対応するRevenueCatパッケージを
  /// 購入する。成功したら true、ユーザーキャンセルまたはエラー時は false を返す。
  Future<bool> purchase(String productId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      if (!PurchaseService.isRevenueCatReady) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: '課金機能が現在利用できません（設定未完了）。しばらくしてから再度お試しください。',
        );
        return false;
      }

      final package = await _service.findPackageByProductId(productId);
      if (package == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'この商品は現在購入できません。時間をおいて再度お試しください。',
        );
        return false;
      }

      final info = await _service.purchasePackage(package);
      _applyCustomerInfo(info);
      state = state.copyWith(isLoading: false);
      return true;
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) {
        // ユーザーによるキャンセル。エラー扱いにしない。
        state = state.copyWith(isLoading: false);
        return false;
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: '購入処理に失敗しました。再度お試しください。',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '購入処理に失敗しました。再度お試しください。',
      );
      return false;
    }
  }

  /// 過去の購入を復元する。成功したら true を返す。
  Future<bool> restore() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      if (!PurchaseService.isRevenueCatReady) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: '課金機能が現在利用できません（設定未完了）。',
        );
        return false;
      }
      final info = await _service.restoreRevenueCatPurchases();
      _applyCustomerInfo(info);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '復元に失敗しました。再度お試しください。',
      );
      return false;
    }
  }

  @override
  void dispose() {
    _customerInfoSub?.cancel();
    super.dispose();
  }
}

final purchaseProvider =
    StateNotifierProvider.autoDispose<PurchaseNotifier, PurchaseState>(
  (ref) => PurchaseNotifier(),
);
