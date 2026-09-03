import '../design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'sizes.dart';
import 'spacing.dart';

/// eigo-kore アプリケーション全体で使用する
/// 統一されたコンポーネントスタイル定義
///
/// 使用例:
/// ```dart
/// ElevatedButton(
///   style: AppComponentStyles.primaryButton,
///   onPressed: () => ...,
///   child: Text('押す'),
/// )
/// ```
class AppComponentStyles {
  // ===== ボタンスタイル =====

  /// プライマリボタンスタイル
  /// 青色の標準ボタン、最優先アクション用
  static ButtonStyle get primaryButton => ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor:AppColors.textWhite,
        minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
        elevation: AppSizes.elevationStandard,
      ).copyWith(
        elevation: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return AppSizes.elevationHigh;
          }
          return AppSizes.elevationStandard;
        }),
      );

  /// セカンダリボタンスタイル
  /// グリーン色のボタン、次点のアクション用
  static ButtonStyle get secondaryButton => ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentGreen,
        foregroundColor:AppColors.textWhite,
        minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
      );

  /// アウトラインボタンスタイル
  /// 枠線のみ、キャンセルなど低優先度アクション用
  static ButtonStyle get outlineButton => OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
        side: const BorderSide(color: AppColors.primary, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
      );

  /// テキストボタンスタイル
  /// 背景なし、最低優先度のアクション用
  static ButtonStyle get textButton => TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
      );

  /// 小さいボタンスタイル
  static ButtonStyle get smallButton => ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor:AppColors.textWhite,
        minimumSize: const Size(double.infinity, AppSizes.buttonHeightSmall),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
      );

  // ===== テキスト入力スタイル =====

  /// 標準テキスト入力フィールドのデコレーション
  static InputDecoration get textInputDecoration => InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.textFieldBorderRadius),
          borderSide: const BorderSide(color: AppColors.bgLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.textFieldBorderRadius),
          borderSide: const BorderSide(color: AppColors.bgLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.textFieldBorderRadius),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor:AppColors.textWhite,
        hintStyle: const TextStyle(color: AppColors.textMuted),
      );

  // ===== カードスタイル =====

  /// 標準カードのデコレーション
  static BoxDecoration get cardDecoration => BoxDecoration(
        color:AppColors.textWhite,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppColors.bgLight,
          width: 1,
        ),
      );

  /// 強調されたカードのデコレーション
  static BoxDecoration get highlightedCardDecoration => BoxDecoration(
        color:AppColors.textWhite,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withAlpha(25),
          width: 2,
        ),
      );

  // ===== チップ・バッジスタイル =====

  /// 標準チップの装飾
  static BoxDecoration get chipDecoration => BoxDecoration(
        color: AppColors.primary.withAlpha(25).withAlpha(51),
        borderRadius: BorderRadius.circular(AppSizes.chipBorderRadius),
        border: Border.all(
          color: AppColors.primary.withAlpha(25),
          width: 1,
        ),
      );

  /// 成功バッジの装飾
  static BoxDecoration get successBadgeDecoration => BoxDecoration(
        color: AppColors.accentGreen.withAlpha(25),
        borderRadius: BorderRadius.circular(AppSizes.badgeBorderRadius),
        border: Border.all(
          color: AppColors.accentGreen,
          width: 1,
        ),
      );

  /// 警告バッジの装飾
  static BoxDecoration get warningBadgeDecoration => BoxDecoration(
        color: AppColors.accentOrange.withAlpha(25),
        borderRadius: BorderRadius.circular(AppSizes.badgeBorderRadius),
        border: Border.all(
          color: AppColors.accentOrange,
          width: 1,
        ),
      );

  // ===== ディバイダースタイル =====

  /// 標準ディバイダー
  static const Divider standardDivider = Divider(
    height: AppSizes.dividerHeight,
    color: AppColors.bgLight,
    thickness: 1,
  );

  /// 太いディバイダー
  static const Divider boldDivider = Divider(
    height: AppSizes.dividerHeightBold,
    color: AppColors.bgLight,
    thickness: 2,
  );

  // ===== スペーシングヘルパー =====

  /// カード間の標準パディング
  static const EdgeInsets cardPadding = EdgeInsets.all(AppSpacing.lg);

  /// 画面のパディング
  static const EdgeInsets screenPadding = EdgeInsets.all(AppSpacing.lg);

  /// セクション間のパディング
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(
    vertical: AppSpacing.xxl,
    horizontal: AppSpacing.lg,
  );
}

/// AppBar カスタマイズ用のスタイル
class AppBarStyles {
  /// 標準 AppBar のテーマ
  static const AppBarTheme standardTheme = AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor:AppColors.textWhite,
    elevation: AppSizes.elevationStandard,
    centerTitle: false,
  );

  /// ダークテーマの AppBar
  static const AppBarTheme darkTheme = AppBarTheme(
    backgroundColor: Color(0xFF1E1E1E),
    foregroundColor:AppColors.textWhite,
    elevation: 0,
  );
}
