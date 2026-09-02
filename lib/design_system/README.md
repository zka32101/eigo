# Design System

eigo-kore の統一された設計トークンシステム。アプリケーション全体での一貫性、保守性、スケーラビリティを確保します。

## Overview

Design System は以下の4つのコアコンポーネントで構成されています：

1. **AppSpacing** - 間隔・パディング・マージン
2. **AppTypography** - テキストスタイル・見出し・本文
3. **AppSizes** - ボタン・アイコン・カード・レスポンシブ値
4. **AppColors** - カラーパレット・セマンティックカラー

## Quick Start

```dart
import 'package:eigo_kore/design_system/design_system.dart';

// スペーシング
Padding(
  padding: EdgeInsets.all(AppSpacing.md),
  child: Text(
    'Hello World',
    style: AppTypography.bodyLarge,
  ),
)

// サイズとカラー
Container(
  width: 100,
  height: AppSizes.buttonHeight,
  decoration: BoxDecoration(
    color: AppColors.primary,
    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
  ),
)
```

## Components

### 1. AppSpacing

共通の間隔値を定義。Material Design 3 の 8dp グリッドシステムに準拠。

**基本値:**
- `xs`: 4dp - 極小間隔
- `sm`: 8dp - 小間隔
- `md`: 12dp - 中間隔
- `lg`: 16dp - 標準間隔 ⭐ 最も一般的
- `xl`: 20dp - 大間隔
- `xxl`: 24dp - 特大間隔
- `xxxl`: 32dp - 超大間隔

**プリセット:**
- `EdgeInsets` 系: `horizontalPaddingLg`, `verticalPaddingMd`, `allPaddingLg` など
- `SizedBox` 系: `verticalSpacerMd`, `horizontalSpacerLg` など

**使用例:**
```dart
// 単独値
SizedBox(height: AppSpacing.md)

// EdgeInsets
Padding(padding: AppSpacing.allPaddingLg, child: ...)

// SizedBox ショートカット
Column(
  children: [
    Text('Title'),
    AppSpacing.verticalSpacerMd,  // 12dp の縦スペーサー
    Text('Content'),
  ],
)
```

### 2. AppTypography

Material Design 3 に準拠したテキストスタイルシステム。

**見出し系:**
- `displayLarge` (32sp, Bold) - ページタイトル
- `displayMedium` (28sp, Bold) - セクションタイトル
- `displaySmall` (24sp, Bold) - サブセクションタイトル
- `headlineLarge` (22sp, Bold) - ダイアログタイトル
- `headlineMedium` (20sp, Bold) - 画面タイトル
- `headlineSmall` (18sp, Bold) - カード見出し

**本文系:**
- `bodyLarge` (16sp, Normal) - 説明テキスト
- `bodyMedium` (14sp, Normal) - 標準本文 ⭐ 最も一般的
- `bodySmall` (12sp, Normal) - ヘルプテキスト

**ラベル系:**
- `labelLarge` (14sp, SemiBold) - ボタンテキスト
- `labelMedium` (12sp, SemiBold) - 小ラベル
- `labelSmall` (11sp, SemiBold) - 最小ラベル

**数字用:**
- `numberDisplay` (28sp, Bold) - スコア表示
- `numberBody` (16sp, Bold) - ポイント表示

**使用例:**
```dart
// 基本
Text('Title', style: AppTypography.displayLarge)
Text('Body', style: AppTypography.bodyMedium)

// スタイルの拡張
Text(
  'Custom',
  style: AppTypography.bodySmall.copyWith(
    color: AppColors.textMuted,
    fontStyle: FontStyle.italic,
  ),
)

// ボタンラベル
Text('Click Me', style: AppTypography.labelLarge)
```

### 3. AppSizes

UI コンポーネントの標準サイズ。レスポンシブデザインに対応。

**主要カテゴリ:**

**ボタン:**
- `buttonHeight` (48dp) - 標準ボタン
- `buttonHeightSmall` (40dp) - 小ボタン
- `touchTargetMin` (48dp) - 最小タップ対象

**アイコン:**
- `iconSize` (24dp) - 標準アイコン ⭐ 最も一般的
- `iconSizeLarge` (32dp) - 大アイコン
- `iconSizeSmall` (16dp) - 小アイコン

**カード・角丸:**
- `borderRadius` (12dp) - 標準角丸 ⭐ 最も一般的
- `borderRadiusLarge` (16dp) - 大角丸
- `borderRadiusSmall` (8dp) - 小角丸

**シャドウ（elevation）:**
- `elevationStandard` (2.0) - 標準
- `elevationHigh` (4.0) - 高い
- `elevationVeryHigh` (8.0) - 非常に高い

**アバター:**
- `avatarSize` (48dp) - 標準
- `avatarSizeLarge` (64dp) - 大
- `avatarSizeSmall` (32dp) - 小

**ペット・イラスト:**
- `petSize` (120dp) - 標準
- `petSizeLarge` (200dp) - 詳細表示
- `petSizeSmall` (80dp) - リスト表示

