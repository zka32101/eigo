import 'dart:io';

class RevenueCatConfig {
  RevenueCatConfig._();

  static const String _applePlaceholder = 'appl_PLACEHOLDER_SET_VIA_DART_DEFINE';
  static const String _googlePlaceholder = 'goog_PLACEHOLDER_SET_VIA_DART_DEFINE';

  static const String _appleKey = String.fromEnvironment(
    'REVENUECAT_APPLE_KEY',
    defaultValue: _applePlaceholder,
  );
  static const String _googleKey = String.fromEnvironment(
    'REVENUECAT_GOOGLE_KEY',
    defaultValue: _googlePlaceholder,
  );

  /// 現在のプラットフォームに対応するAPIキー
  static String get apiKey => Platform.isIOS ? _appleKey : _googleKey;

  /// 実際のAPIキーが `--dart-define` で設定されているか（プレースホルダーのままではないか）
  static bool get isConfigured =>
      apiKey != _applePlaceholder && apiKey != _googlePlaceholder && apiKey.isNotEmpty;

  // ─── エンタイトルメントID ──────────────────────────────
  // RevenueCatダッシュボードで作成するエンタイトルメント識別子。
  // settings_screen.dart / upgrade_screen.dart のプラン名と対応させている。
  static const String entitlementLite = 'lite';
  static const String entitlementPro = 'pro';
  static const String entitlementPlus = 'plus';
  static const String entitlementPremium = 'premium';

  // ─── ストア商品ID ──────────────────────────────────────
  // App Store Connect / Google Play Console 側で作成する商品IDと一致させる。
  // upgrade_screen.dart の `_productId()` と同じ値。
  static const String productLiteMonthly = 'eigo_kore_lite_monthly';
  static const String productProMonthly = 'eigo_kore_pro_monthly';
  static const String productPlusMonthly = 'eigo_kore_plus_monthly';
  static const String productPremiumMonthly = 'eigo_kore_premium_monthly';
}
