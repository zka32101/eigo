import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../config/revenuecat_config.dart';
import '../models/purchase_model.dart';
import 'logger_service.dart';

class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();

  factory PurchaseService() {
    return _instance;
  }

  PurchaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── RevenueCat（サブスクリプション課金） ──────────────────────
  //
  // 上の Firestore ベースのメソッド群は products/purchasePackages コレクションを
  // 使った独自のカタログ・購入履歴管理（コイン購入・プロモコード等）用。
  // 実際のストア課金（サブスクリプションプラン）は RevenueCat SDK を介して行う。

  static bool _rcInitialized = false;
  static final StreamController<CustomerInfo> _customerInfoController =
      StreamController<CustomerInfo>.broadcast();

  /// RevenueCat SDK が初期化済みかどうか
  static bool get isRevenueCatReady => _rcInitialized;

  /// RevenueCat SDK を初期化する。
  ///
  /// APIキーが未設定（プレースホルダーのまま）の場合は何もせずスキップし、
  /// アプリはRevenueCatなしで（ローカル/フリープランのみで）動作を続ける。
  /// これにより本番キーが無いこの開発環境でもクラッシュしない。
  static Future<void> initializeRevenueCat() async {
    if (_rcInitialized) return;
    if (!RevenueCatConfig.isConfigured) {
      LoggerService.info(
        'RevenueCat APIキーが未設定のため初期化をスキップします（プレースホルダー検出）',
        tag: 'PurchaseService',
      );
      return;
    }
    try {
      await Purchases.setLogLevel(LogLevel.warn);
      final config = PurchasesConfiguration(RevenueCatConfig.apiKey);
      await Purchases.configure(config);
      _rcInitialized = true;

      Purchases.addCustomerInfoUpdateListener((info) {
        if (!_customerInfoController.isClosed) {
          _customerInfoController.add(info);
        }
      });

      LoggerService.info('RevenueCat初期化完了', tag: 'PurchaseService');
    } catch (e) {
      LoggerService.error('RevenueCat初期化に失敗しました: $e', tag: 'PurchaseService');
    }
  }

  /// Firebase匿名UIDなど、アプリ側のユーザーIDとRevenueCatユーザーを紐付ける。
  /// サポート対応・分析のために推奨（必須ではない）。
  Future<void> linkRevenueCatUser(String appUserId) async {
    if (!_rcInitialized) return;
    try {
      await Purchases.logIn(appUserId);
    } catch (e) {
      LoggerService.error('RevenueCatユーザー紐付けに失敗しました: $e', tag: 'PurchaseService');
    }
  }

  /// カスタマー情報（エンタイトルメント含む）の更新ストリーム
  Stream<CustomerInfo> get customerInfoStream => _customerInfoController.stream;

  /// 現在のカスタマー情報を取得（未初期化時は null）
  Future<CustomerInfo?> getCustomerInfo() async {
    if (!_rcInitialized) return null;
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      LoggerService.error('カスタマー情報の取得に失敗しました: $e', tag: 'PurchaseService');
      return null;
    }
  }

  /// 購入可能なオファリング（プラン・パッケージ一覧）を取得
  Future<Offerings?> getOfferings() async {
    if (!_rcInitialized) return null;
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      LoggerService.error('オファリングの取得に失敗しました: $e', tag: 'PurchaseService');
      return null;
    }
  }

  /// 指定したストア商品IDに対応する [Package] をオファリングから探す
  Future<Package?> findPackageByProductId(String productId) async {
    final offerings = await getOfferings();
    if (offerings == null) return null;
    for (final offering in offerings.all.values) {
      for (final pkg in offering.availablePackages) {
        if (pkg.storeProduct.identifier == productId) {
          return pkg;
        }
      }
    }
    return null;
  }

  /// パッケージを購入する。
  /// [PurchasesErrorCode.purchaseCancelledError] はユーザーキャンセルなので
  /// 呼び出し側でキャッチしてハンドリングすること。
  Future<CustomerInfo> purchasePackage(Package package) async {
    if (!_rcInitialized) {
      throw StateError('RevenueCatが初期化されていません（APIキー未設定）');
    }
    return Purchases.purchasePackage(package);
  }

  /// 過去の購入を復元する
  Future<CustomerInfo> restoreRevenueCatPurchases() async {
    if (!_rcInitialized) {
      throw StateError('RevenueCatが初期化されていません（APIキー未設定）');
    }
    return Purchases.restorePurchases();
  }

  // ─── Firestore ベースのカタログ・購入履歴管理 ───────────────────

  // Get all available products
  Future<List<Product>> getAvailableProducts() async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Product.fromJson(doc.data()))
          .toList();
    } catch (e) {
      LoggerService.error('Failed to get products: $e', tag: 'PurchaseService');
      rethrow;
    }
  }

  // Get products by type
  Future<List<Product>> getProductsByType(ProductType type) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('type', isEqualTo: type.toString().split('.').last)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Product.fromJson(doc.data()))
          .toList();
    } catch (e) {
      LoggerService.error('Failed to get products by type: $e', tag: 'PurchaseService');
      rethrow;
    }
  }

  // Get subscription plans
  Future<List<SubscriptionPlan>> getSubscriptionPlans() async {
    try {
      final snapshot = await _firestore
          .collection('subscriptionPlans')
          .orderBy('isMostPopular', descending: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => SubscriptionPlan.fromJson(doc.data()))
          .toList();
    } catch (e) {
      LoggerService.error('Failed to get subscription plans: $e', tag: 'PurchaseService');
      rethrow;
    }
  }

  // Get featured packages
  Future<List<PurchasePackage>> getFeaturedPackages() async {
    try {
      final snapshot = await _firestore
          .collection('purchasePackages')
          .where('isFeatured', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      final packages = <PurchasePackage>[];
      for (var doc in snapshot.docs) {
        final pkg = PurchasePackage.fromJson(doc.data());
        if (!pkg.isExpired) {
          packages.add(pkg);
        }
      }
      return packages;
    } catch (e) {
      LoggerService.error('Failed to get featured packages: $e', tag: 'PurchaseService');
      rethrow;
    }
  }

  // Create a purchase
  Future<Purchase> createPurchase({
    required String userId,
    required String productId,
    required String transactionId,
    required double amount,
    required String currency,
    String? receiptData,
    String? platform,
  }) async {
    try {
      final purchaseId = _firestore.collection('purchases').doc().id;
      final purchase = Purchase(
        id: purchaseId,
        userId: userId,
        productId: productId,
        transactionId: transactionId,
        amount: amount,
        currency: currency,
        status: PurchaseStatus.completed,
        purchasedAt: DateTime.now(),
        isSubscriptionActive: false,
        receiptData: receiptData,
        platform: platform,
      );

      await _firestore
          .collection('purchases')
          .doc(purchaseId)
          .set(purchase.toJson());

      // Create transaction record
      final txnId = _firestore.collection('transactions').doc().id;
      final transaction = Transaction(
        id: txnId,
        userId: userId,
        purchaseId: purchaseId,
        amount: amount,
        currency: currency,
        transactionDate: DateTime.now(),
        transactionId: transactionId,
        status: 'completed',
        paymentMethod: platform,
      );

      await _firestore
          .collection('transactions')
          .doc(txnId)
          .set(transaction.toJson());

      LoggerService.info(
        'Purchase created for user $userId: $purchaseId',
        'PurchaseService',
      );
      return purchase;
    } catch (e) {
      LoggerService.error('Failed to create purchase: $e', tag: 'PurchaseService');
      rethrow;
    }
  }

  // Get user's purchase history
  Future<List<Purchase>> getUserPurchases(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('purchases')
          .where('userId', isEqualTo: userId)
          .orderBy('purchasedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Purchase.fromJson(doc.data()))
          .toList();
    } catch (e) {
      LoggerService.error(
        'Failed to get user purchases: $e',
        tag: 'PurchaseService',
      );
      rethrow;
    }
  }

  // Get active subscriptions for user
  Future<List<Purchase>> getActiveSubscriptions(String userId) async {
    try {
      final purchases = await getUserPurchases(userId);
      return purchases
          .where((p) => p.isSubscriptionActive && !p.isExpired)
          .toList();
    } catch (e) {
      LoggerService.error(
        'Failed to get active subscriptions: $e',
        tag: 'PurchaseService',
      );
      rethrow;
    }
  }

  // Check if user owns a product
  Future<bool> userOwnsProduct(String userId, String productId) async {
    try {
      final purchases = await getUserPurchases(userId);
      return purchases.any((p) => p.productId == productId && p.isValid);
    } catch (e) {
      LoggerService.error(
        'Failed to check product ownership: $e',
        tag: 'PurchaseService',
      );
      rethrow;
    }
  }

  // Restore purchases (for subscription recovery)
  Future<List<Purchase>> restorePurchases(String userId) async {
    try {
      final purchases = await getUserPurchases(userId);
      
      for (final purchase in purchases) {
        if (purchase.expiresAt != null && 
            DateTime.now().isBefore(purchase.expiresAt!)) {
          // Update subscription status if not expired
          await _firestore
              .collection('purchases')
              .doc(purchase.id)
              .update({
                'isSubscriptionActive': true,
                'status': 'completed',
              });
        }
      }

      LoggerService.info(
        'Purchases restored for user $userId',
        'PurchaseService',
      );
      return purchases;
    } catch (e) {
      LoggerService.error(
        'Failed to restore purchases: $e',
        tag: 'PurchaseService',
      );
      rethrow;
    }
  }

  // Get purchase history with stats
  Future<PurchaseHistory> getPurchaseHistory(String userId) async {
    try {
      final purchases = await getUserPurchases(userId);
      
      double totalSpent = 0;
      final purchasedProductIds = <String>{};
      DateTime? firstPurchaseDate;
      DateTime? lastPurchaseDate;

      for (final purchase in purchases) {
        if (purchase.status == PurchaseStatus.completed) {
          totalSpent += purchase.amount;
          purchasedProductIds.add(purchase.productId);
          
          if (firstPurchaseDate == null ||
              purchase.purchasedAt.isBefore(firstPurchaseDate)) {
            firstPurchaseDate = purchase.purchasedAt;
          }
          
          if (lastPurchaseDate == null ||
              purchase.purchasedAt.isAfter(lastPurchaseDate)) {
            lastPurchaseDate = purchase.purchasedAt;
          }
        }
      }

      return PurchaseHistory(
        userId: userId,
        totalPurchases: purchases.where((p) => p.isValid).length,
        totalSpent: totalSpent,
        currency: 'JPY',
        purchases: purchases,
        firstPurchaseDate: firstPurchaseDate,
        lastPurchaseDate: lastPurchaseDate,
        purchasedProductIds: purchasedProductIds.toList(),
      );
    } catch (e) {
      LoggerService.error(
        'Failed to get purchase history: $e',
        tag: 'PurchaseService',
      );
      rethrow;
    }
  }

  // Get user's account value (total spent)
  Future<double> getUserAccountValue(String userId) async {
    try {
      final history = await getPurchaseHistory(userId);
      return history.totalSpent;
    } catch (e) {
      LoggerService.error(
        'Failed to get user account value: $e',
        tag: 'PurchaseService',
      );
      rethrow;
    }
  }

  // Verify receipt
  //
  // NOTE: レシート検証自体はRevenueCat SDKが購入・復元時に自動的に行うため
  // クライアント側でこのメソッドを個別に呼ぶ必要は基本的にない
  // （`purchasePackage` / `restoreRevenueCatPurchases` が返す [CustomerInfo] の
  // エンタイトルメント状態が既に検証済みの結果）。
  //
  // ここに残しているのは、Firestore上の独自購入履歴（コイン購入等）に対する
  // レガシー用途のプレースホルダー。サーバー側でのRevenueCat Webhook検証
  // （購入・更新・解約イベントをCloud Functionsで受信しFirestoreに反映する等）は
  // 別タスクとして今後対応する（社内参考実装として想定していたsocial_quiz_appには
  // 実際にはCloud Functions側のRevenueCat/購入連携は未実装だったため、ゼロから設計する）。
  Future<bool> verifyReceipt(String receiptData, String platform) async {
    try {
      LoggerService.info(
        'Receipt verification for platform: $platform',
        tag: 'PurchaseService',
      );
      return true;
    } catch (e) {
      LoggerService.error('Failed to verify receipt: $e', tag: 'PurchaseService');
      rethrow;
    }
  }

  // Cancel subscription
  Future<void> cancelSubscription(String purchaseId) async {
    try {
      await _firestore
          .collection('purchases')
          .doc(purchaseId)
          .update({
            'isSubscriptionActive': false,
            'status': 'cancelled',
          });

      LoggerService.info(
        'Subscription cancelled: $purchaseId',
        'PurchaseService',
      );
    } catch (e) {
      LoggerService.error(
        'Failed to cancel subscription: $e',
        tag: 'PurchaseService',
      );
      rethrow;
    }
  }

  // Apply promo code
  Future<double> applyPromoCode(
    String userId,
    String promoCode,
    double originalPrice,
  ) async {
    try {
      final doc = await _firestore
          .collection('promoCodes')
          .doc(promoCode)
          .get();

      if (!doc.exists) {
        throw Exception('Invalid promo code');
      }

      final data = doc.data()!;
      final isActive = data['isActive'] ?? false;
      final discountType = data['discountType'] ?? 'percentage'; // 'percentage' or 'fixed'
      final discountValue = data['discountValue'] ?? 0;
      final usageLimit = data['usageLimit'];
      final timesUsed = data['timesUsed'] ?? 0;

      if (!isActive || (usageLimit != null && timesUsed >= usageLimit)) {
        throw Exception('Promo code is not valid');
      }

      double discount = 0;
      if (discountType == 'percentage') {
        discount = originalPrice * (discountValue / 100);
      } else {
        discount = discountValue.toDouble();
      }

      final finalPrice = (originalPrice - discount).clamp(0.0, originalPrice);

      // Update usage count
      await _firestore
          .collection('promoCodes')
          .doc(promoCode)
          .update({'timesUsed': FieldValue.increment(1)});

      return finalPrice;
    } catch (e) {
      LoggerService.error(
        'Failed to apply promo code: $e',
        tag: 'PurchaseService',
      );
      rethrow;
    }
  }
}
