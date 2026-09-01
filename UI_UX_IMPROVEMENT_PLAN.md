# eigo-kore v3.4 UI/UX 改善計画

**作成日**: 2026-09-01  
**対象**: Flutter UI/UX ポーランド  
**優先度**: 中期改善（1-2ヶ月）

---

## 📋 目次

1. [現在の状態](#現在の状態)
2. [改善対象スクリーン一覧](#改善対象スクリーン一覧)
3. [デザイン改善チェックリスト](#デザイン改善チェックリスト)
4. [優先度別実装プラン](#優先度別実装プラン)
5. [カラーパレット最適化](#カラーパレット最適化)
6. [タイポグラフィー統一](#タイポグラフィー統一)
7. [アニメーション・マイクロインタラクション](#アニメーションマイクロインタラクション)
8. [アクセシビリティ](#アクセシビリティ)
9. [レスポンシブデザイン](#レスポンシブデザイン)

---

## 現在の状態

### ✅ 現在の強み
- Material Design 3 採用
- ダークモード対応
- 豊富なゲーミング要素（バッジ、XP、ストリーク）
- カラフルなスキル別カラー（L/S/R/W）
- Riverpod による効率的な状態管理

### ❌ 改善余地
- **小画面最適化**: タブレット・大画面での表示が未調整
- **アニメーション不足**: 画面遷移やボタンのフィードバック
- **アクセシビリティ**: コントラスト比、フォントサイズ
- **視覚階層**: 重要度の差別化が不十分
- **スペーシング**: 一貫性が低い部分がある
- **ローディング状態**: スケルトンスクリーンがない

---

## 改善対象スクリーン一覧

### 🏠 ホーム関連（3画面）
| スクリーン | 優先度 | 改善項目 |
|-----------|--------|---------|
| home_screen.dart | ⭐⭐⭐ | レイアウト再設計、カード間隔、ボタンのサイズ統一 |
| onboarding_screen.dart | ⭐⭐ | ステップインジケータ、大きなタイポグラフィ |
| profile_select_screen.dart | ⭐⭐ | プロフィールカードのアニメーション、アバター拡大 |

### 📚 学習関連（6画面）
| スクリーン | 優先度 | 改善項目 |
|-----------|--------|---------|
| lesson_screen.dart | ⭐⭐⭐ | 問題表示の最適化、ボタン配置、フィードバック |
| stage_select_screen.dart | ⭐⭐⭐ | ステージカード 2列グリッド化、クリアバッジ位置 |
| stage_intro_screen.dart | ⭐⭐⭐ | 導入コンテンツ、イラスト最適化、テキスト行間 |
| result_screen.dart | ⭐⭐⭐ | スコア表示、アニメーション（confetti改善） |
| speaking_practice_screen.dart | ⭐⭐⭐ | マイク入力UI、スコアリング表示 |
| pronunciation_check_screen.dart | ⭐⭐⭐ | 波形表示、スコア計測UI、比較画面 |

### 🐾 ペット・ゲーミング関連（5画面）
| スクリーン | 優先度 | 改善項目 |
|-----------|--------|---------|
| pet_screen.dart | ⭐⭐⭐ | ペット描画、アニメーション拡張 |
| teacher_mode_screen.dart | ⭐⭐ | 先生ごっこ UI、モード切り替え |
| ranking_screen.dart | ⭐⭐ | ランキングテーブル最適化 |
| weekly_report_screen.dart | ⭐⭐⭐ | チャート最適化、グラフ描画改善 |
| badge_screen.dart | ⭐⭐ | バッジグリッド、獲得時の表現 |

### 📊 その他（18画面）
| スクリーン | 優先度 | 改善項目 |
|-----------|--------|---------|
| parent_dashboard_screen.dart | ⭐⭐⭐ | 親向けダッシュボード、グラフ最適化 |
| vocabulary_screen.dart | ⭐⭐ | 単語リスト UI、フィルター UX |
| conversation_screen.dart | ⭐⭐ | AI会話 UI、チャット吹き出し |
| settings_screen.dart | ⭐⭐ | 設定フォーム、トグル UI |
| notification_settings_screen.dart | ⭐ | 通知設定フォーム |
| parent_child_challenge_screen.dart | ⭐⭐ | チャレンジボード UI |

---

## デザイン改善チェックリスト

### 🎨 カラー・コントラスト
- [ ] WCAG 2.1 AA レベルのコントラスト比を検証
- [ ] 背景色と文字色の組み合わせ確認（正常色弱対応）
- [ ] ダークモードでのコントラスト確認
- [ ] アクセントカラーの過度な使用の回避

### 📐 タイポグラフィー
- [ ] 見出し（H1-H6）のサイズと太さ統一
- [ ] 本文フォントサイズを 14sp 以上に
- [ ] 行間（lineHeight）の一貫性確認
- [ ] フォントウェイトの統一（Regular, Bold, SemiBold）

### 🎯 レイアウト・スペーシング
- [ ] 8dp グリッドシステムの徹底
- [ ] パディング・マージンの統一（8, 12, 16, 20, 24dp）
- [ ] カード間のスペーシング統一（12-16dp）
- [ ] 最小タップ対象サイズ 48×48dp の確認

### ✨ アニメーション
- [ ] 画面遷移アニメーション追加（300-400ms）
- [ ] ボタンタップフィードバック（ripple + scale）
- [ ] スクロール時のカード elevation 変更
- [ ] ステージクリア時の confetti 改善
- [ ] ローディング中のスピナー/スケルトン追加

### 📱 レスポンシブ対応
- [ ] 小画面（< 360dp）での表示確認
- [ ] 大画面（> 800dp）での 2 列/3 列レイアウト
- [ ] タブレット（600dp 以上）での landscape 対応
- [ ] ステータスバー・ナビゲーションバーの考慮

### 🔍 小さな UI 改善
- [ ] ボタンの最小サイズ確認（44×44dp）
- [ ] アイコンサイズの統一（24×24 を基準）
- [ ] テキスト入力フィールドの高さ（48-56dp）
- [ ] リスト項目の最小高さ（56dp）
- [ ] カードの角丸統一（12-16dp）

### ♿ アクセシビリティ
- [ ] Semantics ウィジェットの追加
- [ ] スクリーンリーダー対応テスト
- [ ] フォーカスナビゲーション テスト
- [ ] 拡大表示対応テスト（150%-200%）

---

## 優先度別実装プラン

### Phase 1: 基本デザイン統一（Week 1-2）

#### 1.1 カラーパレット最適化
```dart
// lib/theme/app_theme.dart の改善

// Primary Colors
const kPrimaryColor = Color(0xFF1A73E8);      // Google Blue
const kPrimaryDark = Color(0xFF1558B0);       // Darker Blue
const kPrimaryLight = Color(0xFF4A9EFF);      // Light Blue

// Semantic Colors
const kSuccessColor = Color(0xFF34A853);      // Green
const kWarningColor = Color(0xFFFB8C00);      // Orange
const kErrorColor = Color(0xFFE53935);        // Red
const kInfoColor = Color(0xFF1976D2);         // Info Blue

// Skill Colors (4技能)
const kListeningColor = Color(0xFF00BCD4);    // Cyan
const kSpeakingColor = Color(0xFFE91E63);     // Pink
const kReadingColor = Color(0xFF4CAF50);      // Green
const kWritingColor = Color(0xFFFF9800);      // Orange

// Background & Text
const kBgLight = Color(0xFFF0F4FF);           // Very light blue
const kBgLighter = Color(0xFFFAFBFC);         // Lighter
const kTextDark = Color(0xFF1A1A2E);          // Very dark
const kTextMuted = Color(0xFF6B7280);         // Muted gray
const kBorderColor = Color(0xFFE5E7EB);       // Light gray
```

#### 1.2 タイポグラフィー統一
```dart
// lib/theme/typography.dart (新規作成)

class AppTypography {
  // 見出し
  static const headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.25,
  );
  
  static const headline2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );
  
  static const headline3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.33,
  );
  
  // 本文
  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
  
  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
  
  static const bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
  
  // ラベル
  static const labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
}
```

#### 1.3 スペーシング定数
```dart
// lib/theme/spacing.dart (新規作成)

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
}

// lib/theme/sizes.dart
class AppSizes {
  static const double borderRadius = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double iconSize = 24.0;
  static const double buttonHeight = 48.0;
  static const double listTileHeight = 56.0;
}
```

### Phase 2: 主要画面の改善（Week 2-3）

#### 2.1 ホーム画面の改善
- ステータスバー色の統一
- カードのシャドウ・ボーダー改善
- ボタンサイズの統一（height: 48dp）
- グリッドレイアウト（small で 1 列、large で 2 列）

#### 2.2 ステージ選択画面の改善
- ステージカードを GridView で 2 列表示
- クリアバッジの位置最適化
- スコア表示フォーマット統一
- ロック状態のビジュアル改善

#### 2.3 レッスン画面の改善
- 問題表示領域の最適化
- ボタン配置の整理（下部固定）
- フィードバック UX 改善

### Phase 3: アニメーション・インタラクション（Week 3-4）

#### 3.1 ページ遷移
```dart
// lib/utils/transitions.dart (新規作成)

class SlidePageTransition extends PageTransition {
  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);
  
  // スライドイン・アウトのアニメーション
}
```

#### 3.2 ボタンフィードバック
```dart
// インタラクティブなボタン

class PrimaryButton extends StatefulWidget {
  // Ripple + Scale animation
  // Duration: 150-200ms
}
```

#### 3.3 ローディング状態
```dart
// lib/widgets/skeleton_loader.dart (新規作成)
// - スケルトンスクリーン
// - Shimmer アニメーション
```

### Phase 4: アクセシビリティ対応（Week 4）

#### 4.1 コントラスト確認
- WCAG 2.1 AAA レベル対応を目指す
- 色覚異常対応（正常色弱対応）

#### 4.2 フォントサイズ
- 最小 14sp を徹底
- 拡大表示対応テスト

#### 4.3 セマンティクス
```dart
// Semantics ウィジェット追加

Semantics(
  label: '発音チェック',
  button: true,
  enabled: true,
  child: GestureDetector(
    onTap: () => _checkPronunciation(),
    child: ...
  ),
)
```

---

## カラーパレット最適化

### 現在のパレット分析

| 役割 | 色 | 16進数 | 使用箇所 |
|------|-----|--------|---------|
| Primary | Blue | #1A73E8 | AppBar, ボタン, リンク |
| Primary Dark | Dark Blue | #1558B0 | Focus, Hover |
| Primary Light | Light Blue | #4A9EFF | Light テーマ要素 |
| Secondary | Green | #34A853 | Success, アクション |
| Accent | Orange | #FB8C00 | Warning, Highlights |
| Error | Red | #E53935 | Errors, Alerts |
| Listening | Cyan | #00BCD4 | L スキル |
| Speaking | Pink | #E91E63 | S スキル |
| Reading | Green | #4CAF50 | R スキル |
| Writing | Orange | #FF9800 | W スキル |

### 推奨：カラーシステムの最適化

```dart
// Material Design 3 カラーシステム

class ColorTokens {
  // Surface Colors
  static const surface = Color(0xFFFAFBFC);
  static const surfaceVariant = Color(0xFFF0F4FF);
  
  // Outline Colors
  static const outline = Color(0xFFCAD1DD);
  static const outlineVariant = Color(0xFFE5E7EB);
  
  // これらを ThemeData に統合
}
```

---

## タイポグラフィー統一

### 現在の課題
- フォントサイズが不統一（14sp-32sp でばらつき）
- 行間が指定されていない場合がある
- フォントウェイトの統一性が低い

### 推奨フォントスケール

| 用途 | サイズ | ウェイト | 行間 |
|------|--------|----------|------|
| Display Large | 32sp | Bold | 1.25 |
| Display Medium | 28sp | Bold | 1.3 |
| Display Small | 24sp | Bold | 1.33 |
| Headline Large | 22sp | Bold | 1.4 |
| Headline Medium | 20sp | Bold | 1.4 |
| Headline Small | 18sp | Bold | 1.5 |
| Body Large | 16sp | Normal | 1.5 |
| Body Medium | 14sp | Normal | 1.5 |
| Body Small | 12sp | Normal | 1.5 |
| Label Large | 14sp | 600 | 1.4 |
| Label Medium | 12sp | 600 | 1.4 |
| Label Small | 11sp | 600 | 1.4 |

---

## アニメーション・マイクロインタラクション

### 実装予定

#### 1. ページ遷移（300-400ms）
```dart
// 現在: 標準的なマテリアルトランジション
// 改善: スライド/フェードイン追加
```

#### 2. ボタンタップ（150-200ms）
```dart
// 実装: Ripple + Scale Effect
MaterialButton(
  // Elevation change on tap
  // Scale: 0.98x on press
)
```

#### 3. スクロール時のアニメーション
```dart
// ヘッダーの elevation 変更
// カードの parallax effect
```

#### 4. ステージクリア演出（1000ms）
```dart
// 現在: Confetti
// 改善: 
// - スターのアニメーション追加
// - スコア上昇アニメーション
// - バッジ獲得アニメーション
```

#### 5. ローディング状態
```dart
// Skeleton screens
// - Shimmer effect
// - Progressive loading
```

---

## アクセシビリティ

### WCAG 2.1 AA 準拠チェックリスト

#### Contrast (1.4.3)
- [ ] 通常テキスト: 4.5:1 以上
- [ ] 大きいテキスト: 3:1 以上
- [ ] グラフィック要素: 3:1 以上

#### Text Size (1.4.4)
- [ ] 最小フォントサイズ: 14sp
- [ ] 拡大対応: 200% まで確認

#### Focus Visible (2.4.7)
- [ ] すべてのインタラクティブ要素に Focus 表示
- [ ] Focus の色: 通常テキストとのコントラスト 3:1 以上

#### Color Alone (1.4.1)
- [ ] 色だけで情報を伝えない
- [ ] テキストラベルの追加

---

## レスポンシブデザイン

### ブレークポイント定義

```dart
class Breakpoints {
  static const double mobile = 0;      // < 360dp
  static const double tablet = 600;    // >= 600dp
  static const double desktop = 1200;  // >= 1200dp
}

// ScreenSize helper
extension ContextExtension on BuildContext {
  bool get isMobile => MediaQuery.of(this).size.width < 600;
  bool get isTablet => MediaQuery.of(this).size.width >= 600 && 
                        MediaQuery.of(this).size.width < 1200;
  bool get isDesktop => MediaQuery.of(this).size.width >= 1200;
}
```

### レイアウトパターン

#### Mobile (< 360dp)
- 1 列レイアウト
- コンパクトなカード
- 大きめなボタン

#### Tablet (600-1200dp)
- 2 列グリッド（ステージ等）
- 2 ペイン レイアウト（master-detail）
- 横向き対応

#### Desktop (>= 1200dp)
- 3 列グリッド
- サイドバー付き
- Full-width layouts

---

## 実装スケジュール

### Week 1-2: 基本設計
- [ ] カラーパレット最適化
- [ ] タイポグラフィー統一
- [ ] スペーシング定数化

### Week 2-3: 主要画面改善
- [ ] ホーム画面
- [ ] ステージ選択
- [ ] レッスン画面
- [ ] リザルト画面

### Week 3-4: アニメーション
- [ ] ページ遷移
- [ ] ボタンフィードバック
- [ ] ローディング状態

### Week 4: アクセシビリティ
- [ ] コントラスト確認
- [ ] フォントサイズ確認
- [ ] スクリーンリーダー対応

---

## 測定指標

### UI 品質指標

| 指標 | 現在 | 目標 | 計測方法 |
|------|------|------|---------|
| コントラスト比 | 4.5:1 | 7:1 | WebAIM Contrast Checker |
| 最小フォントサイズ | 12sp | 14sp | Manual review |
| ボタン最小サイズ | 40×40 | 48×48 | Manual review |
| スペーシング一貫性 | 70% | 100% | Code review |
| アニメーション実装率 | 30% | 80% | Feature checklist |

---

## 参考リソース

- [Material Design 3 Guide](https://m3.material.io/)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Flutter Accessibility](https://flutter.dev/docs/development/accessibility-and-localization/accessibility)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

---

**Last Updated**: 2026-09-01  
**Version**: 1.0
