import '../models/question.dart';

// ────────────────────────────────────────────────────────────────────────────
// Stage 81-90: 食べ物（拡張10ステージ）- 既存ステージの質問を再利用
// ────────────────────────────────────────────────────────────────────────────

final stage81Questions = <Question>[
  const Question(
    id: 's81_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Rice', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🍚',
    choices: ['お米', 'パン', 'パスタ', 'じゃがいも'], correctAnswer: 'お米', phonetic: '/raɪs/',
  ),
  const Question(
    id: 's81_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Eggs', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🥚',
    choices: ['肉', '卵', '魚', 'チーズ'], correctAnswer: '卵', phonetic: '/ɛɡz/',
  ),
  const Question(
    id: 's81_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Bread', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🍞',
    choices: ['パスタ', 'パン', 'お米', 'ジャム'], correctAnswer: 'パン', phonetic: '/brɛd/',
  ),
  const Question(
    id: 's81_l4', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Milk', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🥛',
    choices: ['水', 'ジュース', 'ミルク', 'ココア'], correctAnswer: 'ミルク', phonetic: '/mɪlk/',
  ),
  const Question(
    id: 's81_l5', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Chicken', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🍗',
    choices: ['豚肉', '牛肉', '鶏肉', '羊肉'], correctAnswer: '鶏肉', phonetic: '/ˈtʃɪkən/',
  ),
];

final stage82Questions = <Question>[
  const Question(
    id: 's82_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Pizza', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🍕',
    choices: ['ピザ', 'ハンバーガー', 'カレー', 'スシ'], correctAnswer: 'ピザ', phonetic: '/ˈpiːtsə/',
  ),
  const Question(
    id: 's82_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Apple', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🍎',
    choices: ['ミカン', 'バナナ', 'リンゴ', 'ぶどう'], correctAnswer: 'リンゴ', phonetic: '/ˈæpəl/',
  ),
  const Question(
    id: 's82_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Orange', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🍊',
    choices: ['リンゴ', 'ミカン', 'グレープフルーツ', 'レモン'], correctAnswer: 'ミカン', phonetic: '/ˈɔːrɪndʒ/',
  ),
  const Question(
    id: 's82_l4', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Banana', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🍌',
    choices: ['ぶどう', 'バナナ', 'スイカ', 'パイナップル'], correctAnswer: 'バナナ', phonetic: '/bəˈnænə/',
  ),
  const Question(
    id: 's82_l5', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Soup', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🍲',
    choices: ['スープ', 'カレー', 'シチュー', 'みそ汁'], correctAnswer: 'スープ', phonetic: '/suːp/',
  ),
];

final stage83Questions = <Question>[
  const Question(
    id: 's83_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Chocolate', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🍫',
    choices: ['アイスクリーム', 'チョコレート', 'キャンディ', 'クッキー'], correctAnswer: 'チョコレート', phonetic: '/ˈtʃɔːklət/',
  ),
  const Question(
    id: 's83_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Candy', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🍭',
    choices: ['チョコ', 'ガム', 'キャンディ', 'チューイングガム'], correctAnswer: 'キャンディ', phonetic: '/ˈkændi/',
  ),
  const Question(
    id: 's83_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Ice cream', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🍦',
    choices: ['ケーキ', 'プリン', 'アイスクリーム', 'ヨーグルト'], correctAnswer: 'アイスクリーム', phonetic: '/ˈaɪs ˌkriːm/',
  ),
  const Question(
    id: 's83_l4', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Cake', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🎂',
    choices: ['ケーキ', 'ドーナツ', 'クッキー', 'パイ'], correctAnswer: 'ケーキ', phonetic: '/keɪk/',
  ),
  const Question(
    id: 's83_l5', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Cookie', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🍪',
    choices: ['ケーキ', 'クッキー', 'ドーナツ', 'パイ'], correctAnswer: 'クッキー', phonetic: '/ˈkʊki/',
  ),
];

