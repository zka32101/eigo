import '../models/question.dart';

// ────────────────────────────────────────────────────────────────────────────
// Stage 91-100: 動物（拡張10ステージ）
// ────────────────────────────────────────────────────────────────────────────

final stage91Questions = <Question>[
  const Question(
    id: 's91_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Cat', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🐱',
    choices: ['犬', '猫', 'ウサギ', 'ねずみ'], correctAnswer: '猫', phonetic: '/kæt/',
  ),
  const Question(
    id: 's91_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Dog', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🐕',
    choices: ['猫', '犬', 'ウサギ', 'ねずみ'], correctAnswer: '犬', phonetic: '/dɔːɡ/',
  ),
  const Question(
    id: 's91_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Rabbit', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🐰',
    choices: ['ねずみ', 'ウサギ', 'リス', 'モルモット'], correctAnswer: 'ウサギ', phonetic: '/ˈræbət/',
  ),
  const Question(
    id: 's91_l4', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Bird', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🐦',
    choices: ['蜂', '鳥', 'バッタ', 'トンボ'], correctAnswer: '鳥', phonetic: '/bɜːrd/',
  ),
  const Question(
    id: 's91_l5', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Fish', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🐟',
    choices: ['カニ', 'エビ', '魚', 'イカ'], correctAnswer: '魚', phonetic: '/fɪʃ/',
  ),
];

final stage92Questions = <Question>[
  const Question(
    id: 's92_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Cow', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🐄',
    choices: ['馬', '牛', 'ヤギ', 'ヒツジ'], correctAnswer: '牛', phonetic: '/kaʊ/',
  ),
  const Question(
    id: 's92_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Horse', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🐴',
    choices: ['ロバ', '馬', 'ポニー', 'シマウマ'], correctAnswer: '馬', phonetic: '/hɔːrs/',
  ),
  const Question(
    id: 's92_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Elephant', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🐘',
    choices: ['ライオン', 'キリン', '象', 'サイ'], correctAnswer: '象', phonetic: '/ˈɛləfənt/',
  ),
  const Question(
    id: 's92_l4', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Lion', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🦁',
    choices: ['虎', 'ライオン', 'ヒョウ', 'チーター'], correctAnswer: 'ライオン', phonetic: '/ˈlaɪən/',
  ),
  const Question(
    id: 's92_l5', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Tiger', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🐯',
    choices: ['ライオン', '虎', 'ヒョウ', 'チーター'], correctAnswer: '虎', phonetic: '/ˈtaɪɡər/',
  ),
];

final stage93Questions = <Question>[
  const Question(
    id: 's93_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Bear', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🐻',
    choices: ['狼', '熊', 'オス', 'パンダ'], correctAnswer: '熊', phonetic: '/bɛr/',
  ),
  const Question(
    id: 's93_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Panda', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🐼',
    choices: ['熊', 'パンダ', 'レッサーパンダ', 'クマ'], correctAnswer: 'パンダ', phonetic: '/ˈpændə/',
  ),
  const Question(
    id: 's93_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Monkey', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🐵',
    choices: ['ゴリラ', '猿', 'チンパンジー', 'テナガザル'], correctAnswer: '猿', phonetic: '/ˈmʌŋki/',
  ),
  const Question(
    id: 's93_l4', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Giraffe', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🦒',
    choices: ['シマウマ', 'キリン', 'ヌー', 'インパラ'], correctAnswer: 'キリン', phonetic: '/dʒəˈræf/',
  ),
  const Question(
    id: 's93_l5', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Penguin', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🐧',
    choices: ['カモメ', 'ペンギン', 'フラミンゴ', 'オウム'], correctAnswer: 'ペンギン', phonetic: '/ˈpɛŋɡwɪn/',
  ),
];

