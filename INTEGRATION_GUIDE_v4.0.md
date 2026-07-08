# eigo-kore v4.0 既存コード統合ガイド

**作成日**: 2026-07-03  
**バージョン**: v4.0 Week 2-C  

---

## 📊 統合アーキテクチャ

```
┌─────────────────────────────────────────────────────────────┐
│                  lesson_screen.dart                          │
│           (問題タップ → 発音認識 → スコア計算)              │
└───────────────────────┬─────────────────────────────────────┘
                        │
          SpeechService.calculatePronunciationScore()
                (0.0-1.0 を 0-100 に正規化)
                        │
                        ▼
    ┌───────────────────────────────────────┐
    │ PronunciationResult                   │
    │ - word: String                        │
    │ - userPronunciation: String           │
    │ - accuracy: double (0.0-1.0)          │
    │ - isPassed: bool (accuracy >= 0.7)    │
    └─────────────┬──────────────────────────┘
                  │
                  ▼
    ┌──────────────────────────────────────────────────────┐
    │ PronunciationPetIntegrationService.processResult()   │
    │                                                      │
    │ 1. accuracy → pronouncingScore (0-100)             │
    │ 2. feedPetWithScore(score)                         │
    │    → coinsEarned, petLevelUp                       │
    │ 3. addCoins(coinsEarned)                           │
    │ 4. addXp(xpBonus)  [人間レベル]                    │
    └──────────────┬─────────────────────────────────────┘
                   │
         ┌─────────┼─────────┐
         ▼         ▼         ▼
    ┌────────┐ ┌────────┐ ┌──────────┐
    │ Pet    │ │Coin    │ │ Level    │
    │Provider│ │Provider│ │Provider  │
    │        │ │        │ │          │
    │Firestore SharedPref SharedPref│
    └────────┘ └────────┘ └──────────┘
```

---

## 🔗 統合フロー詳細

### **Step 1: 発音スコア計算**

```dart
// lesson_screen.dart: line 183
final s = _speech.calculatePronunciationScore(_current.correctAnswer, text);
// Output: int (0-100)
```

**入力**: 
- `_current.correctAnswer`: 正解フレーズ
- `text`: ユーザーの音声認識結果

**出力**: 
- `s`: 発音スコア (0-100)

**内部ロジック** (`speech_service.dart`):
```dart
// 1. 単語レベルの一致度（60% 重み）
int matchCount = ...;
double wordAccuracy = matchCount / targetWords.length;

// 2. 文字列類似度（40% 重み）
double charAccuracy = 1.0 - (levenshtein_distance / max_length);

// 加重平均 → (0.0-1.0) × 100
return (wordAccuracy * 0.6 + charAccuracy * 0.4) * 100;
```

---

### **Step 2: ペット統合処理**

```dart
// lesson_screen.dart: line 196
_feedPetFromScore(s, text);
```

**実装内容**:
```dart
Future<void> _feedPetFromScore(int pronouncingScore, String recognizedText) async {
  // スコア 60 未満はスキップ
  if (pronouncingScore < 60) return;

  // PronunciationResult オブジェクト作成
  final accuracy = pronouncingScore / 100.0;  // 0.0-1.0 に正規化
  final result = PronunciationResult(
    word: _current.correctAnswer,
    userPronunciation: recognizedText,
    accuracy: accuracy,  // 0.0-1.0
    feedback: '',
    isPassed: accuracy >= 0.7,
  );

  // 統合サービス実行
  final feedbackResult = await ref
      .read(pronunciationPetIntegrationProvider)
      .processResult(
        pronunciationResult: result,
        userId: userId,
      );
}
```

---

### **Step 3: PetNotifier へのフィード**

```dart
// pet_provider.dart
Future<int> feedPetWithScore(int pronouncingScore) async {
  // 発音スコア 60+ でのみ実行
  if (pronouncingScore >= 60) {
    // hunger: -10
    int newHunger = (hunger - 10).clamp(0, 100);
    
    // exp: +10-14 (スコアに基づくボーナス)
    int scoreBonus = (pronouncingScore - 60) ~/ 10;  // 0-4
    int newExp = exp + 10 + scoreBonus;
    
    // コイン計算: 10-30
    int coinsEarned = 10 + (scoreBonus * 5);
    
    // レベルアップ判定
    while (newExp >= 100) {
      newExp -= 100;
      level++;
      // 進化判定 (level 5, 15, 25)
    }
    
    // Firestore 保存
    await firestore.update(...);
    
    return coinsEarned;
  }
  return 0;
}
```

**返却値**: `coinsEarned` (10-30 コイン)

---

### **Step 4: コイン加算**

```dart
// pronunciation_pet_integration_service.dart
await ref.read(coinProvider.notifier).addCoins(coinsFromPet);
```

