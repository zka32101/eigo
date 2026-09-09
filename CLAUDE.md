# 小学コレ！英語 — Claude Code 開発ガイド

## プロジェクト概要

- **アプリ名**: 小学コレ！英語 (eigo)
- **対象**: 小学5〜6年生の英語学習
- **スタック**: Flutter + Riverpod + Firebase + RevenueCat
- **ビルド**: Android APK/AAB, iOS

## 実装済み機能

### Phase 1: 基本機能
| 機能 | 状態 | ファイル |
|---|---|---|
| ユニット別クイズ | ✅ | `lib/screens/quiz_screen.dart` |
| 進捗管理 | ✅ | `lib/providers/progress_provider.dart` |
| ローカル永続化 | ✅ | SharedPreferences + Hive |
| ユーザープロフィール | ✅ | `lib/providers/profile_provider.dart` |

### Phase 2: ゲーミフィケーション
| 機能 | 状態 | ファイル |
|---|---|---|
| ポイント/コイン | ✅ | `lib/providers/coin_provider.dart` |
| バッジシステム | ✅ | shared_core BadgeNotifier |
| キャラクター育成 | ✅ | shared_core CharacterNotifier |
| ランキング（シングルプレイ） | ✅ | `lib/screens/ranking_screen.dart` |

### Phase 3: 課金・サブスクリプション（v1.1開発中）
| 機能 | 実装状況 | 詳細 |
|---|---|---|
| RevenueCat SDK | ✅ 接続完了 | `lib/services/revenue_cat_service.dart` |
| サブスク商品 | ✅ 販売開始済み | 月額¥120（テスト中は無料） |
| 領収書検証 | ✅ | Google Play/App Store API |
| 広告管理 | ✅ | AdMob 統合済み |

## 技術スタック

- **Flutter**: 3.11.5+
- **State Management**: Riverpop 2.6.x StateNotifier
- **Backend**: Firebase Firestore, Authentication
- **In-app Purchase**: RevenueCat SDK
- **Ad Network**: Google Mobile Ads (AdMob)
- **Persistence**: SharedPreferences + Hive
- **Analytics**: Firebase Analytics（計画中）

## ファイル構成

```
lib/
├── config/
│   ├── theme.dart              # Material Design 3 テーマ
│   ├── constants.dart          # アプリ定数
│   └── firebase_config.dart    # Firebase 設定
├── data/
│   ├── quiz_data.dart          # クイズ問題データ
│   └── eigo_characters.dart    # キャラクター定義（shared_core 統合）
├── features/
│   ├── home/
│   │   └── home_screen.dart
│   ├── quiz/
│   │   ├── quiz_screen.dart
│   │   ├── result_screen.dart
│   │   └── widgets/
│   ├── progress/
│   │   ├── progress_screen.dart
│   │   └── weekly_report_screen.dart
│   ├── character/
│   │   └── character_screen.dart (→ shared_core)
│   ├── shop/
│   │   └── shop_screen.dart (→ shared_core CoinShopPage)
│   └── subscriptions/
│       └── subscription_screen.dart
├── models/
│   ├── quiz_question.dart
│   ├── user_progress.dart
│   └── subscription_tier.dart
├── providers/
│   ├── progress_provider.dart
│   ├── profile_provider.dart
│   ├── coin_provider.dart
│   ├── badge_provider.dart
│   ├── subscription_provider.dart  (✨ v1.1 新規)
│   └── ads_provider.dart
├── services/
│   ├── firebase_service.dart
│   ├── revenue_cat_service.dart    (✨ v1.1 新規)
│   ├── analytics_service.dart
│   └── notification_service.dart
├── utils/
│   └── helpers.dart
├── widgets/
│   ├── common_widgets.dart
│   └── quiz_widgets.dart
└── main.dart
```

## セットアップ手順

### 初回セットアップ
```bash
cd /home/user/eigo
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Firebase 設定
1. Firebase コンソール（console.firebase.google.com）でプロジェクト作成
2. `google-services.json` (Android) と `GoogleService-Info.plist` (iOS) をダウンロード
3. 配置:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

### RevenueCat 設定（v1.1 必須）
1. RevenueCat コンソール（dashboard.revenuecat.com）でアプリ作成
2. `lib/config/constants.dart` に API キーを設定:
   ```dart
   const String REVENUE_CAT_API_KEY = 'your_api_key_here';
   ```
3. App Store Connect / Google Play Console で商品を登録
4. RevenueCat ダッシュボードで商品をマッピング

## 開発フロー

### 新機能追加
1. **Model** を `lib/models/` に定義
2. **Provider** を `lib/providers/` に実装（Riverpod StateNotifier）
3. **Screen** を `lib/features/` に作成
4. テスト実装 (`test/` ディレクトリ)

### UI コンポーネント規則
- Material Design 3 のスタイルに従う
- `Theme.of(context)` で色・フォント取得
- レスポンシブ対応（phone/tablet）

## Riverpod プロバイダーガイド

### ProgressProvider（進捗管理）
```dart
// 進捗情報の取得
final progress = ref.watch(progressProvider);

