/// eigo-kore Design System
///
/// A comprehensive, centralized design token system for consistent UI across the app.
/// Includes spacing, typography, sizes, colors, and responsive utilities.
///
/// 使用例:
/// ```dart
/// import 'package:eigo_kore/design_system/design_system.dart';
///
/// // スペーシング
/// SizedBox(height: AppSpacing.md),
/// Padding(padding: EdgeInsets.all(AppSpacing.lg), child: ...),
///
/// // タイポグラフィー
/// Text('Title', style: AppTypography.headlineLarge),
/// Text('Body', style: AppTypography.bodyMedium),
///
/// // サイズ
/// BorderRadius.circular(AppSizes.borderRadius),
/// SizedBox(width: AppSizes.iconSizeLarge),
///
/// // カラー
/// Container(color: AppColors.primary),
/// Text('Error', style: TextStyle(color: AppColors.error)),
/// ```

// Re-export all design system components
export '../theme/spacing.dart';
export '../theme/typography.dart';
export '../theme/sizes.dart';
export 'app_colors.dart';
