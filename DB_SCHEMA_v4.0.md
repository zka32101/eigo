# eigo-kore v4.0 Firestore データベーススキーマ設計

**作成日**: 2026-07-03  
**バージョン**: 4.0  
**期間**: Week 8-12 実装予定  

---

## 📋 概要

Firestore スキーマは以下の3大機能をサポート：
1. **ペット育成** (`users/{userId}/pet/*`)
2. **1日1フレーズチャレンジ** (`dailyChallenges/*`)
3. **先生ごっこモード** (`users/{userId}/teacherMode/*`)

---

## 🎭 1. ペット育成スキーマ

### **Collection: `users/{userId}/pet`**

#### **Document: `data` — ペットの現在状態**

```json
{
  "userId": "user_abc123",
  "species": "parrot",
  "level": 5,
  "exp": 45,
  "hunger": 60,
  "happiness": 75,
  "lastFedDate": "2026-07-03T14:30:00Z",
  "createdAt": "2026-06-28T09:00:00Z",
  "evolveDates": [
    "2026-06-28T09:00:00Z",    // たまご → ベビー
    "2026-07-01T10:30:00Z"     // ベビー → キッズ
  ],
  "decorationIds": [
    "hat_party",
    "medal_gold"
  ]
}
```

| フィールド | 型 | 説明 | 備考 |
|----------|------|------|------|
| `userId` | String | ユーザーID | 親ドキュメント参照 |
| `species` | String | ペットの種類 | parrot/turtle/fish/lion/fox |
| `level` | Integer | ペットレベル | 1-30 |
| `exp` | Integer | 経験値 | 0-99（100で level up） |
| `hunger` | Integer | 飢餓度 | 0-100 |
| `happiness` | Integer | 幸福度 | 0-100 |
| `lastFedDate` | Timestamp | 最後にエサやった日時 | UTC ISO8601 |
| `createdAt` | Timestamp | ペット作成日時 | UTC ISO8601 |
| `evolveDates` | Array<Timestamp> | 進化した日時（最大3回） | [たまご→ベビー, ベビー→キッズ, キッズ→アダルト] |
| `decorationIds` | Array<String> | 装備中の装飾品ID | リスト |

**インデックス要件**:
- なし（単一ドキュメント読み込み）

---

#### **Subcollection: `users/{userId}/pet/history` — エサやり履歴**

```json
{
  "date": "2026-07-03",
  "timestamp": "2026-07-03T14:30:00Z",
  "pronouncingScore": 85,
  "coinsEarned": 20,
  "hungerBefore": 70,
  "hungerAfter": 60,
  "stageId": 5,
  "questionId": "q_5_2"
}
```

| フィールド | 型 | 説明 | 用途 |
|----------|------|------|------|
| `date` | String | 日付（YYYY-MM-DD） | 日単位の集計用 |
| `timestamp` | Timestamp | 正確な時刻 | ソート用 |
| `pronouncingScore` | Integer | 発音スコア | 0-100 |
| `coinsEarned` | Integer | 獲得コイン数 | ペットのエサ変換 |
| `hungerBefore` / `hungerAfter` | Integer | エサやり前後の飢餓度 | 分析用 |
| `stageId` | Integer | ステージID | どの問題で獲得したか |
| `questionId` | String | 問題ID | 問題の詳細特定用 |

**ドキュメント ID**: `auto` （Firestore が自動生成）

**TTL ポリシー**: 90日後に自動削除（Storage 節約）

**インデックス要件**:
- `date` (ASC)
- `timestamp` (DESC)

---

### **Subcollection: `users/{userId}/pet/decorations` — 所有装飾品**

```json
{
  "decorationId": "hat_crown",
  "name": "クラウン",
  "emoji": "👑",
  "price": 200,
  "purchasedAt": "2026-07-02T10:15:00Z",
  "isEquipped": true
}
```

