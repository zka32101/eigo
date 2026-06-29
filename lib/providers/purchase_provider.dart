import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/purchase_service.dart';

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
      case PurchasePlan.free: return '無料プラン';
      case PurchasePlan.lite: return 'Lite';
      case PurchasePlan.pro: return 'Pro';
      case PurchasePlan.plus: return 'Plus';
      case PurchasePlan.premium: return 'Premium';
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
}

class PurchaseNotifier extends StateNotifier<PurchaseState> {
  PurchaseNotifier() : super(const PurchaseState()) {
    _init();
  }

  final _service = PurchaseService();

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    _service.onPlanChanged = (plan) {
      state = state.copyWith(activePlan: plan, isLoading: false);
    };
    _service.onError = (msg) {
      state = state.copyWith(isLoading: false, errorMessage: msg);
    };
    await _service.init();
    state = state.copyWith(
      activePlan: _service.activePlan,
      isLoading: false,
    );
  }

  Future<void> purchase(String productId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final ok = await _service.purchase(productId);
    if (!ok) {
      state = state.copyWith(isLoading: false, errorMessage: '購入処理に失敗しました。再度お試しください。');
    }
    // 成功時は onPlanChanged コールバックで状態が更新される
  }

  Future<void> restore() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await _service.restorePurchases();
    state = state.copyWith(
      activePlan: _service.activePlan,
      isLoading: false,
    );
  }

  // デバッグ用
  Future<void> debugSetPlan(PurchasePlan plan) async {
    await _service.debugSetPlan(plan);
    state = state.copyWith(activePlan: plan);
  }
}

final purchaseProvider = StateNotifierProvider<PurchaseNotifier, PurchaseState>(
  (ref) => PurchaseNotifier(),
);
