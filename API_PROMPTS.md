# eigo-kore v4.0 Claude API プロンプト設計

**作成日**: 2026-07-03  
**対象機能**: 先生ごっこモード + ペット育成（インタラクション）  
**モデル**: Claude 3.5 Haiku (fast)  

---

## 🧑‍🏫 先生ごっこモード：「間違い方」ジェネレーター

このプロンプトは、子どもが教える相手となる AI 生徒が「わざと間違えた言い方」を生成します。

### **API エンドポイント**

```
POST /api/v1/messages
Model: claude-3-5-haiku-20241022
Max Tokens: 300
Temperature: 0.7 (変動性：難易度に応じた自然なバリエーション)
```

### **基本テンプレート**

```dart
// lib/services/claude_api_service.dart

Future<TeacherModeResponse> generateWrongPhrase({
  required String correctPhrase,
  required String japaneseTranslation,
  required DifficultyLevel difficulty,
  required int level, // ユーザーレベル 1-30
}) async {
  final prompt = _buildTeacherPrompt(
    correctPhrase,
    japaneseTranslation,
    difficulty,
    level,
  );

  final response = await client.messages.create(
    model: 'claude-3-5-haiku-20241022',
    maxTokens: 300,
    temperature: 0.7,
    messages: [
      Message(
        role: 'user',
        content: prompt,
      ),
    ],
  );

  return _parseResponse(response.content[0].text);
}
```

---

### **難易度別プロンプト仕様**

#### **1️⃣ 初級（Level 1-10）：発音・アクセントミス**

**プロンプト本体**:

```
You are a student character in an English learning app for elementary school children (grades 1-6).
The child is teaching you English. Your role is to deliberately make a SMALL mistake 
so the child can teach you the correct way.

Correct phrase: "[PHRASE]"
Japanese meaning: "[TRANSLATION]"
Difficulty level: BEGINNER
User's current level: [LEVEL]/30

Create a SMALL mistake in pronunciation or word stress that a beginner might make.
The mistake should be:
- Easy to spot (wrong accent/stress on a word)
- Not too difficult to correct
- Natural for a beginner learner
- Entertaining but educational

IMPORTANT: Output ONLY a JSON object with NO markdown formatting:
{
  "mistake": "[The wrong phrase the student says]",
  "mistakeType": "pronunciation",
  "explanation": "[Brief explanation of why this is wrong - in Japanese for clarity]",
  "correction": "[The correct way to say it]",
  "teachingTip": "[A hint about why this happens - to help the child understand common mistakes]"
}

Example:
{"mistake":"Whot is your neim?","mistakeType":"pronunciation","explanation":"「ゆっくり話しすぎている」という初心者の典型的なミスです","correction":"What is your name?","teachingTip":"英語のリズムは日本語とは違います。単語と単語をスムーズにつなげることが大切です。"}
```

**パラメータ**:
- `[PHRASE]`: 正解フレーズ（例："What is your name?"）
- `[TRANSLATION]`: 日本語訳（例："あなたの名前は何ですか？"）
- `[LEVEL]`: ユーザーレベル（1-30）

**出力例**:
```json
{
  "mistake": "What is your neim?",
  "mistakeType": "pronunciation",
  "explanation": "最後の単語で o と ei を混同している初心者のミス",
  "correction": "What is your name?",
  "teachingTip": "name のように -ame で終わる単語は /eɪm/ と発音します。日本語の「ネーム」ではなく、口を大きく開けて「neim」と言いましょう。"
}
```

---

#### **2️⃣ 中級（Level 11-20）：文法ミス**

**プロンプト本体**:

```
You are a student character in an English learning app.
The child is teaching you. Your role is to make a MEDIUM-level grammar mistake.

Correct phrase: "[PHRASE]"
Japanese meaning: "[TRANSLATION]"
Difficulty level: INTERMEDIATE
User's current level: [LEVEL]/30

Create a grammar mistake typical of intermediate learners:
- Tense confusion (past/present)
- Subject-verb disagreement
- Missing auxiliary verbs
- Wrong prepositions
- Wrong word order

The mistake should be:
- Clearly grammatically wrong (not a pronunciation mistake)
- Something the child will feel proud teaching you to fix
- Natural and educational

Output ONLY a JSON object:
{
  "mistake": "[Wrong sentence]",
  "mistakeType": "grammar",
  "explanation": "[Why this is wrong - in Japanese]",
  "correction": "[Correct sentence]",
  "teachingTip": "[Grammar rule the child should explain back to you]"
}

Example:
{"mistake":"I goes to school tomorrow.","mistakeType":"grammar","explanation":"主語が I なので go を使わないといけません","correction":"I go to school tomorrow.","teachingTip":"主語が1人称・2人称・複数形の場合は「go」、3人称単数の場合は「goes」を使います。Remember: He/She/It → goes!"}
```