| フィールド | 型 | 説明 |
|----------|------|------|
| `decorationId` | String | 装飾品ID |
| `name` | String | 日本語名 |
| `emoji` | String | 絵文字 |
| `price` | Integer | コイン価格 |
| `purchasedAt` | Timestamp | 購入日時 |
| `isEquipped` | Boolean | 装備中か |

**ドキュメント ID**: `{decorationId}` （例：`hat_crown`）

**インデックス要件**:
- `purchasedAt` (DESC)

---

## 🎤 2. 1日1フレーズチャレンジスキーマ

### **Collection: `dailyChallenges` — 日替わり出題**

```json
{
  "date": "2026-07-03",
  "phraseId": "phrase_challenge_542",
  "phrase": "What's your favorite color?",
  "romanji": "Wots yuu fevearet caluh?",
  "japaneseTranslation": "あなたの好きな色は何ですか？",
  "category": "shopping",
  "difficulty": "intermediate",
  "createdAt": "2026-07-02T15:00:00Z",
  "scheduledAt": "2026-07-03T07:00:00Z",
  "maxScore": 100,
  "ranking": {
    "totalParticipants": 1250,
    "completed": 1087,
    "completionRate": 0.8696
  }
}
```

| フィールド | 型 | 説明 |
|----------|------|------|
| `date` | String | 日付（YYYY-MM-DD） |
| `phraseId` | String | フレーズID（一意） |
| `phrase` | String | チャレンジフレーズ |
| `romanji` | String | ローマ字表記（参考） |
| `japaneseTranslation` | String | 日本語訳 |
| `category` | String | カテゴリ（会話シーンから） |
| `difficulty` | String | 難易度 |
| `createdAt` | Timestamp | 作成日時 |
| `scheduledAt` | Timestamp | 配信予定時刻（UTC 7:00） |
| `maxScore` | Integer | 満点 |
| `ranking.totalParticipants` | Integer | 参加者総数 |
| `ranking.completed` | Integer | 完了者数 |
| `ranking.completionRate` | Float | 完了率（0.0-1.0） |

**ドキュメント ID**: `{date}` （例：`2026-07-03`）

**インデックス要件**:
- `scheduledAt` (DESC)
- `date` (DESC)

**Cloud Scheduler トリガー**:
```
毎日 07:00 UTC
→ Cloud Function が新規チャレンジドキュメント作成
→ Firebase Admin SDK で集計開始
```

---

### **Subcollection: `dailyChallenges/{date}/scores` — スコア記録**

```json
{
  "userId": "user_abc123",
  "username": "太郎",
  "score": 95,
  "pronunciingScore": 92,
  "timeTaken": 45,
  "submittedAt": "2026-07-03T08:15:30Z",
  "region": "Tokyo",
  "grade": "grade_2",
  "avatarEmoji": "🦜"
}
```

| フィールド | 型 | 説明 |
|----------|------|------|
| `userId` | String | ユーザーID |
| `username` | String | ユーザー名 |
| `score` | Integer | スコア（0-100） |
| `pronunciingScore` | Integer | 発音スコア（0-100） |
| `timeTaken` | Integer | 完了時間（秒） |
| `submittedAt` | Timestamp | 提出日時 |
| `region` | String | 都道府県 |
| `grade` | String | 学年 |
| `avatarEmoji` | String | アバター絵文字 |

**ドキュメント ID**: `{userId}` （1ユーザー = 1スコア）

**リアルタイム表示**: Firestore listener で上位100件をソート

**インデックス要件**:
- `score` (DESC) with `submittedAt` (DESC)
- `region` (ASC), `score` (DESC) — 地域別ランキング用

**TTL ポリシー**: 30日後に自動削除

---

### **Collection: `dailyChallengeStats` — 統計・集計**