final stage84Questions = <Question>[
  const Question(
    id: 's84_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Tea', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '☕',
    choices: ['コーヒー', 'お茶', 'ジュース', 'ココア'], correctAnswer: 'お茶', phonetic: '/tiː/',
  ),
  const Question(
    id: 's84_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Coffee', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '☕',
    choices: ['紅茶', 'コーヒー', 'ココア', 'ジュース'], correctAnswer: 'コーヒー', phonetic: '/ˈkɔːfi/',
  ),
  const Question(
    id: 's84_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Water', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '💧',
    choices: ['ミルク', 'ジュース', '水', 'お茶'], correctAnswer: '水', phonetic: '/ˈwɔːtər/',
  ),
  const Question(
    id: 's84_l4', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Juice', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🧃',
    choices: ['ジュース', 'ソーダ', 'ミルク', 'ココア'], correctAnswer: 'ジュース', phonetic: '/dʒuːs/',
  ),
  const Question(
    id: 's84_l5', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Soda', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🥤',
    choices: ['ジュース', 'ソーダ', 'ビール', 'ワイン'], correctAnswer: 'ソーダ', phonetic: '/ˈsoʊdə/',
  ),
];

final stage85Questions = <Question>[
  const Question(
    id: 's85_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Fish', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🐟',
    choices: ['肉', '魚', 'エビ', 'カニ'], correctAnswer: '魚', phonetic: '/fɪʃ/',
  ),
  const Question(
    id: 's85_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Shrimp', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🦐',
    choices: ['カニ', 'エビ', 'イカ', 'タコ'], correctAnswer: 'エビ', phonetic: '/ʃrɪmp/',
  ),
  const Question(
    id: 's85_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Sushi', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🍣',
    choices: ['てんぷら', '寿司', 'そば', 'ラーメン'], correctAnswer: '寿司', phonetic: '/ˈsuːʃi/',
  ),
  const Question(
    id: 's85_l4', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Noodles', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🍜',
    choices: ['ご飯', '麺', 'パン', 'スープ'], correctAnswer: '麺', phonetic: '/ˈnuːdəlz/',
  ),
  const Question(
    id: 's85_l5', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Salad', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🥗',
    choices: ['スープ', 'サラダ', 'スチュー', 'カレー'], correctAnswer: 'サラダ', phonetic: '/ˈsæləd/',
  ),
];

final stage86Questions = <Question>[
  const Question(
    id: 's86_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Meat', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🥩',
    choices: ['魚', '肉', '野菜', 'チーズ'], correctAnswer: '肉', phonetic: '/miːt/',
  ),
  const Question(
    id: 's86_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Cheese', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🧀',
    choices: ['バター', 'チーズ', 'クリーム', 'ヨーグルト'], correctAnswer: 'チーズ', phonetic: '/tʃiːz/',
  ),
  const Question(
    id: 's86_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Butter', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🧈',
    choices: ['油', 'バター', 'クリーム', 'マーガリン'], correctAnswer: 'バター', phonetic: '/ˈbʌtər/',
  ),
  const Question(
    id: 's86_l4', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Vegetable', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🥕',
    choices: ['果物', '野菜', '肉', '穀物'], correctAnswer: '野菜', phonetic: '/ˈvɛdʒtəbəl/',
  ),
  const Question(
    id: 's86_l5', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Fruit', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🍓',
    choices: ['野菜', '果物', '花', '木'], correctAnswer: '果物', phonetic: '/fruːt/',
  ),
];

final stage87Questions = <Question>[
  const Question(
    id: 's87_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Corn', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🌽',
    choices: ['にんじん', 'とうもろこし', 'キャベツ', 'ブロッコリー'], correctAnswer: 'とうもろこし', phonetic: '/kɔːrn/',
  ),
  const Question(
    id: 's87_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Carrot', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🥕',
    choices: ['ジャガイモ', 'にんじん', 'たまねぎ', 'トマト'], correctAnswer: 'にんじん', phonetic: '/ˈkærət/',
  ),
  const Question(
    id: 's87_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Tomato', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🍅',
    choices: ['キュウリ', 'ピーマン', 'トマト', 'ナス'], correctAnswer: 'トマト', phonetic: '/təˈmeɪtoʊ/',
  ),
  const Question(
    id: 's87_l4', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Potato', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🥔',
    choices: ['にんじん', 'ジャガイモ', 'たまねぎ', 'とうもろこし'], correctAnswer: 'ジャガイモ', phonetic: '/pəˈteɪtoʊ/',
  ),
  const Question(
    id: 's87_l5', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Broccoli', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🥦',
    choices: ['キャベツ', 'ブロッコリー', 'ほうれん草', 'レタス'], correctAnswer: 'ブロッコリー', phonetic: '/ˈbrɑːkəli/',
  ),
];

