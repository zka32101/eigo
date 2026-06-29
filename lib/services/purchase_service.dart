import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PurchasePlan { free, lite, pro, plus, premium }

class PurchaseService {
  static final PurchaseService _instance = PurchaseService._();
  factory PurchaseService() => _instance;
  PurchaseService._();

  static const _planKey = 'active_plan';

  // Google Play / App Store の商品ID
  static const Map<String, PurchasePlan> _productToPlan = {
    'eigo_kore_lite_monthly': PurchasePlan.lite,
    'eigo_kore_pro_monthly': PurchasePlan.pro,
    'eigo_kore_plus_monthly': PurchasePlan.plus,
    'eigo_kore_premium_monthly': PurchasePlan.premium,
  };

  static const Set<String> _productIds = {
    'eigo_kore_lite_monthly',
    'eigo_kore_pro_monthly',
    'eigo_kore_plus_monthly',
    'eigo_kore_premium_monthly',
  };

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> _products = [];
  PurchasePlan _activePlan = PurchasePlan.free;
  bool _available = false;

  bool get isAvailable => _available;
  PurchasePlan get activePlan => _activePlan;
  List<ProductDetails> get products => _products;

  bool get hasProFeatures => _activePlan.index >= PurchasePlan.pro.index;
  bool get hasPlusFeatures => _activePlan.index >= PurchasePlan.plus.index;
  bool get hasPremiumFeatures => _activePlan == PurchasePlan.premium;

  Function(PurchasePlan)? onPlanChanged;
  Function(String)? onError;

  Future<void> init() async {
    _available = await _iap.isAvailable();
    await _loadSavedPlan();

    if (!_available) return;

    // 購入ストリームを購読
    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (e) => onError?.call(e.toString()),
    );

    // 商品情報を取得
    await _fetchProducts();

    // 過去の購入を復元
    await _iap.restorePurchases();
  }

  Future<void> _fetchProducts() async {
    try {
      final response = await _iap.queryProductDetails(_productIds);
      _products = response.productDetails;
    } catch (_) {}
  }

  Future<void> _loadSavedPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final planName = prefs.getString(_planKey) ?? 'free';
    _activePlan = PurchasePlan.values.firstWhere(
      (p) => p.name == planName,
      orElse: () => PurchasePlan.free,
    );
  }

  Future<void> _savePlan(PurchasePlan plan) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_planKey, plan.name);
    _activePlan = plan;
    onPlanChanged?.call(plan);
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _verifyAndDeliver(purchase);
          break;
        case PurchaseStatus.error:
          onError?.call(purchase.error?.message ?? '購入エラーが発生しました');
          if (purchase.pendingCompletePurchase) {
            _iap.completePurchase(purchase);
          }
          break;
        case PurchaseStatus.canceled:
          if (purchase.pendingCompletePurchase) {
            _iap.completePurchase(purchase);
          }
          break;
        case PurchaseStatus.pending:
          break;
      }
    }
  }

  Future<void> _verifyAndDeliver(PurchaseDetails purchase) async {
    // 本番では Server-side verification を実装
    // ここでは簡易的にクライアント側で処理
    final plan = _productToPlan[purchase.productID];
    if (plan != null) {
      await _savePlan(plan);
    }
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }
  }

  /// 商品を購入
  Future<bool> purchase(String productId) async {
    if (!_available) return false;
    final product = _products.where((p) => p.id == productId).toList();
    if (product.isEmpty) return false;

    final purchaseParam = PurchaseParam(productDetails: product.first);
    try {
      return await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (_) {
      return false;
    }
  }

  /// 購入を復元
  Future<void> restorePurchases() async {
    if (!_available) return;
    await _iap.restorePurchases();
  }

  /// デバッグ用: プランを強制設定
  Future<void> debugSetPlan(PurchasePlan plan) async {
    await _savePlan(plan);
  }

  String get planDisplayName {
    switch (_activePlan) {
      case PurchasePlan.free: return '無料プラン';
      case PurchasePlan.lite: return 'Lite プラン';
      case PurchasePlan.pro: return 'Pro プラン';
      case PurchasePlan.plus: return 'Plus プラン';
      case PurchasePlan.premium: return 'Premium プラン';
    }
  }

  String get planPrice {
    switch (_activePlan) {
      case PurchasePlan.free: return '無料';
      case PurchasePlan.lite: return '¥200/月';
      case PurchasePlan.pro: return '¥400/月';
      case PurchasePlan.plus: return '¥550/月';
      case PurchasePlan.premium: return '¥1,800/月';
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
