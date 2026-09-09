import 'dart:io';

/// RevenueCat 関連の設定値を集約するクラス。
///
/// APIキーはリポジトリに含めず、ビルド時の `--dart-define` で注入する。
/// この開発環境には本番のRevenueCat APIキーが存在しないため、
/// デフォルト値は明示的なプレースホルダーになっている
/// （[isConfigured] が false の間、RevenueCatの初期化はスキップされ、
/// アプリはローカル動作にフォールバックする）。
///
/// 本番ビルド時の指定例:
/// ```bash
/// flutter build apk --release \
///   --dart-define=REVENUECAT_GOOGLE_KEY=goog_xxxxxxxxxxxxxxxxxxxx
///
/// flutter build ios --release \
///   --dart-define=REVENUECAT_APPLE_KEY=appl_xxxxxxxxxxxxxxxxxxxx
/// ```
///
/// `flutter run` でのデバッグ時も同様に `--dart-define` で渡せる。
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
