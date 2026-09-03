import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/purchase_model.dart';
import 'logger_service.dart';

class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();

  factory PurchaseService() {
    return _instance;
  }

  PurchaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LoggerService _logger = LoggerService();

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
      _logger.error('Failed to get products: $e', 'PurchaseService');
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
      _logger.error('Failed to get products by type: $e', 'PurchaseService');
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
      _logger.error('Failed to get subscription plans: $e', 'PurchaseService');
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
      _logger.error('Failed to get featured packages: $e', 'PurchaseService');
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

      _logger.info(
        'Purchase created for user $userId: $purchaseId',
        'PurchaseService',
      );
      return purchase;
    } catch (e) {
      _logger.error('Failed to create purchase: $e', 'PurchaseService');
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
      _logger.error(
        'Failed to get user purchases: $e',
        'PurchaseService',
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
      _logger.error(
        'Failed to get active subscriptions: $e',
        'PurchaseService',
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
      _logger.error(
        'Failed to check product ownership: $e',
        'PurchaseService',
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

      _logger.info(
        'Purchases restored for user $userId',
        'PurchaseService',
      );
      return purchases;
    } catch (e) {
      _logger.error(
        'Failed to restore purchases: $e',
        'PurchaseService',
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
      _logger.error(
        'Failed to get purchase history: $e',
        'PurchaseService',
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
      _logger.error(
        'Failed to get user account value: $e',
        'PurchaseService',
      );
      rethrow;
    }
  }

  // Verify receipt
  Future<bool> verifyReceipt(String receiptData, String platform) async {
    try {
      // In production, this would call RevenueCat API or your backend
      // For now, this is a placeholder
      _logger.info(
        'Receipt verification for platform: $platform',
        'PurchaseService',
      );
      return true;
    } catch (e) {
      _logger.error('Failed to verify receipt: $e', 'PurchaseService');
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

      _logger.info(
        'Subscription cancelled: $purchaseId',
        'PurchaseService',
      );
    } catch (e) {
      _logger.error(
        'Failed to cancel subscription: $e',
        'PurchaseService',
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
      _logger.error(
        'Failed to apply promo code: $e',
        'PurchaseService',
      );
      rethrow;
    }
  }
}
