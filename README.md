# 英語コレ！(eigo-kore)

小学生向けのFlutter英語学習アプリ。スピーキング・発音チェック機能とAI会話機能により、自然な英語運用能力をサポートします。

## 🎯 主な特徴

- **80ステージ** - 体系的な学習カリキュラム (Grades 1-6対応、英検5級対応)
- **1,676問題** - リスニング・スピーキング・リーディング・ライティングの4技能
- **発音チェック機能** - Levenshtein距離による精密な発音採点、0-100点表示
- **AI会話** - Gemini・Claude APIによるフリートーク練習
- **ステージ導入画面** - 各ステージの学習前にキーワード・ポイント・例文を表示
- **解答説明** - 正解後に発音・日本語・学習ティップスを表示
- **500語彙** - 12カテゴリ、難度フィルター、TTS対応
- **朝通知機能** - 毎日50フレーズの英語を自動配信

## 📋 コンテンツ

| 項目 | 内容 |
|------|------|
| **ステージ** | 80本 |
| **問題数** | 1,676問 |
| **語彙** | 500語、12カテゴリ |
| **会話シーン** | 59本 |
| **朝フレーズ** | 50本 |

## 🛠️ 技術スタック

- **Frontend**: Flutter 3.11+
- **State Management**: Riverpod
- **Database**: Firebase Firestore + SharedPreferences
- **AI/ML**: 
  - Google Generative AI (Gemini 1.5 Flash)
  - Anthropic Claude API (フォールバック)
- **Speech**: 
  - flutter_tts (Text-to-Speech)
  - speech_to_text (音声認識)
- **Storage**: flutter_secure_storage (API キー安全保管)
- **Notifications**: flutter_local_notifications

## 📁 プロジェクト構成

```
lib/
├── main.dart                      - エントリポイント、ルート管理
├── screens/                       - UI画面
│  ├── home_screen.dart
│  ├── stage_select_screen.dart
│  ├── stage_intro_screen.dart     - ステージ導入画面
│  ├── lesson_screen.dart          - レッスン画面（解答説明含む）
│  ├── result_screen.dart
│  ├── vocabulary_screen.dart      - 語彙ページ
│  ├── ai_freetalk_screen.dart
│  ├── pronunciation_check_screen.dart
│  └── settings_screen.dart
├── models/
│  ├── stage.dart
│  ├── question.dart
│  ├── vocabulary.dart
│  └── user.dart
├── providers/                     - Riverpod State Management
│  ├── stage_provider.dart
│  ├── question_provider.dart
│  ├── user_provider.dart
│  ├── ai_api_key_provider.dart
│  └── pet_provider.dart
├── services/
│  ├── firebase_service.dart
│  ├── ai_service.dart
│  ├── speech_service.dart
│  ├── tts_service.dart
│  ├── notification_service.dart
│  └── secure_storage_service.dart
├── widgets/
│  ├── stage_card.dart
│  ├── question_widget.dart
│  ├── result_summary.dart
│  └── pet_animation.dart
├── utils/
│  ├── constants.dart
│  ├── color_scheme.dart
│  ├── pronunciation_scorer.dart
│  └── levenshtein_distance.dart
├── assets/
│  ├── icons/
│  ├── images/
│  └── pets/
└── test/
   └── unit_tests/
```

## 🚀 はじめ方

### 前提条件
- Flutter 3.11.5 以上
- Dart 3.11.5 以上
- iOS 12.0 以上（iOS開発時）
- Android 5.1 以上（Android開発時）

### インストール

```bash
# 依存パッケージをインストール
flutter pub get

# iOS/Androidの準備
flutter pub global activate fvm
fvm install

# アプリを実行
flutter run
```

### API キーの設定

1. **Firebase** - `google-services.json` (Android) と `GoogleService-Info.plist` (iOS) を設定
2. **Gemini API** - アプリ設定からAPIキーを入力
3. **Claude API** (オプション) - フォールバック用にAPIキーを入力

## 🎮 使用方法

1. **ホーム画面** - ステージを選択
2. **ステージ導入** - 学習内容を理解（キーワード・ポイント・例文）
3. **レッスン** - 各問題に回答（リスニング・スピーキングなど）
4. **解答説明** - 発音・意味・ティップスを確認
5. **ペット育成** - 学習によってペットが成長

## 📊 主な機能の詳細

### 発音チェック
- Levenshtein距離アルゴリズムを用いた精密採点
- スコア表示（0-100点）で上達実感
- 通常速・ゆっくり速の再生対応

### AI会話
- Gemini 1.5 Flash による自然な会話生成
- Claude API フォールバック機能
- API キーは安全にローカル保管

### ペット育成（v4.0）
- 学習によってペットが成長
- 先生ごっこ機能でぬいぐるみのような体験
- 複数ペット対応

## 🔐 セキュリティ

- API キーは `flutter_secure_storage` で安全に保管
- Firebase Security Rules により ユーザーデータを保護
- 児童向けアプリ向けのプライバシー設定

## 📱 対応プラットフォーム

- ✅ Android 5.1 以上
- ✅ iOS 12.0 以上
- ✅ macOS（開発中）
- ✅ Windows（開発中）
- ✅ Web（開発中）

## 📈 開発ロードマップ

### v3.4（現在）
- スピーキング・発音チェック
- 80ステージ・1,676問題
- AI会話機能（Gemini/Claude）

### v4.0（計画中）
- ペット育成システム強化
- 先生ごっこ機能
- 学習分析ダッシュボード

### v4.1（計画中）
- アニメーション強化
- ランキング機能
- プレミアム機能（無制限AI会話など）

## 🐛 バグ報告

バグを発見した場合は、[Issues](https://github.com/zka32101/eigo/issues) で報告してください。

## 📝 ライセンス

このプロジェクトはプライベートリポジトリです。

## 👨‍💻 開発者

- **主開発者**: zkaz83
- **バージョン**: v3.4
- **最終更新**: 2026-09-01

## 📧 サポート

ご質問や機能リクエストは GitHub Issues でお願いします。