**出力例**:
```json
{
  "mistake": "She go to school every day.",
  "mistakeType": "grammar",
  "explanation": "3人称単数形の主語 She に対して、動詞を goes にしないといけません",
  "correction": "She goes to school every day.",
  "teachingTip": "He, She, It には『s』をつけます！He eats, She plays, It is — これを覚えていれば大丈夫です。"
}
```

---

#### **3️⃣ 上級（Level 21-30）：意味ミス + 複雑な文法**

**プロンプト本体**:

```
You are an advanced student character.
The child is teaching you English at an advanced level.

Correct phrase: "[PHRASE]"
Japanese meaning: "[TRANSLATION]"
Difficulty level: ADVANCED
User's current level: [LEVEL]/30

Create a DIFFICULT mistake:
- Semantic confusion (wrong word used correctly, but meaning is wrong)
- Complex tense mistakes
- Subtle word choice mistakes
- Missing implied grammar in conversation

The mistake should:
- Be subtle enough that an advanced learner would notice
- Require explanation to understand
- Make the child feel genuinely accomplished for teaching

Output ONLY JSON:
{
  "mistake": "[Wrong phrase or sentence]",
  "mistakeType": "semantic",
  "explanation": "[Why this is wrong - in Japanese, be detailed]",
  "correction": "[Correct phrase]",
  "teachingTip": "[Deep explanation of the rule or cultural context]"
}

Example:
{"mistake":"I'm boring with this book.","mistakeType":"semantic","explanation":"bore と bore.d を混同しています。主語が人間なら bored, 主語が物なら boring です","correction":"I'm bored with this book.","teachingTip":"『退屈させる側』は boring, 『退屈を感じる側』は bored です。This movie is boring. I am bored. で使い分けます。"}
```

**出力例**:
```json
{
  "mistake": "I am boring of studying English.",
  "mistakeType": "semantic",
  "explanation": "be bored of で「〜に飽きた」という意味ですが、boring は「退屈させる」という意味です。また of ではなく with が正しい用法です",
  "correction": "I am bored with studying English.",
  "teachingTip": "✓ I am bored with... = 〜に飽きている\n✗ I am boring = 私は人を退屈させる人です\nBoring は『退屈させる側』、bored は『退屈を感じている側』です。"
}
```

---

## 🎭 ペット育成：「朝呼びかけ」フレーズジェネレーター

朝通知時に、ペットが学んだ単語を使って子どもに呼びかけます。

### **API テンプレート**

```dart
Future<PetGreetingResponse> generateMorningGreeting({
  required String petName,
  required PetSpecies species,
  required List<String> recentlyLearnedWords,
  required int petLevel,
}) async {
  final prompt = '''
子どもが英語を学ぶアプリの中のペットキャラクターです。
子どもはあなたのペットと一緒に英語を学んでいます。

ペット情報:
- 名前: $petName
- 種類: ${species.displayName}
- レベル: $petLevel

最近学んだ英単語: ${recentlyLearnedWords.take(3).join(", ")}

朝(7:00AM)に子どもを起こす時のセリフを作成してください。
要件:
1. ペットのキャラクターらしい可愛らしい表現
2. 最近学んだ単語を1-2個織り交ぜる
3. 英語と日本語を混ぜる（子どもは英語初心者）
4. 5文以下（短く、読みやすく）
5. JSON形式で出力

{"greeting": "[English + Japanese]", "emoji": "[ペットに合ったemoji]"}
  ''';

  // API呼び出しと解析
}
```

---

## 🔧 実装サンプル（Dart）

