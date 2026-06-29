# 英語コレ！ (eigo-kore)

小学生向けの Flutter 英語学習アプリ。スピーキング・発音チェック機能を特化させ、AI会話による自由な英語練習をサポートします。

## 🎯 特徴

- **80ステージ** — 段階的な学習カリキュラム（grades 1-6対応、英検5級対応）
- **1,676問** — リスニング・スピーキング・リーディング・ライティングの4技能
- **発音チェック** — Levenshtein距離による精密な発音採点（0-100点表示）
- **AI会話** — Gemini・Claude API によるフリートーク練習
- **ステージ導入画面** — 各ステージの学習前に「キーワード・ポイント・例文」を表示
- **解答説明** — 正解後に「発音・日本語・学習ティップス」を表示
- **500語の語彙カード** — 12カテゴリ、難易度フィルター、TTS対応
- **朝通知** — 毎朝50フレーズの英語を自動配信

## 📊 コンテンツ規模

| 項目 | 内容 |
|------|------|
| **ステージ** | 80本 |
| **総問題数** | 1,676問 |
| **語彙カード** | 500語（12カテゴリ） |
| **会話シーン** | 59本 |
| **朝フレーズ** | 50本 |

## 🏗️ 技術スタック

- **Frontend**: Flutter 3.11+
- **State Management**: Riverpod
- **Database**: Firebase Firestore + SharedPreferences
- **AI/ML**: 
  - Google Generative AI (Gemini 1.5 Flash)
  - Anthropic Claude API (フォールバック)
- **Speech**: 
  - flutter_tts (Text-to-Speech)
  - speech_to_text (音声認識)
- **Storage**: flutter_secure_storage (API キー暗号化)
- **Notifications**: flutter_local_notifications

## 📁 プロジェクト構成

```
lib/
├── main.dart                      — エントリポイント・ルート定義
├── screens/                       — UI画面
│   ├── home_screen.dart
│   ├── stage_select_screen.dart
│   ├── stage_intro_screen.dart    — ステージ導入画面
│   ├── lesson_screen.dart         — レッスン画面（解答説明付き）
│   ├── result_screen.dart
│   ├── vocabulary_screen.dart     — 語彙カード
│   ├── ai_freetalk_screen.dart
│   ├── pronunciation_check_screen.dart
│   └── settings_screen.dart
├── models/
│   ├── stage.dart
│   ├── question.dart
│   └── user_profile.dart
├── providers/                     — Riverpod state management
│   ├── progress_provider.dart
│   ├── level_provider.dart
│   ├── badge_provider.dart
│   ├── claude_conversation_provider.dart  — AI会話
│   ├── pronunciation_provider.dart
│   ├── ai_api_key_provider.dart   — API キー管理
│   └── morning_notification_provider.dart
├── services/
│   ├── speech_service.dart        — 音声認識・採点
│   ├── tts_service.dart           — TTS
│   ├── gemini_service.dart        — Gemini API
│   ├── claude_api_service.dart    — Claude API
│   └── morning_notification_service.dart
├── data/
│   ├── stage_data.dart            — 80ステージ定義
│   ├── question_data*.dart        — 1,676問データ
│   ├── vocabulary_data.dart       — 500語カード
│   ├── conversation_data.dart     — 59会話シーン
│   ├── stage_intro_data.dart      — ステージ導入データ
│   └── morning_phrase_data.dart   — 朝フレーズ
└── theme/
    └── app_theme.dart             — デザインシステム
```

## 🚀 セットアップ

### 必須環境
- Flutter 3.11+
- Dart 3.0+
- Android SDK 21+ / iOS 11+

### インストール

```bash
git clone https://github.com/petitworksappsdev-hash/eigo-kore.git
cd eigo-kore
flutter pub get
flutter run
```

### Firebase 設定

1. Firebase Console で新規プロジェクト作成
2. `android/app/google-services.json` を配置
3. Firestore Database を初期化（セキュリティルール設定）

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    match /progress/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

### API キー設定

アプリ内「設定 > AI キー設定」から以下を入力：
- **Gemini API Key**: https://aistudio.google.com/app/apikey
- **Claude API Key**: https://console.anthropic.com/account/keys

## 📱 ビルド & リリース

### APK ビルド（Android）

```bash
flutter build apk --release
# 出力: build/app/outputs/flutter-apk/app-release.apk (72.5MB)
```

### IPA ビルド（iOS）

```bash
flutter build ios --release
# Xcode で Archive → Export
```

### Google Play へのリリース

1. Google Play Console にログイン
2. 新規アプリ作成
3. APK/AAB をアップロード
4. ストア掲載情報（説明、スクリーンショット、プライバシーポリシー）を入力
5. リリース申請

## 🔐 プライバシー & セキュリティ

- **COPPA 準拠**: 13才未満を対象とした子ども向けアプリ
- **データ暗号化**: API キーは flutter_secure_storage で暗号化
- **通信セキュリティ**: HTTPS のみ使用
- **プライバシーポリシー**: [プライバシーポリシー](./PRIVACY_POLICY.md)

## 📊 競合分析

| アプリ | 強み | eigo-kore の差別化 |
|--------|------|-------------------|
| **チャレンジイングリッシュ** | 2,600レッスン | スピーキング・発音チェック特化 |
| **ECC Jr.** | 7,400語 | AI会話機能（業界初） |
| **トド英語** | 3,500アクティビティ | ステージ導入・解答説明充実 |
| **Duolingo** | 10,000+ | 小学生向け専門・スピーキング特化 |

## 📈 ロードマップ

- [ ] v3.5: Web 版対応 & Chromebook サポート
- [ ] v4.0: 教育施設向け管理画面（先生用）
- [ ] v4.1: マルチプレイヤー対戦モード
- [ ] v4.2: Advanced AI coaching（個別学習プラン提案）

## 📄 ライセンス

MIT License — 詳細は [LICENSE](./LICENSE) を参照

## 👨‍💻 開発者

**Petit Works Apps**  
- GitHub: [@petitworksappsdev-hash](https://github.com/petitworksappsdev-hash)
- Email: zkaz83@gmail.com

## 📞 サポート

- バグ報告・機能リクエスト: [GitHub Issues](https://github.com/petitworksappsdev-hash/eigo-kore/issues)
- プライバシー関連: zkaz83@gmail.com

---

**バージョン**: v3.4  
**最終更新**: 2026-06-28  
**ステータス**: 🚀 Ready for Release