**実装** (`coin_provider.dart`):
```dart
Future<void> addCoins(int amount) async {
  final prefs = await SharedPreferences.getInstance();
  final newTotal = state.totalCoins + amount;
  await prefs.setInt(_coinKey, newTotal);
  state = state.copyWith(totalCoins: newTotal);
}
```

---

### **Step 5: 人間レベル XP ボーナス**

```dart
// pronunciation_pet_integration_service.dart
final xpBonus = _calculateXpBonus(pronouncingScore);
await ref.read(levelProvider.notifier).addXp(xpBonus);
```

**XP ボーナス計算**:
```dart
int _calculateXpBonus(int pronouncingScore) {
  if (pronouncingScore < 60) return 0;
  
  // 60: 5XP, 70: 10XP, 80: 12XP, 90: 15XP
  return 5 + ((pronouncingScore - 60) ~/ 10) * 2;
}
```

**実装** (`level_provider.dart`):
```dart
Future<int> addXp(int amount) async {
  state = state.copyWith(totalXp: state.totalXp + amount);
  await prefs.setInt(_key, state.totalXp);
  return state.level - prevLevel;  // レベルアップ数
}
```

---

## 📋 データフロー表

| ステップ | 入力値 | 処理 | 出力値 | 保存先 |
|--------|---------|------|---------|--------|
| 1 | 発音認識テキスト | Speech score計算 | 0-100 | メモリ |
| 2 | pronouncing score (0-100) | ペットフィード | hunger-10, exp+10-14 | Firestore |
| 3 | coinsEarned | コイン加算 | totalCoins+10-30 | SharedPref |
| 4 | xpBonus (0-15) | XP加算 | totalXp+0-15 | SharedPref |
| 5 | level check | Level UP判定 | level+1 or 0 | SharedPref |

---

## 🎯 統合ポイント一覧

### **ファイル1: lesson_screen.dart**

**修正箇所**:
- Line 13-16: インポート追加 (pronunciation_pet_integration_service)
- Line 196: `_feedPetFromScore(s, text)` 呼び出し追加
- Line 202-240: `_feedPetFromScore()` メソッド実装

**動作**:
- 発音スコア >= 60 の場合のみペット処理実行
- 各問題終了後、スナックバー表示でフィードバック

---

### **ファイル2: pronunciation_pet_integration_service.dart**

**役割**: 3つのプロバイダーを統合

```dart
class PronunciationPetIntegrationService {
  Future<PronunciationFeedbackResult> processResult({
    required PronunciationResult pronunciationResult,
    required String userId,
  }) async {
    // 1. ペットフィード
    final coinsFromPet = await petNotifier.feedPetWithScore(score);
    
    // 2. コイン加算
    await coinNotifier.addCoins(coinsFromPet);
    
    // 3. XP加算（人間レベル）
    await levelNotifier.addXp(xpBonus);
    
    // 4. フィードバック生成
    return PronunciationFeedbackResult(...);
  }
}
```

---

### **ファイル3: pet_model.dart & pet_provider.dart**

**既存実装を使用**:
- `PetModel.feedPetWithScore(int score)`: メソッド
- `PetNotifier.feedPetWithScore()`: Firestore同期処理
- `PetEvolutionStage.fromLevel()`: 進化判定ロジック

---

## 🧪 テストケース

### **テスト1: スコア 60 未満 → フィード不可**
```dart
// Input: pronouncingScore = 55
// Expected: coinsEarned = 0, hunger = unchanged, exp = unchanged
```

### **テスト2: スコア 60-70 → 基本報酬**
```dart
// Input: pronouncingScore = 65
// Expected: coinsEarned = 10, hunger = -10, exp = +11, xpBonus = 5
```

### **テスト3: スコア 80-90 → ボーナス報酬**
```dart
// Input: pronouncingScore = 85
// Expected: coinsEarned = 20, hunger = -10, exp = +12, xpBonus = 10
```

### **テスト4: レベルアップ判定**
```dart
// Input: exp = 95, pronouncingScore = 80
// Expected: exp becomes 7 (95+12-100), level += 1
```

---

## 🚀 デプロイメント チェックリスト

- [ ] `pronunciation_pet_integration_service.dart` デプロイ
- [ ] `lesson_screen.dart` 修正確認
- [ ] インポート順序確認
- [ ] ローカルテスト（発音スコア 60+ の場合）
- [ ] コイン加算確認（SharedPreferences）
- [ ] ペット状態確認（Firestore）
- [ ] XP加算確認（レベルプロバイダー）

---

## 📌 次フェーズ（Week 3 以降）

### **Phase 2-A: 先生ごっこ実装**
- Claude API 統合（`claude_teacher_service.dart`）
- 「間違い方」生成テスト（100フレーズ）

### **Phase 3-A: 1日1フレーズ実装**
- Cloud Scheduler 設定
- Firestore リアルタイムランキング
- 画像生成（シェア機能）

---

**開発チェックポイント**: 2026-07-07 までに Week 2 完了予定

