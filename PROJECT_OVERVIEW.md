# 英語コレ！ - プロジェクト概要

**バージョン**: 3.0.0  
**最終更新**: 2026-06-10  
**プラットフォーム**: Flutter / Android / iOS

---

## 📚 プロジェクトコンセプト

小学1-6年生を対象とした、ゲーム的要素を組み込んだ英語学習アプリ。  
**「楽しく、継続できる」** をモットーに、以下を実現：

- 🎮 **ゲーミフィケーション**: コイン・XP・バッジ・ストリークで継続を促進
- 🎤 **スピーキング重視**: AI発音評価 + 親子で楽しめる対戦機能
- 👨‍👩‍👧 **親子連携**: 保護者ダッシュボード＋親子チャレンジで家庭学習をサポート
- 📱 **オフライン対応**: インターネット不要（SharedPreferences のみ）

---

## 🎯 学習内容

### ステージ構成（全30ステージ）

| # | カテゴリ | 例 |
|---|---|---|
| 1-10 | 基本単語 | 動物・食べ物・数字・色・形 |
| 11-20 | 日常単語 | 乗り物・スポーツ・仕事・季節・場所 |
| 21-30 | 会話・応用 | フレーズ・時間表現・国・買い物・家 |

### 問題数（全600問）

| スキル | 問題数 | 説明 |
|---|---|---|
| **Listening（リスニング）** | 210問 | 音声を聞いて選択肢から選ぶ |
| **Speaking（スピーキング）** | 210問 | 英単語を発音、AI評価 |
| **Reading（リーディング）** | 120問 | 英文を読んで意味を理解 |
| **Writing（ライティング）** | 60問 | 英単語をタイプして綴字練習 |

---

## 🎮 ゲーム機能（v3.0.0）

### メイン機能
1. **📚 レッスン** — 30ステージ、各20問（L×7 + S×8 + R×3 + W×2）
2. **⚡ デイリーチャレンジ** — 日替わり5問、毎日クリアで30コイン＋50XP
3. **🎤 発音バトル** — スコア推移グラフ、自分との勝負
4. **💬 会話シミュレーション** — 5シーン、ターン制対話、TTS
5. **👨‍👩‍👧 親子チャレンジ** — 5ラウンド交互対戦、スコア比較
6. **👫 友達招待** — 招待コード交換、50コイン獲得

### 進捗管理
- 🪙 **コイン** — レッスン・チャレンジで獲得、ショップで消費
- 📈 **XP＆レベル** — 学習量に応じてアップ
- 🏆 **バッジ** — 達成条件クリアで取得（計15個程度）
- 🔥 **ストリーク** — 連続学習日数の記録
- 📅 **カレンダー** — 学習履歴をカレンダー表示

### サポート機能
- 📊 **週次レポート** — スキル別進捗、推奨学習内容
- 👨‍💼 **親向けダッシュボード** — 子どもの進捗・バッジ一覧
- ⚙️ **設定画面** — 音量・言語（日本語/英語）・通知

---

## 🪙 コインシステム（v3.0.0）

### 獲得方法
| 方法 | 獲得量 | 条件 |
|---|---|---|
| レッスンクリア | スコア÷10 + 5 | 各レッスン1回 |
| デイリーチャレンジ | 30 | 毎日クリア |
| 親子チャレンジ | スコア÷10 | 各対戦1回 |
| 招待使用 | 50 | 友達コード入力 |

### 消費方法（コインショップ）
| アイテム | 価格 | 効果 |
|---|---|---|
| 💡 ヒントチケット | 30🪙 | 問題でヒント表示 |
| ⚡ XPブースター | 50🪙 | 次レッスンXP 2倍 |
| 🎊 エフェクトパック | 80🪙 | 結果画面の演出UP |
| ⭐ スターアバター | 100🪙 | ホーム画面アイコン変更 |
| 👑 クラウンアバター | 150🪙 | ホーム画面アイコン変更 |
| 🔓 ステージ先行解放 | 200🪙 | 未クリアステージを解放 |

---

## 🛠️ 技術スタック

### フロントエンド
- **Flutter**: 3.41.9 / Dart 3.11.5
- **状態管理**: Riverpod 2.6.1
- **永続化**: SharedPreferences
- **UI**: Material Design + カスタムテーマ

### 音声機能
- **TTS**: flutter_tts（日本語・英語）
- **STT**: speech_to_text（スピーキング認識）
- **評価**: 編集距離（Levenshtein）+ 音素マッチング

### デバイス
- **Android**: minSdk 21, targetSdk 34
- **iOS**: iOS 11.0+
- **マイク**: RECORD_AUDIO パーミッション

### 外部依存
- confetti（結果画面の紙吹雪）
- fl_chart（グラフ表示）

---

## 📁 ディレクトリ構成