// 進捗更新
ref.read(progressProvider.notifier).completeQuiz(
  quizId: 'unit_1_lesson_1',
  correctCount: 8,
  totalCount: 10,
);
```

### SubscriptionProvider（サブスクリプション）✨ v1.1
```dart
// 購読状態を監視
final subscription = ref.watch(subscriptionProvider);

// 商品を購入
ref.read(subscriptionProvider.notifier).purchaseSubscription('monthly_plan');
```

### AdsProvider（広告管理）
```dart
// バナー広告を監視
final bannerAd = ref.watch(adsProvider).bannerAd;

// インタースティシャル広告を表示
ref.read(adsProvider.notifier).showInterstitial();
```

## よくあるエラーと対処法

| エラー | 原因 | 解決方法 |
|--------|------|--------|
| `firebase_core not initialized` | Firebase 初期化失敗 | `main.dart` で `Firebase.initializeApp()` を待つ |
| `Riverpod state not watched` | Provider 参照ミス | `ref.watch()` 使用（`ref.read()` でなく） |
| `RevenueCat not connected` | SDK 初期化失敗 | ネットワーク接続・API キー確認 |
| `Ad Unit ID invalid` | テスト用 ID のまま | `lib/config/constants.dart` の本番 ID に変更 |

## ビルド・テスト

### ローカルテスト
```bash
# ホットリロード（開発中）
flutter run -v

# デバッグビルド
flutter build apk --debug
flutter build ios --debug

# テスト実行
flutter test
```

### リリースビルド
```bash
# Android AAB（Google Play）
flutter build appbundle --release

# Android APK（直接配信）
flutter build apk --release

# iOS（App Store）
flutter build ios --release
```

## SharedPreferences キー命名規則

```dart
// 形式: 'eigo_[feature]_[name]'
'eigo_quiz_completed_count'       // クイズ完了数
'eigo_quiz_total_score'           // 総スコア
'eigo_progress_streakdays'        // 連続学習日数
'eigo_subscription_tier'          # サブスク階級（v1.1）
'eigo_character_equipped'         # 装備キャラ
```

## Git ブランチ構成

```
main (v1.0 stable)
  ↓
develop
  ├─ feature/revenue-cat-integration  (v1.1 開発中 ← 現在地)
  ├─ feature/analytics-setup
  └─ feature/social-multiplayer (v1.2 計画中)
```

## 実装状況（2026-09-09）

### v1.0（現在リリース中）
- ✅ 基本クイズ・進捗管理
- ✅ ゲーミフィケーション（ポイント・バッジ・キャラ）
- ✅ ローカルランキング

### v1.1（開発中）
- ✅ RevenueCat SDK 接続
- ✅ サブスク商品登録
- ✅ 領収書検証 API
- 🔄 Analytics 統合（準備中）
- ⏳ A/B テスト機構（計画中）

### v1.2（計画中）
- ⏳ マルチプレイ対応
- ⏳ ソーシャル機能
- ⏳ オンラインランキング

## よくある質問

**Q. キャラクターシステムはどこで管理？**  
→ `shared_core` パッケージの `CharacterNotifier` で一元管理。各アプリでキャラセットを定義（`lib/data/eigo_characters.dart`）

**Q. RevenueCat と Firebase は何が違う？**  
→ RevenueCat は決済・サブスク管理、Firebase は認証・ユーザーデータ。両方を使用。

**Q. オフラインでプレイできる？**  
→ クイズ問題はアプリ内に埋め込み。ユーザー進捗は SharedPreferences で保存。ネット不要。

## 参考資料

- [RevenueCat 公式ドキュメント](https://docs.revenuecat.com/docs)
- [Flutter 公式ガイド](https://flutter.dev/docs)
- [Riverpod パターン集](https://riverpod.dev)
- [Google Mobile Ads for Flutter](https://pub.dev/packages/google_mobile_ads)

---

**最終更新**: 2026-09-09  
**ステータス**: ✅ v1.0 リリース中 / 🔄 v1.1 開発中
