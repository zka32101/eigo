import 'package:flutter/material.dart';

/// eigo-kore アプリケーション全体で使用するカラーパレット
/// Material Design 3 に準拠した統一された色定義
///
/// 使用例:
/// ```dart
/// Text('Hello', style: TextStyle(color: AppColors.textPrimary))
/// Container(color: AppColors.surfaceLight)
/// ```
class AppColors {
  // ===== プライマリーカラー =====

  /// プライマリーカラー: 青 (#1A73E8)
  /// 用途: 主要なボタン、リンク、強調要素
  static const Color primary = Color(0xFF1A73E8);

  /// プライマリーダーク: 濃紺 (#1558B0)
  /// 用途: 活性状態、ホバー状態
  static const Color primaryDark = Color(0xFF1558B0);

  /// プライマリーライト: 薄い青 (#4A9EFF)
  /// 用途: 無効状態、ライト背景
  static const Color primaryLight = Color(0xFF4A9EFF);

  // ===== セカンダリーカラー =====

  /// セカンダリーカラー: 緑 (#34A853)
  /// 用途: 成功状態、完了、肯定的なアクション
  static const Color secondary = Color(0xFF34A853);

  /// セカンダリーの濃い色
  static const Color secondaryDark = Color(0xFF2E7D32);

  // ===== アクセントカラー =====

  /// アクセントオレンジ (#FBb800)
  /// 用途: 警告、ハイライト、強調
  static const Color accentOrange = Color(0xFFFb8C00);

  /// アクセント赤 (#E53935)
  /// 用途: エラー、削除、危険アクション
  static const Color accentRed = Color(0xFFE53935);

  /// アクセント紫 (#7B1FA2)
  /// 用途: スペシャル、プレミアム、特別な機能
  static const Color accentPurple = Color(0xFF7B1FA2);

  /// アクセント青（シアン） (#00BCD4)
  /// 用途: リスニング関連、情報提示
  static const Color accentCyan = Color(0xFF00BCD4);

  /// アクセントピンク (#E91E63)
  /// 用途: スピーキング関連、ロマンティック
  static const Color accentPink = Color(0xFFE91E63);

  /// アクセントグリーン (#4CAF50)
  /// 用途: 読む関連、新規、成長
  static const Color accentGreen = Color(0xFF4CAF50);

  // ===== スキル別カラー =====

  /// リスニングスキルのカラー
  static const Color listeningColor = Color(0xFF00BCD4);

  /// スピーキングスキルのカラー
  static const Color speakingColor = Color(0xFFE91E63);

  /// リーディングスキルのカラー
  static const Color readingColor = Color(0xFF4CAF50);

  /// ライティングスキルのカラー
  static const Color writingColor = Color(0xFFFF9800);

  // ===== テキストカラー =====

  /// プライマリーテキスト: ダークグレー (#1A1A2E)
  /// 用途: 本文、見出し、主要テキスト
  static const Color textPrimary = Color(0xFF1A1A2E);

  /// セカンダリーテキスト: グレー (#5A5A7E)
  /// 用途: サブテキスト、補助情報
  static const Color textSecondary = Color(0xFF5A5A7E);

  /// ミュートテキスト: ライトグレー (#6B7280)
  /// 用途: 無効テキスト、ヒント、プレイスホルダー
  static const Color textMuted = Color(0xFF6B7280);

  /// ホワイトテキスト
  static const Color textWhite = Colors.white;

  // ===== 背景カラー =====

  /// ライト背景: 淡いブルー (#F0F4FF)
  /// 用途: ページ背景、コンテナ背景
  static const Color bgLight = Color(0xFFF0F4FF);

  /// ダーク背景
  static const Color bgDark = Color(0xFF121212);

  /// サーフェスライト
  static const Color surfaceLight = Color(0xFFFAFAFA);

  /// サーフェスダーク
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // ===== ボーダー・ディバイダー =====

  /// ボーダーカラー: ライトグレー
  static const Color border = Color(0xFFE0E0E0);

  /// ディバイダーカラー
  static const Color divider = Color(0xFFEEEEEE);

  // ===== フィードバックカラー =====

  /// 成功カラー
  static const Color success = Color(0xFF4CAF50);

  /// 警告カラー
  static const Color warning = Color(0xFFFFA500);

  /// エラーカラー
  static const Color error = Color(0xFFE53935);

  /// 情報カラー
  static const Color info = Color(0xFF2196F3);

  // ===== グラデーション用カラー =====

  /// グラデーション開始色（プライマリー系）
  static const Color gradientStart = Color(0xFF1A73E8);

  /// グラデーション終了色（セカンダリー系）
  static const Color gradientEnd = Color(0xFF34A853);

  // ===== 半透明カラー =====

  /// セミトランスペアレント背景 (black 50%)
  static const Color overlayDark = Color(0x80000000);

  /// セミトランスペアレント背景 (white 50%)
  static const Color overlayLight = Color(0x80FFFFFF);

  // ===== ヘルパーメソッド =====

  /// 色を半透明にする
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// ライトテーマ用のテキストカラー
  static const Color textLightTheme = textPrimary;

  /// ダークテーマ用のテキストカラー
  static const Color textDarkTheme = Colors.white;

  /// ライトテーマ用の背景カラー
  static const Color bgLightTheme = bgLight;

  /// ダークテーマ用の背景カラー
  static const Color bgDarkTheme = bgDark;
}