final stage94Questions = <Question>[
  const Question(
    id: 's94_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Butterfly', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🦋',
    choices: ['トンボ', 'チョウチョウ', 'ハチ', 'バッタ'], correctAnswer: 'チョウチョウ', phonetic: '/ˈbʌtərflaɪ/',
  ),
  const Question(
    id: 's94_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Bee', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🐝',
    choices: ['蜂', 'アリ', 'トンボ', 'クモ'], correctAnswer: '蜂', phonetic: '/biː/',
  ),
  const Question(
    id: 's94_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Spider', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🕷️',
    choices: ['蜂', 'アリ', 'クモ', 'ムカデ'], correctAnswer: 'クモ', phonetic: '/ˈspaɪdər/',
  ),
  const Question(
    id: 's94_l4', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Snake', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🐍',
    choices: ['トカゲ', 'ヘビ', 'ワニ', 'カメ'], correctAnswer: 'ヘビ', phonetic: '/sneɪk/',
  ),
  const Question(
    id: 's94_l5', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Turtle', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🐢',
    choices: ['カエル', 'カメ', 'ワニ', 'トカゲ'], correctAnswer: 'カメ', phonetic: '/ˈtɜːrtəl/',
  ),
];

final stage95Questions = <Question>[
  const Question(
    id: 's95_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Dolphin', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🐬',
    choices: ['イルカ', 'クジラ', 'オットセイ', 'アシカ'], correctAnswer: 'イルカ', phonetic: '/ˈdɑːlfən/',
  ),
  const Question(
    id: 's95_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Whale', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🐋',
    choices: ['イルカ', 'クジラ', 'シャチ', 'アザラシ'], correctAnswer: 'クジラ', phonetic: '/weɪl/',
  ),
  const Question(
    id: 's95_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Shark', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🦈',
    choices: ['マンタ', 'サメ', 'エイ', 'イルカ'], correctAnswer: 'サメ', phonetic: '/ʃɑːrk/',
  ),
  const Question(
    id: 's95_l4', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Frog', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🐸',
    choices: ['オタマジャクシ', 'カエル', 'トカゲ', 'サンショウウオ'], correctAnswer: 'カエル', phonetic: '/frɔːɡ/',
  ),
  const Question(
    id: 's95_l5', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Lizard', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🦎',
    choices: ['ヘビ', 'トカゲ', 'カメ', 'イグアナ'], correctAnswer: 'トカゲ', phonetic: '/ˈlɪzərd/',
  ),
];

final stage96Questions = <Question>[
  const Question(
    id: 's96_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Pig', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🐷',
    choices: ['牛', 'ブタ', 'ヒツジ', 'ヤギ'], correctAnswer: 'ブタ', phonetic: '/pɪɡ/',
  ),
  const Question(
    id: 's96_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Sheep', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🐑',
    choices: ['ヤギ', 'ヒツジ', 'ロバ', 'ウマ'], correctAnswer: 'ヒツジ', phonetic: '/ʃiːp/',
  ),
  const Question(
    id: 's96_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Goat', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🐐',
    choices: ['ヒツジ', 'ヤギ', 'ロバ', '牛'], correctAnswer: 'ヤギ', phonetic: '/ɡoʊt/',
  ),
  const Question(
    id: 's96_l4', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Duck', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🦆',
    choices: ['ニワトリ', 'アヒル', 'ガチョウ', 'カモメ'], correctAnswer: 'アヒル', phonetic: '/dʌk/',
  ),
  const Question(
    id: 's96_l5', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Chicken', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🐔',
    choices: ['アヒル', 'ニワトリ', 'ガチョウ', 'シチメンチョウ'], correctAnswer: 'ニワトリ', phonetic: '/ˈtʃɪkən/',
  ),
];

final stage97Questions = <Question>[
  const Question(
    id: 's97_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Wolf', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🐺',
    choices: ['犬', '狼', 'キツネ', 'ハイエナ'], correctAnswer: '狼', phonetic: '/wʊlf/',
  ),
  const Question(
    id: 's97_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Fox', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🦊',
    choices: ['狼', 'キツネ', 'ハイエナ', 'ジャッカル'], correctAnswer: 'キツネ', phonetic: '/fɑːks/',
  ),
  const Question(
    id: 's97_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Deer', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🦌',
    choices: ['シマウマ', 'インパラ', '鹿', 'エルク'], correctAnswer: '鹿', phonetic: '/dɪr/',
  ),
  const Question(
    id: 's97_l4', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Zebra', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🦓',
    choices: ['ロバ', 'シマウマ', 'ウマ', 'ポニー'], correctAnswer: 'シマウマ', phonetic: '/ˈziːbrə/',
  ),
  const Question(
    id: 's97_l5', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Squirrel', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🐿️',
    choices: ['リス', 'ネズミ', 'モグラ', 'ハリネズミ'], correctAnswer: 'リス', phonetic: '/ˈskwɪrəl/',
  ),
];

