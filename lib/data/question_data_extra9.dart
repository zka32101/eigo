import '../models/question.dart';

// ────────────────────────────────────────────────────────────────────────────
// Stage 101-110: 色・形（拡張10ステージ）
// ────────────────────────────────────────────────────────────────────────────

final stage101Questions = <Question>[
  const Question(
    id: 's101_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Blue', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🔵',
    choices: ['赤', '青', '黄色', '緑'], correctAnswer: '青', phonetic: '/bluː/',
  ),
  const Question(
    id: 's101_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Red', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🔴',
    choices: ['赤', '青', '黄色', 'ピンク'], correctAnswer: '赤', phonetic: '/rɛd/',
  ),
  const Question(
    id: 's101_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Yellow', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🟡',
    choices: ['黄色', 'オレンジ', '緑', '白'], correctAnswer: '黄色', phonetic: '/ˈjɛloʊ/',
  ),
  const Question(
    id: 's101_l4', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Green', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🟢',
    choices: ['青', '緑', '黄色', 'ターコイズ'], correctAnswer: '緑', phonetic: '/ɡriːn/',
  ),
  const Question(
    id: 's101_l5', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'White', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '⚪',
    choices: ['黒', '白', 'グレー', 'ベージュ'], correctAnswer: '白', phonetic: '/waɪt/',
  ),
];

final stage102Questions = <Question>[
  const Question(
    id: 's102_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Black', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '⬛',
    choices: ['黒', '白', 'グレー', '紫'], correctAnswer: '黒', phonetic: '/blæk/',
  ),
  const Question(
    id: 's102_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Orange', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🟠',
    choices: ['赤', 'オレンジ', '黄色', 'ピンク'], correctAnswer: 'オレンジ', phonetic: '/ˈɔːrɪndʒ/',
  ),
  const Question(
    id: 's102_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Purple', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🟣',
    choices: ['紫', 'ピンク', 'マゼンタ', 'バイオレット'], correctAnswer: '紫', phonetic: '/ˈpɜːrpəl/',
  ),
  const Question(
    id: 's102_l4', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Pink', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🌸',
    choices: ['赤', 'オレンジ', 'ピンク', '紫'], correctAnswer: 'ピンク', phonetic: '/pɪŋk/',
  ),
  const Question(
    id: 's102_l5', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Brown', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🟤',
    choices: ['黒', '茶色', 'グレー', 'ベージュ'], correctAnswer: '茶色', phonetic: '/braʊn/',
  ),
];

final stage103Questions = <Question>[
  const Question(
    id: 's103_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Gray', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '⚫',
    choices: ['黒', '白', 'グレー', '茶色'], correctAnswer: 'グレー', phonetic: '/ɡreɪ/',
  ),
  const Question(
    id: 's103_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Circle', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '⭕',
    choices: ['三角形', '円', '四角形', '星'], correctAnswer: '円', phonetic: '/ˈsɜːrkəl/',
  ),
  const Question(
    id: 's103_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Square', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '⬜',
    choices: ['三角形', '円', '四角形', '長方形'], correctAnswer: '四角形', phonetic: '/skwɛr/',
  ),
  const Question(
    id: 's103_l4', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Triangle', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '△',
    choices: ['四角形', '三角形', '円', '長方形'], correctAnswer: '三角形', phonetic: '/ˈtraɪæŋɡəl/',
  ),
  const Question(
    id: 's103_l5', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Star', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '⭐',
    choices: ['月', '星', '太陽', 'クラウド'], correctAnswer: '星', phonetic: '/stɑːr/',
  ),
];