final stage88Questions = <Question>[
  const Question(
    id: 's88_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Pineapple', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🍍',
    choices: ['パイナップル', 'メロン', 'スイカ', 'マンゴー'], correctAnswer: 'パイナップル', phonetic: '/ˈpaɪnæpəl/',
  ),
  const Question(
    id: 's88_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Watermelon', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🍉',
    choices: ['メロン', 'スイカ', 'ぶどう', 'マンゴー'], correctAnswer: 'スイカ', phonetic: '/ˈwɔːtərˌmɛlən/',
  ),
  const Question(
    id: 's88_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Grape', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🍇',
    choices: ['いちご', 'ぶどう', 'プラム', 'ブルーベリー'], correctAnswer: 'ぶどう', phonetic: '/ɡreɪp/',
  ),
  const Question(
    id: 's88_l4', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Strawberry', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🍓',
    choices: ['ブルーベリー', 'いちご', 'ラズベリー', 'クランベリー'], correctAnswer: 'いちご', phonetic: '/ˈstrɔːbɛri/',
  ),
  const Question(
    id: 's88_l5', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Mango', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🥭',
    choices: ['パパイヤ', 'マンゴー', 'ココナッツ', 'バナナ'], correctAnswer: 'マンゴー', phonetic: '/ˈmæŋɡoʊ/',
  ),
];

final stage89Questions = <Question>[
  const Question(
    id: 's89_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Honey', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🍯',
    choices: ['砂糖', 'はちみつ', 'ジャム', 'シロップ'], correctAnswer: 'はちみつ', phonetic: '/ˈhʌni/',
  ),
  const Question(
    id: 's89_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Sugar', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🍬',
    choices: ['塩', '砂糖', '砂', 'スパイス'], correctAnswer: '砂糖', phonetic: '/ˈʃʊɡər/',
  ),
  const Question(
    id: 's89_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Salt', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🧂',
    choices: ['砂糖', '塩', 'こしょう', 'スパイス'], correctAnswer: '塩', phonetic: '/sɔːlt/',
  ),
  const Question(
    id: 's89_l4', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Oil', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🫒',
    choices: ['水', '油', 'バター', 'クリーム'], correctAnswer: '油', phonetic: '/ɔɪl/',
  ),
  const Question(
    id: 's89_l5', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Flour', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🌾',
    choices: ['砂糖', '小麦粉', '塩', 'デンプン'], correctAnswer: '小麦粉', phonetic: '/ˈflaʊər/',
  ),
];

final stage90Questions = <Question>[
  const Question(
    id: 's90_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Egg', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🥚',
    choices: ['肉', '卵', '牛乳', 'チーズ'], correctAnswer: '卵', phonetic: '/ɛɡ/',
  ),
  const Question(
    id: 's90_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Jam', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🍓',
    choices: ['はちみつ', 'ジャム', 'マーマレード', 'ペースト'], correctAnswer: 'ジャム', phonetic: '/dʒæm/',
  ),
  const Question(
    id: 's90_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Peanut', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🥜',
    choices: ['クルミ', 'ピーナッツ', 'アーモンド', 'ココナッツ'], correctAnswer: 'ピーナッツ', phonetic: '/ˈpiːnʌt/',
  ),
  const Question(
    id: 's90_l4', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Nut', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🥜',
    choices: ['シード', 'ナッツ', 'ベリー', 'フルーツ'], correctAnswer: 'ナッツ', phonetic: '/nʌt/',
  ),
  const Question(
    id: 's90_l5', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Yogurt', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🥛',
    choices: ['チーズ', 'バター', 'ヨーグルト', 'アイスクリーム'], correctAnswer: 'ヨーグルト', phonetic: '/ˈjoʊɡərt/',
  ),
];