```
eigo-kore/
├── lib/
│   ├── main.dart                          （エントリー、ルート定義）
│   ├── providers/                         （Riverpod状態管理）
│   │   ├── progress_provider.dart         （学習進捗）
│   │   ├── coin_provider.dart             （コイン）
│   │   ├── level_provider.dart            （レベルXP）
│   │   ├── badge_provider.dart            （バッジ）
│   │   ├── daily_challenge_provider.dart  （日替わり設定）
│   │   ├── weakness_provider.dart         （弱点把握）
│   │   └── ...
│   ├── screens/                           （UI）
│   │   ├── home_screen.dart               （ホーム）
│   │   ├── lesson_screen.dart             （レッスン本体）
│   │   ├── daily_challenge_screen.dart    （⚡デイリー）
│   │   ├── pronunciation_battle_screen.dart （🎤発音バトル）
│   │   ├── conversation_screen.dart       （💬会話）
│   │   ├── parent_child_challenge_screen.dart （👨‍👩‍👧親子）
│   │   ├── invite_screen.dart             （👫招待）
│   │   ├── coin_shop_screen.dart          （🪙ショップ）
│   │   └── ...
│   ├── data/
│   │   ├── stage_data.dart                （30ステージ定義）
│   │   ├── question_data.dart             （基本単語 200問）
│   │   ├── question_data_extra2.dart      （ステージ11-20）
│   │   ├── question_data_extra3.dart      （ステージ21-30）
│   │   └── conversation_data.dart         （会話5シーン）
│   ├── models/
│   │   ├── question.dart                  （問題データ構造）
│   │   ├── stage.dart                     （ステージ定義）
│   │   └── ...
│   ├── services/
│   │   ├── speech_service.dart            （音声認識・評価）
│   │   ├── tts_service.dart               （テキスト読み上げ）
│   │   └── ...
│   ├── theme/
│   │   └── app_theme.dart                 （カラー・テキストスタイル）
│   └── widgets/
│       ├── xp_bar.dart                    （XPバー）
│       ├── speaking_score_ring.dart       （スコアリング表示）
│       └── ...
├── android/
│   ├── app/build.gradle.kts               （ビルド設定）
│   ├── gradle.properties                  （JVM設定）
│   └── ...
├── ios/                                   （iOS設定）
├── pubspec.yaml                           （依存パッケージ）
├── build/                                 （ビルド出力）
│   ├── app/outputs/flutter-apk/app-release.apk （v3: 58MB）
│   └── app/outputs/bundle/release/app-release.aab （v3: 47MB）
└── release-outputs/
    ├── GOOGLE_PLAY_CHECKLIST.md           （チェックリスト）
    └── policies/
        ├── PRIVACY_POLICY.md              （プライバシー）
        └── SECURITY_POLICY.md             （セキュリティ）
```

---

## 📊 開発ロードマップ（完了状況）

### Phase 1: 基本機能（✅ 完了）
- [x] 30ステージ / 600問データ
- [x] Listening / Speaking / Reading / Writing
- [x] レッスン画面 + 結果表示
- [x] SharedPreferences 永続化
- [x] Riverpod 状態管理

### Phase 2: ゲーム要素（✅ 完了）
- [x] コイン・XP・バッジシステム
- [x] ストリーク・カレンダー
- [x] 5つの新機能（デイリー・発音・会話・親子・招待）
- [x] コインショップ（6アイテム）

### Phase 3: 親向け機能（✅ 基本完了）
- [x] 親向けダッシュボード
- [x] 週次レポート
- [x] 親子チャレンジ

### Phase 4: リリース準備（✅ 完了）
- [x] AAB / APK ビルド成功
- [x] プライバシーポリシー自動生成
- [x] チェックリスト作成

### Phase 5: Google Play 公開（⏳ 手動）
- [ ] プライバシーポリシー公開
- [ ] グラフィック素材作成
- [ ] Google Play Console 提出
- [ ] 内部テスト確認
- [ ] 製品版リリース

### Future: 機能拡張（🔮）
- [ ] Firebase 統合（オンラインランキング）
- [ ] プッシュ通知（デイリーリマインダー）
- [ ] レベル別アダプティブ難易度
- [ ] ユーザー間対戦（オンライン）

---

## 📦 ビルド成果物（v3.0.0）

| ファイル | サイズ | 用途 |
|---|---|---|
| `eigo-kore-v3.apk` | 58MB | Android 直接インストール（テスト用） |
| `eigo-kore-v3.aab` | 47MB | Google Play Console アップロード（本番） |

**署名情報**:
- Signing Config: Release（`android/app/key.jks` で署名）
- Obfuscation: R8/ProGuard 有効

---

## 🚀 リリース手順

1. **プライバシーポリシー公開** — GitHub Pages / Notion でURL取得
2. **グラフィック作成** — アイコン・スクリーンショット・フィーチャーグラフィック
3. **Google Play Console** — アプリ作成 → AAB アップロード
4. **コンテンツレーティング** — 回答フォーム完了
5. **内部テスト** → **製品版リリース**

---

## 📞 連絡先・ライセンス

**開発**: Petit Studio  
**メール**: zkaz83@gmail.com  
**ライセンス**: 適用なし（クローズド）

---

## 🎓 学習参考資料

- Flutter 3.41.9 公式ドキュメント
- Riverpod 状態管理ガイド
- Google Play Console ポリシー

---

**最終確認**: 2026-06-10 / Claude Haiku 4.5