```dart
// lib/services/claude_teacher_service.dart

import 'package:anthropic_sdk/anthropic_sdk.dart';

class ClaudeTeacherService {
  final Anthropic _client;

  ClaudeTeacherService({required Anthropic client}) : _client = client;

  /// 先生ごっこモード：間違い方を生成
  Future<TeacherModePhrase> generateMistakePhrase({
    required String correctPhrase,
    required String japaneseTranslation,
    required DifficultyLevel difficulty,
    required int userLevel,
  }) async {
    final difficultyText = _difficultyToText(difficulty);
    
    final prompt = '''
You are a student character in an English learning app for elementary school children.
The child is teaching you. Make a deliberate mistake they can correct.

Correct phrase: "$correctPhrase"
Japanese meaning: "$japaneseTranslation"
Difficulty: $difficultyText
User level: $userLevel/30

Create a ${difficultyText.toLowerCase()} mistake.
Output ONLY JSON:
{
  "mistake": "[wrong phrase]",
  "mistakeType": "[pronunciation/grammar/semantic]",
  "explanation": "[why wrong - in Japanese]",
  "correction": "[correct phrase]",
  "teachingTip": "[hint for the child]"
}
''';

    try {
      final message = await _client.messages.create(
        model: 'claude-3-5-haiku-20241022',
        maxTokens: 300,
        temperature: 0.7,
        messages: [
          Message(role: 'user', content: prompt),
        ],
      );

      final jsonText = message.content[0].type == 'text'
          ? message.content[0].text
          : '';
      
      return TeacherModePhrase.fromJson(jsonDecode(jsonText));
    } catch (e) {
      // フォールバック：プリセット間違いを返す
      return _getPresetMistake(correctPhrase, difficulty);
    }
  }

  String _difficultyToText(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.beginner:
        return 'BEGINNER (pronunciation/accent)';
      case DifficultyLevel.intermediate:
        return 'INTERMEDIATE (grammar)';
      case DifficultyLevel.advanced:
        return 'ADVANCED (semantic/complex)';
    }
  }

  /// フォールバック：API呼び出し失敗時の代替データ
  TeacherModePhrase _getPresetMistake(String phrase, DifficultyLevel level) {
    // プリセット辞書から返す（例：phrase_mistake_presets.dart）
    return TeacherModePhrase(
      mistake: 'API error - preset used',
      mistakeType: 'fallback',
      explanation: 'インターネット接続がない場合',
      correction: phrase,
      teachingTip: 'オフラインモードです',
    );
  }
}

// モデルクラス
class TeacherModePhrase {
  final String mistake;
  final String mistakeType;
  final String explanation;
  final String correction;
  final String teachingTip;

  TeacherModePhrase({
    required this.mistake,
    required this.mistakeType,
    required this.explanation,
    required this.correction,
    required this.teachingTip,
  });

  factory TeacherModePhrase.fromJson(Map<String, dynamic> json) {
    return TeacherModePhrase(
      mistake: json['mistake'] as String,
      mistakeType: json['mistakeType'] as String,
      explanation: json['explanation'] as String,
      correction: json['correction'] as String,
      teachingTip: json['teachingTip'] as String,
    );
  }
}

enum DifficultyLevel { beginner, intermediate, advanced }
```

---

## 📊 API 呼び出し頻度・コスト概算

| 機能 | 月間呼び出し | 入力トークン | 出力トークン | 月額概算 |
|-----|----------|----------|----------|--------|
| 先生ごっこ（毎回） | 1000 | 150 | 100 | ¥150 |
| 朝グリーティング（毎日） | 30 | 100 | 50 | ¥30 |
| **合計** | **1030** | | | **¥180** |

**💡 Haiku は ¥0.8/1M input tokens, ¥2.4/1M output tokens**

---

## ✅ テスト計画

### **Unit テスト**
```dart
test('generateMistakePhrase_beginner_返す発音ミス', () async {
  // 初級で「発音ミス」が返されることを確認
  final response = await service.generateMistakePhrase(
    correctPhrase: 'Apple',
    japaneseTranslation: 'りんご',
    difficulty: DifficultyLevel.beginner,
    userLevel: 3,
  );
  
  expect(response.mistakeType, 'pronunciation');
  expect(response.correction, 'Apple');
});

test('generateMistakePhrase_advanced_セマンティックミス', () async {
  // 上級で「意味ミス」が返されることを確認
  final response = await service.generateMistakePhrase(
    correctPhrase: 'I am interested in learning English',
    japaneseTranslation: '英語の勉強に興味があります',
    difficulty: DifficultyLevel.advanced,
    userLevel: 28,
  );
  
  expect(response.mistakeType, 'semantic');
});
```

### **統合テスト**
- API呼び出し成功時の返却値形式確認
- エラーハンドリング（タイムアウト、無効なJSON）
- オフラインモード：プリセット辞書への動的フォールバック

---

## 🚀 本番運用チェックリスト

- [ ] Claude API キーが環境変数に設定されている
- [ ] レート制限対応（10 req/sec）
- [ ] タイムアウト設定（10秒）
- [ ] エラーログ記録（Sentry 連携）
- [ ] API 応答テスト（100サンプル）

---

**次のステップ**: Firestore DB スキーマ設計 → UI プロトタイピング