final stage104Questions = <Question>[
  const Question(
    id: 's104_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Rectangle', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '▭',
    choices: ['四角形', '長方形', '三角形', '円'], correctAnswer: '長方形', phonetic: '/ˈrɛktæŋɡəl/',
  ),
  const Question(
    id: 's104_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Heart', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '❤️',
    choices: ['星', '心臓', 'ダイヤモンド', 'クローバー'], correctAnswer: '心臓', phonetic: '/hɑːrt/',
  ),
  const Question(
    id: 's104_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Diamond', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '♦️',
    choices: ['心臓', 'ダイヤモンド', 'クローバー', 'スペード'], correctAnswer: 'ダイヤモンド', phonetic: '/ˈdaɪəmənd/',
  ),
  const Question(
    id: 's104_l4', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Pentagon', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '⬠',
    choices: ['六角形', '五角形', '四角形', '三角形'], correctAnswer: '五角形', phonetic: '/ˈpɛntəɡɑːn/',
  ),
  const Question(
    id: 's104_l5', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Hexagon', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '⬡',
    choices: ['五角形', '六角形', '八角形', '四角形'], correctAnswer: '六角形', phonetic: '/ˈhɛksəɡɑːn/',
  ),
];

final stage105Questions = <Question>[
  const Question(
    id: 's105_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Big', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '📏',
    choices: ['大きい', '小さい', '長い', '短い'], correctAnswer: '大きい', phonetic: '/bɪɡ/',
  ),
  const Question(
    id: 's105_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Small', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '📎',
    choices: ['大きい', '小さい', '太い', 'ほっそい'], correctAnswer: '小さい', phonetic: '/smɔːl/',
  ),
  const Question(
    id: 's105_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Thick', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '📚',
    choices: ['薄い', '太い', '長い', '短い'], correctAnswer: '太い', phonetic: '/θɪk/',
  ),
  const Question(
    id: 's105_l4', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Thin', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '📄',
    choices: ['太い', 'ほっそい', '厚い', '広い'], correctAnswer: 'ほっそい', phonetic: '/θɪn/',
  ),
  const Question(
    id: 's105_l5', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Long', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '📏',
    choices: ['短い', '長い', '太い', '小さい'], correctAnswer: '長い', phonetic: '/lɔːŋ/',
  ),
];

final stage106Questions = <Question>[
  const Question(
    id: 's106_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Short', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '📏',
    choices: ['長い', '短い', '低い', '高い'], correctAnswer: '短い', phonetic: '/ʃɔːrt/',
  ),
  const Question(
    id: 's106_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Tall', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '📐',
    choices: ['低い', '高い', '短い', '太い'], correctAnswer: '高い', phonetic: '/tɔːl/',
  ),
  const Question(
    id: 's106_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Wide', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '◻️',
    choices: ['狭い', '広い', '短い', '長い'], correctAnswer: '広い', phonetic: '/waɪd/',
  ),
  const Question(
    id: 's106_l4', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Narrow', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '▯',
    choices: ['広い', '狭い', '太い', 'ほっそい'], correctAnswer: '狭い', phonetic: '/ˈnæroʊ/',
  ),
  const Question(
    id: 's106_l5', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Round', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '⭕',
    choices: ['四角い', '丸い', '三角い', 'ぎざぎざ'], correctAnswer: '丸い', phonetic: '/raʊnd/',
  ),
];

final stage107Questions = <Question>[
  const Question(
    id: 's107_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Straight', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '➖',
    choices: ['曲がった', 'まっすぐ', 'ぎざぎざ', 'らせん状'], correctAnswer: 'まっすぐ', phonetic: '/streɪt/',
  ),
  const Question(
    id: 's107_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Curved', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '➰',
    choices: ['まっすぐ', '曲がった', 'ぎざぎざ', '角ばった'], correctAnswer: '曲がった', phonetic: '/kɜːrvd/',
  ),
  const Question(
    id: 's107_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Flat', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '▭',
    choices: ['立体的', 'でこぼこ', '平らな', 'うねうねした'], correctAnswer: '平らな', phonetic: '/flæt/',
  ),
  const Question(
    id: 's107_l4', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Rough', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🪨',
    choices: ['なめらかな', 'ざらざら', '滑らかな', 'つるつるした'], correctAnswer: 'ざらざら', phonetic: '/rʌf/',
  ),
  const Question(
    id: 's107_l5', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Smooth', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '💎',
    choices: ['ざらざら', 'なめらかな', 'でこぼこ', 'ぎざぎざ'], correctAnswer: 'なめらかな', phonetic: '/smuːð/',
  ),
];

