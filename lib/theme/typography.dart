import 'package:flutter/material.dart';

/// eigo-kore アプリケーション全体で使用するタイポグラフィー定義
/// Material Design 3 に準拠した統一されたテキストスタイル
class AppTypography {
  // ===== 見出し =====

  /// Display Large: 32sp / Bold / 1.25 行間
  /// 用途: 大きなページタイトル、主要な見出し
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.25,
    letterSpacing: 0,
  );

  /// Display Medium: 28sp / Bold / 1.3 行間
  /// 用途: セクションタイトル
  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.3,
    letterSpacing: 0,
  );

  /// Display Small: 24sp / Bold / 1.33 行間
  /// 用途: サブセクションタイトル
  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.33,
    letterSpacing: 0,
  );

  /// Headline Large: 22sp / Bold / 1.4 行間
  /// 用途: ダイアログタイトル、大きなカード見出し
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    height: 1.4,
    letterSpacing: 0,
  );

  /// Headline Medium: 20sp / Bold / 1.4 行間
  /// 用途: 画面タイトル、セクション見出し
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    height: 1.4,
    letterSpacing: 0,
  );

  /// Headline Small: 18sp / Bold / 1.5 行間
  /// 用途: カード見出し、リスト項目見出し
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    height: 1.5,
    letterSpacing: 0,
  );

  // ===== 本文 =====

  /// Body Large: 16sp / Normal / 1.5 行間
  /// 用途: 本文、説明テキスト
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
    letterSpacing: 0,
  );

  /// Body Medium: 14sp / Normal / 1.5 行間
  /// 用途: 標準的な本文、リスト内容
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
    letterSpacing: 0,
  );

  /// Body Small: 12sp / Normal / 1.5 行間
  /// 用途: サポートテキスト、ヘルプテキスト
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.5,
    letterSpacing: 0,
  );

  // ===== ラベル =====

  /// Label Large: 14sp / SemiBold / 1.4 行間
  /// 用途: ボタンテキスト、タブラベル
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.5,
  );

  /// Label Medium: 12sp / SemiBold / 1.4 行間
  /// 用途: 小さなラベル、バッジ
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.5,
  );

  /// Label Small: 11sp / SemiBold / 1.4 行間
  /// 用途: 小さなバッジ、キャプション
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.5,
  );

  // ===== タイトル（数字用） =====

  /// 数字用の見出し: 28sp / Bold
  /// 用途: スコア表示、大きな数字
  static const TextStyle numberDisplay = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  /// 数字用の本文: 16sp / Bold
  /// 用途: ポイント、レベル表示
  static const TextStyle numberBody = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );
}