**使用例:**
```dart
// ボタン
ElevatedButton(
  style: ElevatedButton.styleFrom(
    minimumSize: Size.square(AppSizes.buttonHeight),
  ),
  child: Text('Click'),
)

// カード
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
  ),
  child: ...,
)

// アイコン
Icon(Icons.favorite, size: AppSizes.iconSizeLarge)

// レスポンシブ
final iconSize = context.isLargeScreen 
  ? AppSizes.iconSizeLarge 
  : AppSizes.iconSize;
Icon(Icons.star, size: iconSize)
```

**レスポンシブ拡張:**
```dart
// BuildContext の拡張メソッド
extension ResponsiveExtension on BuildContext {
  bool get isMobile      // < 600dp
  bool get isTablet      // 600-1200dp
  bool get isDesktop     // >= 1200dp
  bool get isLargeScreen // >= 600dp
}

// 使用例
if (context.isLargeScreen) {
  // タブレット以上での表示
} else {
  // モバイル表示
}
```

### 4. AppColors

統一されたカラーパレット。セマンティックカラーシステムに基づく。

**プライマリー:**
- `primary` (#1A73E8) - 主要カラー
- `primaryDark` (#1558B0) - アクティブ状態
- `primaryLight` (#4A9EFF) - 無効状態

**セカンダリー:**
- `secondary` (#34A853) - 成功・肯定
- `secondaryDark` (#2E7D32)

**アクセント:**
- `accentOrange` (#FBC00) - 警告・ハイライト
- `accentRed` (#E53935) - エラー・削除
- `accentPurple` (#7B1FA2) - スペシャル・プレミアム
- `accentCyan` (#00BCD4) - リスニング
- `accentPink` (#E91E63) - スピーキング
- `accentGreen` (#4CAF50) - リーディング

**スキル別:**
- `listeningColor` - リスニング関連
- `speakingColor` - スピーキング関連
- `readingColor` - リーディング関連
- `writingColor` - ライティング関連

**テキスト:**
- `textPrimary` (#1A1A2E) - 本文
- `textSecondary` (#5A5A7E) - 補助情報
- `textMuted` (#6B7280) - 無効・ヒント

**背景:**
- `bgLight` (#F0F4FF) - ライト背景
- `surfaceLight` (#FAFAFA) - サーフェス
- `bgDark` (#121212) - ダーク背景
- `surfaceDark` (#1E1E1E)

**フィードバック:**
- `success` - 成功メッセージ
- `warning` - 警告メッセージ
- `error` - エラーメッセージ
- `info` - 情報メッセージ

**使用例:**
```dart
// テキスト
Text('Error', style: TextStyle(color: AppColors.error))

// 背景
Container(color: AppColors.bgLight)

// ボタン
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
  ),
  child: Text('Submit'),
)

// 条件付きカラー
final color = isSuccess ? AppColors.success : AppColors.error;

// 半透明
Container(color: AppColors.withOpacity(AppColors.primary, 0.5))
```

## Design Guidelines

### スペーシング

- **基本原則**: 8dp グリッドシステムを厳密に守る
- **推奨**: 大多数の場合、`AppSpacing.md` (12dp) または `AppSpacing.lg` (16dp) を使用
- **小要素**: `AppSpacing.xs` (4dp) または `AppSpacing.sm` (8dp)
- **大セクション**: `AppSpacing.xxl` (24dp) または `AppSpacing.xxxl` (32dp)

### タイポグラフィー

- **見出しは Boldfont のみ**: `displayLarge`, `displayMedium`, `headlineXxx`
- **本文は Normal weight**: `bodyLarge`, `bodyMedium`, `bodySmall`
- **ラベルは SemiBold**: `labelXxx` シリーズ
- **色は必ず AppColors から**: テキストに `TextStyle(color: AppColors.xxx)` を使用

### カラー

- **一貫性**: ハードコードされた色を使用しない
- **コントラスト**: テキストは十分なコントラストを確保
- **セマンティック**: フィードバック色は意味に合わせる
  - 緑 = 成功
  - 赤 = エラー
  - オレンジ = 警告

### Border Radius

- **カード**: `AppSizes.borderRadius` (12dp)
- **ボタン**: `AppSizes.borderRadiusSmall` (8dp) または `borderRadius` (12dp)
- **バッジ**: `AppSizes.badgeBorderRadius` (16dp)

## Migration Guide

既存コードをデザインシステムに移行するには：

### Before
```dart
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: const Color(0xFF1A73E8),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(
    'Click Me',
    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
)
```

### After
```dart
Container(
  padding: AppSpacing.allPaddingLg,
  decoration: BoxDecoration(
    color: AppColors.primary,
    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
  ),
  child: Text(
    'Click Me',
    style: AppTypography.labelLarge.copyWith(
      color: AppColors.textWhite,
    ),
  ),
)
```

## Best Practices

✅ **DO**:
- Import: `import 'package:eigo_kore/design_system/design_system.dart';`
- トークン値を変数に割り当てる
- 常にデザイン値を参照
- `copyWith()` でスタイル拡張

❌ **DON'T**:
- ハードコードされた値 (`16.0`, `Color(0xFF...)`)
- 魔法の数字
- 不一貫なスペーシング

## Maintenance

設計システムを変更する際：

1. トークンファイルを更新
2. すべての参照元が正しく機能することを確認
3. PR で詳細なドキュメントを記載
4. 統一的なコミットメッセージを使用

---

**最終更新**: Phase 4 実装開始
**バージョン**: 1.0 (Foundation)