final stage108Questions = <Question>[
  const Question(
    id: 's108_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Sharp', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🔪',
    choices: ['丸い', '鋭い', '太い', 'もたもたした'], correctAnswer: '鋭い', phonetic: '/ʃɑːrp/',
  ),
  const Question(
    id: 's108_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Dull', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '☁️',
    choices: ['輝く', 'くすんだ', '鮮やかな', '淡い'], correctAnswer: 'くすんだ', phonetic: '/dʌl/',
  ),
  const Question(
    id: 's108_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Bright', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '⭐',
    choices: ['暗い', '明るい', 'くすんだ', '淡い'], correctAnswer: '明るい', phonetic: '/braɪt/',
  ),
  const Question(
    id: 's108_l4', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Dark', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🌙',
    choices: ['明るい', '暗い', 'くすんだ', '淡い'], correctAnswer: '暗い', phonetic: '/dɑːrk/',
  ),
  const Question(
    id: 's108_l5', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Light', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '💡',
    choices: ['暗い', '軽い', '重い', '淡い'], correctAnswer: '軽い', phonetic: '/laɪt/',
  ),
];

final stage109Questions = <Question>[
  const Question(
    id: 's109_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Heavy', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '⚖️',
    choices: ['軽い', '重い', 'かさばる', '小さい'], correctAnswer: '重い', phonetic: '/ˈhɛvi/',
  ),
  const Question(
    id: 's109_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Transparent', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '💎',
    choices: ['透明な', '不透明な', '曇った', '白濁した'], correctAnswer: '透明な', phonetic: '/trænsˈpɛrənt/',
  ),
  const Question(
    id: 's109_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Opaque', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🪵',
    choices: ['透明な', '不透明な', 'つやつやした', 'でこぼこ'], correctAnswer: '不透明な', phonetic: '/oʊˈpeɪk/',
  ),
  const Question(
    id: 's109_l4', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Shiny', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '✨',
    choices: ['くすんだ', 'つやつやした', 'ざらざら', 'なめらかな'], correctAnswer: 'つやつやした', phonetic: '/ˈʃaɪni/',
  ),
  const Question(
    id: 's109_l5', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Matte', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '📦',
    choices: ['つやつやした', 'つや消しの', '光沢のある', 'きらきらした'], correctAnswer: 'つや消しの', phonetic: '/mæt/',
  ),
];

final stage110Questions = <Question>[
  const Question(
    id: 's110_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Rainbow', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🌈',
    choices: ['日没', '虹', '空', '雲'], correctAnswer: '虹', phonetic: '/ˈreɪnboʊ/',
  ),
  const Question(
    id: 's110_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Pattern', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🎨',
    choices: ['色', '形', 'パターン', 'デザイン'], correctAnswer: 'パターン', phonetic: '/ˈpætərn/',
  ),
  const Question(
    id: 's110_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Stripe', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '🟦',
    choices: ['ドット', 'しま', '格子', 'プリント'], correctAnswer: 'しま', phonetic: '/straɪp/',
  ),
  const Question(
    id: 's110_l4', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Polka dot', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '⚫',
    choices: ['しま', 'ドット', '格子', 'チェック'], correctAnswer: 'ドット', phonetic: '/ˈpoʊlkə dɑːt/',
  ),
  const Question(
    id: 's110_l5', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Checkered', textJa: '次の英語を聞いて、正しい意味を選ぼう', imageEmoji: '📋',
    choices: ['ドット', 'しま', 'チェック', 'プリント'], correctAnswer: 'チェック', phonetic: '/ˈtʃɛkərd/',
  ),
];