final stage98Questions = <Question>[
  const Question(
    id: 's98_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Hamster', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🐹',
    choices: ['ハムスター', 'ネズミ', 'モルモット', 'ウサギ'], correctAnswer: 'ハムスター', phonetic: '/ˈhæmstər/',
  ),
  const Question(
    id: 's98_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Guinea pig', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🐹',
    choices: ['ハムスター', 'モルモット', 'ウサギ', 'ネズミ'], correctAnswer: 'モルモット', phonetic: '/ˈɡɪni pɪɡ/',
  ),
  const Question(
    id: 's98_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Hedgehog', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🦔',
    choices: ['ハリネズミ', 'リス', 'モグラ', 'アナグマ'], correctAnswer: 'ハリネズミ', phonetic: '/ˈhɛdʒhoɡ/',
  ),
  const Question(
    id: 's98_l4', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Bat', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🦇',
    choices: ['鳥', 'コウモリ', 'トンボ', '蜂'], correctAnswer: 'コウモリ', phonetic: '/bæt/',
  ),
  const Question(
    id: 's98_l5', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Owl', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🦉',
    choices: ['ワシ', 'フクロウ', 'タカ', 'トビ'], correctAnswer: 'フクロウ', phonetic: '/aʊl/',
  ),
];

final stage99Questions = <Question>[
  const Question(
    id: 's99_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Camel', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🐪',
    choices: ['ラクダ', 'トナカイ', 'シマウマ', 'ヌー'], correctAnswer: 'ラクダ', phonetic: '/ˈkæməl/',
  ),
  const Question(
    id: 's99_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Reindeer', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🦌',
    choices: ['ラクダ', 'トナカイ', '鹿', 'ムース'], correctAnswer: 'トナカイ', phonetic: '/ˈreɪndɪr/',
  ),
  const Question(
    id: 's99_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Kangaroo', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🦘',
    choices: ['カンガルー', 'コアラ', 'ディンゴ', 'ワラビー'], correctAnswer: 'カンガルー', phonetic: '/ˌkæŋɡəˈruː/',
  ),
  const Question(
    id: 's99_l4', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Koala', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🐨',
    choices: ['カンガルー', 'コアラ', 'オーストラリアンデビル', 'ワンバット'], correctAnswer: 'コアラ', phonetic: '/koʊˈɑːlə/',
  ),
  const Question(
    id: 's99_l5', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Sloth', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🦥',
    choices: ['ナマケモノ', 'リス', 'モンキー', 'オランウータン'], correctAnswer: 'ナマケモノ', phonetic: '/sloʊθ/',
  ),
];

final stage100Questions = <Question>[
  const Question(
    id: 's100_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Cheetah', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🐆',
    choices: ['ジャガー', 'チーター', 'ヒョウ', 'ライオン'], correctAnswer: 'チーター', phonetic: '/ˈtʃiːtə/',
  ),
  const Question(
    id: 's100_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Leopard', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🐆',
    choices: ['チーター', 'ヒョウ', 'ジャガー', 'ライオン'], correctAnswer: 'ヒョウ', phonetic: '/ˈlɛpərd/',
  ),
  const Question(
    id: 's100_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Rhino', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🦏',
    choices: ['サイ', 'カバ', '象', '水牛'], correctAnswer: 'サイ', phonetic: '/ˈraɪnoʊ/',
  ),
  const Question(
    id: 's100_l4', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Hippo', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🦛',
    choices: ['サイ', 'カバ', '象', 'ヌー'], correctAnswer: 'カバ', phonetic: '/ˈhɪpoʊ/',
  ),
  const Question(
    id: 's100_l5', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Peacock', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🦚',
    choices: ['クジャク', 'ニワトリ', 'ダチョウ', 'フラミンゴ'], correctAnswer: 'クジャク', phonetic: '/ˈpiːkɑːk/',
  ),
];