```json
{
  "date": "2026-07-03",
  "totalUsers": 1250,
  "totalCompleted": 1087,
  "averageScore": 78.5,
  "medianScore": 82,
  "topScore": 100,
  "bottomScore": 15,
  "completionRate": 0.8696,
  "shareCount": 523,
  "shareRate": 0.481,
  "regionalBreakdown": {
    "tokyo": { "count": 120, "avgScore": 81.2 },
    "osaka": { "count": 95, "avgScore": 79.1 },
    "kyoto": { "count": 42, "avgScore": 75.3 }
  },
  "gradeBreakdown": {
    "grade_1": { "count": 280, "avgScore": 72.1 },
    "grade_2": { "count": 315, "avgScore": 78.5 },
    "grade_3": { "count": 280, "avgScore": 84.2 }
  }
}
```

**ドキュメント ID**: `{date}`

**更新タイミング**: 毎日 23:00 UTC に Cloud Function が集計

---

## 🧑‍🏫 3. 先生ごっこスキーマ

### **Subcollection: `users/{userId}/teacherMode/sessions` — セッション記録**

```json
{
  "sessionId": "session_2026070314301234",
  "startedAt": "2026-07-03T14:30:00Z",
  "endedAt": "2026-07-03T14:48:30Z",
  "totalQuestions": 5,
  "correctAnswers": 4,
  "accuracy": 0.8,
  "totalCoinsEarned": 50,
  "characterFeedback": {
    "positive": ["素晴らしい発音！", "完璧です！", "先生、ありがとう！"],
    "encouragement": "もっと教えてください！"
  }
}
```

| フィールド | 型 | 説明 |
|----------|------|------|
| `sessionId` | String | セッション一意ID |
| `startedAt` | Timestamp | セッション開始 |
| `endedAt` | Timestamp | セッション終了 |
| `totalQuestions` | Integer | 出題数 |
| `correctAnswers` | Integer | 正解数 |
| `accuracy` | Float | 正答率（0.0-1.0） |
| `totalCoinsEarned` | Integer | 獲得コイン合計 |
| `characterFeedback.positive` | Array<String> | AI の褒め言葉（複数） |
| `characterFeedback.encouragement` | String | 激励メッセージ |

**ドキュメント ID**: `auto` （Firestore が自動生成）

**インデックス要件**:
- `startedAt` (DESC)

---

### **Subcollection: `users/{userId}/teacherMode/history` — 問題履歴**

```json
{
  "questionNumber": 1,
  "correctPhrase": "What is your name?",
  "wrongPhrase": "What is you name?",
  "mistakeType": "grammar",
  "userAnswer": "What is your name?",
  "userScore": 85,
  "wasCorrect": true,
  "timestamp": "2026-07-03T14:31:45Z",
  "difficulty": "intermediate"
}
```

| フィールド | 型 | 説明 |
|----------|------|------|
| `questionNumber` | Integer | セッション内の問題番号 |
| `correctPhrase` | String | 正解フレーズ |
| `wrongPhrase` | String | AI が言った間違い |
| `mistakeType` | String | ミスの種類（pronunciation/grammar/semantic） |
| `userAnswer` | String | 子どもの教え方（音声認識結果） |
| `userScore` | Integer | 発音スコア（0-100） |
| `wasCorrect` | Boolean | AI の採点結果 |
| `timestamp` | Timestamp | 質問日時 |
| `difficulty` | String | 難易度 |

**ドキュメント ID**: `auto`

**TTL**: 90日後に自動削除

---

## 💾 4. 既存スキーマとの統合

### **Collection: `users/{userId}` — ユーザープロフィール**

**既存フィールド**：
```json
{
  "userId": "user_abc123",
  "name": "太郎",
  "level": 12,
  "totalExp": 1250,
  "coins": 450,
  "currentStage": 15,
  "createdAt": "2026-01-15T10:00:00Z"
}
```

**v4.0 追加フィールド**：
```json
{
  // 既存フィールド...
  "petCreatedAt": "2026-06-28T09:00:00Z",  // ペット初期化日
  "teacherModeUnlocked": true,              // 先生モード開放済み
  "dailyChallengeOptIn": true,              // チャレンジオプトイン
  "preferredRegion": "tokyo",               // 地域設定
  "preferredGrade": "grade_2"               // 学年設定
}
```

---

