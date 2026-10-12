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
  // 小学コレシリーズ共通の1つのみ。Play Console の eigo_premium_* はこれに紐づく。
  static const String entitlementPremium = '小学コレ_pro';

  // ─── ストア商品ID ──────────────────────────────────────
  // Google Play Console の定期購入ID（基本プラン monthly / yearly）と一致させる。
  static const String productProMonthly = 'eigo_premium_monthly';
  static const String productProAnnual = 'eigo_premium_yearly';

  // ─── 表示価格 ──────────────────────────────────────────
  // ストア側の実価格（App Store Connect / Google Play Console）と
  // 一致させること。ここはアプリ内表示のみを一元管理する定数で、
  // 実際の請求額はストア側の商品設定に従う。
  static const String proPriceMonthlyLabel = '¥300';
  static const String proPriceAnnualLabel = '¥2,400';
}