## 📊 5. セキュリティルール（Firestore Rules）

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ペット関連：ユーザー本人のみアクセス可
    match /users/{userId}/pet/{document=**} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // 先生ごっこ：ユーザー本人のみ
    match /users/{userId}/teacherMode/{document=**} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // 日替わりチャレンジ：全員読み取り
    match /dailyChallenges/{document=**} {
      allow read: if request.auth != null;
      allow write: if false; // クラウド関数のみが書き込み
    }
    
    // スコアランキング：全員読み取り、自分のみ書き込み
    match /dailyChallenges/{date}/scores/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    // 統計：全員読み取り
    match /dailyChallengeStats/{document=**} {
      allow read: if request.auth != null;
      allow write: if false;
    }
  }
}
```

---

## 🔧 6. Cloud Functions 実装概要

### **Function 1: Daily Challenge 作成**

**トリガー**: Cloud Scheduler （毎日 07:00 UTC）

```dart
// 疑似コード
Future<void> createDailyChallenge() async {
  // 1. Firestore から未使用フレーズを取得
  final phrase = await getUnusedPhrase();
  
  // 2. dailyChallenges/{date} ドキュメント作成
  await firestore.collection('dailyChallenges').doc(date).set({
    'phrase': phrase.text,
    'scheduledAt': Timestamp.now(),
    // ...
  });
  
  // 3. 全ユーザーに通知送信（FCM）
  await sendNotificationToAll(phrase);
}
```

**実装担当**: Week 9（1日1フレーズの Cloud Scheduler 実装時）

---

### **Function 2: スコア集計・ランキング更新**

**トリガー**: Realtime database write トリガー

```dart
Future<void> updateRanking(String date, String userId) async {
  // 1. 日付別の全スコア取得
  final snapshot = await firestore
      .collection('dailyChallenges')
      .doc(date)
      .collection('scores')
      .orderBy('score', descending: true)
      .limit(100)
      .get();
  
  // 2. ランキングドキュメント作成
  await firestore.collection('dailyChallengeStats').doc(date).update({
    'ranking': snapshot.docs.map((doc) => ({
      'rank': snapshot.docs.indexOf(doc) + 1,
      'userId': doc.id,
      'score': doc['score'],
    })).toList(),
  });
}
```

---

## 📈 7. データ保持ポリシー

| コレクション | 保持期間 | 削除方法 | 理由 |
|-----------|--------|--------|------|
| `pet/history` | 90日 | TTL削除 | ストレージ節約 |
| `teacherMode/history` | 90日 | TTL削除 | ストレージ節約 |
| `dailyChallenges/{date}/scores` | 30日 | TTL削除 | ランキング新鮮性保持 |
| `dailyChallengeStats` | 無制限 | 手動 | 長期統計分析用 |
| `pet/decorations` | 無制限 | 手動 | 購入履歴・課金証拠 |

---

## 🧪 8. テストデータセット

### **ペットテストデータ**
```json
{
  "userId": "test_user_1",
  "species": "parrot",
  "level": 15,
  "exp": 75,
  "hunger": 45,
  "happiness": 85,
  "lastFedDate": "2026-07-03T14:30:00Z",
  "createdAt": "2026-06-28T09:00:00Z",
  "evolveDates": ["2026-06-28T09:00:00Z", "2026-07-01T10:30:00Z"]
}
```

### **チャレンジテストデータ**
```json
{
  "date": "2026-07-03",
  "phraseId": "phrase_test_1",
  "phrase": "Hello, how are you?",
  "difficulty": "beginner",
  "scheduledAt": "2026-07-03T07:00:00Z"
}
```

---

## ✅ 実装チェックリスト（Week 8-9）

- [ ] Firestore コレクション作成
- [ ] セキュリティルール適用
- [ ] Cloud Functions デプロイ
- [ ] TTL ポリシー設定
- [ ] バックアップ設定
- [ ] インデックス自動作成確認

---

**次のステップ**: UI プロトタイピング（Week 2）
