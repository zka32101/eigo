import '../models/question.dart';

// ─── Stage 1: Greetings（あいさつ） ────────────────────────────────────────

final stage1Questions = <Question>[
  // リスニング (7問 = 35%)
  const Question(
    id: 's1_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Hello', textJa: '次の英語を聞いて、正しい意味を選ぼう',
    imageEmoji: '👋',
    choices: ['こんにちは', 'さようなら', 'ありがとう', 'おはよう'],
    correctAnswer: 'こんにちは', phonetic: '/həˈloʊ/',
  ),
  const Question(
    id: 's1_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Good morning', textJa: '次の英語を聞いて、正しい意味を選ぼう',
    imageEmoji: '🌅',
    choices: ['おやすみ', 'おはよう', 'こんばんは', 'こんにちは'],
    correctAnswer: 'おはよう', phonetic: '/ɡʊd ˈmɔːrnɪŋ/',
  ),
  const Question(
    id: 's1_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Good night', textJa: '次の英語を聞いて、正しい意味を選ぼう',
    imageEmoji: '🌙',
    choices: ['おはよう', 'こんにちは', 'おやすみ', 'さようなら'],
    correctAnswer: 'おやすみ', phonetic: '/ɡʊd naɪt/',
  ),
  const Question(
    id: 's1_l4', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Thank you', textJa: '次の英語を聞いて、正しい意味を選ぼう',
    imageEmoji: '🙏',
    choices: ['ごめんなさい', 'どういたしまして', 'ありがとう', 'よろしく'],
    correctAnswer: 'ありがとう', phonetic: '/θæŋk juː/',
  ),
  const Question(
    id: 's1_l5', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: "You're welcome", textJa: '次の英語を聞いて、正しい意味を選ぼう',
    imageEmoji: '😊',
    choices: ['ありがとう', 'どういたしまして', 'すみません', 'はじめまして'],
    correctAnswer: 'どういたしまして', phonetic: '/jɔːr ˈwɛlkəm/',
  ),
  const Question(
    id: 's1_l6', type: QuestionType.listening, difficulty: DifficultyLevel.intermediate,
    text: 'How are you?', textJa: '次の英語を聞いて、正しい意味を選ぼう',
    imageEmoji: '🤔',
    choices: ['名前はなんですか？', 'いくつですか？', 'げんきですか？', 'どこですか？'],
    correctAnswer: 'げんきですか？', phonetic: '/haʊ ɑːr juː/',
  ),
  const Question(
    id: 's1_l7', type: QuestionType.listening, difficulty: DifficultyLevel.intermediate,
    text: 'Nice to meet you', textJa: '次の英語を聞いて、正しい意味を選ぼう',
    imageEmoji: '🤝',
    choices: ['さようなら', 'またね', 'はじめまして', 'よかったね'],
    correctAnswer: 'はじめまして', phonetic: '/naɪs tə miːt juː/',
  ),

  // スピーキング (8問 = 40%)
  const Question(
    id: 's1_s1', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'Hello', textJa: 'こんにちは、と英語で言ってみよう',
    imageEmoji: '👋', correctAnswer: 'Hello', phonetic: '/həˈloʊ/',
  ),
  const Question(
    id: 's1_s2', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'Good morning', textJa: 'おはようございます、と英語で言ってみよう',
    imageEmoji: '🌅', correctAnswer: 'Good morning', phonetic: '/ɡʊd ˈmɔːrnɪŋ/',
  ),
  const Question(
    id: 's1_s3', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'Thank you', textJa: 'ありがとう、と英語で言ってみよう',
    imageEmoji: '🙏', correctAnswer: 'Thank you', phonetic: '/θæŋk juː/',
  ),
  const Question(
    id: 's1_s4', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'Good night', textJa: 'おやすみ、と英語で言ってみよう',
    imageEmoji: '🌙', correctAnswer: 'Good night', phonetic: '/ɡʊd naɪt/',
  ),
  const Question(
    id: 's1_s5', type: QuestionType.speaking, difficulty: DifficultyLevel.intermediate,
    text: 'How are you?', textJa: 'げんきですか？と英語で言ってみよう',
    imageEmoji: '🤔', correctAnswer: 'How are you?', phonetic: '/haʊ ɑːr juː/',
  ),
  const Question(
    id: 's1_s6', type: QuestionType.speaking, difficulty: DifficultyLevel.intermediate,
    text: "I'm fine, thank you", textJa: 'げんきです、ありがとう、と英語で言ってみよう',
    imageEmoji: '😊', correctAnswer: "I'm fine, thank you", phonetic: '/aɪm faɪn θæŋk juː/',
  ),
  const Question(
    id: 's1_s7', type: QuestionType.speaking, difficulty: DifficultyLevel.intermediate,
    text: 'Nice to meet you', textJa: 'はじめまして、と英語で言ってみよう',
    imageEmoji: '🤝', correctAnswer: 'Nice to meet you', phonetic: '/naɪs tə miːt juː/',
  ),
  const Question(
    id: 's1_s8', type: QuestionType.speaking, difficulty: DifficultyLevel.advanced,
    text: "What's your name?", textJa: '名前はなんですか？と英語で聞いてみよう',
    imageEmoji: '❓', correctAnswer: "What's your name?", phonetic: '/wɒts jɔːr neɪm/',
  ),

  // リーディング (3問 = 15%)
  const Question(
    id: 's1_r1', type: QuestionType.reading, difficulty: DifficultyLevel.beginner,
    text: 'Hello', textJa: '次の英語の意味を選ぼう',
    imageEmoji: '👋',
    choices: ['こんにちは', 'さようなら', 'ありがとう'],
    correctAnswer: 'こんにちは',
  ),
  const Question(
    id: 's1_r2', type: QuestionType.reading, difficulty: DifficultyLevel.beginner,
    text: 'Good morning', textJa: '次の英語の意味を選ぼう',
    imageEmoji: '🌅',
    choices: ['おはよう', 'こんにちは', 'おやすみ'],
    correctAnswer: 'おはよう',
  ),
  const Question(
    id: 's1_r3', type: QuestionType.reading, difficulty: DifficultyLevel.beginner,
    text: 'Thank you', textJa: '次の英語の意味を選ぼう',
    imageEmoji: '🙏',
    choices: ['すみません', 'ありがとう', 'どういたしまして'],
    correctAnswer: 'ありがとう',
  ),

  // ライティング (2問 = 10%)
  const Question(
    id: 's1_w1', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'こんにちは', textJa: '日本語を英語にしよう',
    choices: ['Hello', 'Goodbye', 'Thank you'],
    correctAnswer: 'Hello',
  ),
  const Question(
    id: 's1_w2', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'ありがとう', textJa: '日本語を英語にしよう',
    choices: ['Sorry', 'Thank you', 'Hello'],
    correctAnswer: 'Thank you',
  ),
];

// ─── Stage 2: Numbers（数字） ─────────────────────────────────────────────

final stage2Questions = <Question>[
  // リスニング (7問)
  const Question(
    id: 's2_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'One', textJa: '数字を聞いて、正しいものを選ぼう',
    imageEmoji: '1️⃣',
    choices: ['1', '2', '3', '4'], correctAnswer: '1', phonetic: '/wʌn/',
  ),
  const Question(
    id: 's2_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Five', textJa: '数字を聞いて、正しいものを選ぼう',
    imageEmoji: '5️⃣',
    choices: ['3', '4', '5', '6'], correctAnswer: '5', phonetic: '/faɪv/',
  ),
  const Question(
    id: 's2_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Ten', textJa: '数字を聞いて、正しいものを選ぼう',
    imageEmoji: '🔟',
    choices: ['8', '9', '10', '11'], correctAnswer: '10', phonetic: '/tɛn/',
  ),
  const Question(
    id: 's2_l4', type: QuestionType.listening, difficulty: DifficultyLevel.intermediate,
    text: 'Twelve', textJa: '数字を聞いて、正しいものを選ぼう',
    imageEmoji: '🔢',
    choices: ['11', '12', '13', '14'], correctAnswer: '12', phonetic: '/twɛlv/',
  ),
  const Question(
    id: 's2_l5', type: QuestionType.listening, difficulty: DifficultyLevel.intermediate,
    text: 'Twenty', textJa: '数字を聞いて、正しいものを選ぼう',
    imageEmoji: '🔢',
    choices: ['20', '30', '40', '50'], correctAnswer: '20', phonetic: '/ˈtwɛnti/',
  ),
  const Question(
    id: 's2_l6', type: QuestionType.listening, difficulty: DifficultyLevel.intermediate,
    text: 'How old are you?', textJa: '質問を聞いて、何を聞かれているか選ぼう',
    imageEmoji: '🎂',
    choices: ['名前を聞いている', '年齢を聞いている', '住所を聞いている', '好きな食べ物を聞いている'],
    correctAnswer: '年齢を聞いている', phonetic: '/haʊ oʊld ɑːr juː/',
  ),
  const Question(
    id: 's2_l7', type: QuestionType.listening, difficulty: DifficultyLevel.advanced,
    text: "I'm eight years old", textJa: '何歳か聞いて、正しいものを選ぼう',
    imageEmoji: '🎈',
    choices: ['6歳', '7歳', '8歳', '9歳'], correctAnswer: '8歳', phonetic: '/aɪm eɪt jɪrz oʊld/',
  ),

  // スピーキング (8問)
  const Question(
    id: 's2_s1', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'One, two, three', textJa: '1、2、3を英語で言ってみよう',
    imageEmoji: '🔢', correctAnswer: 'One two three', phonetic: '/wʌn tuː θriː/',
  ),
  const Question(
    id: 's2_s2', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'Four, five, six', textJa: '4、5、6を英語で言ってみよう',
    imageEmoji: '🔢', correctAnswer: 'Four five six', phonetic: '/fɔːr faɪv sɪks/',
  ),
  const Question(
    id: 's2_s3', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'Seven, eight, nine, ten', textJa: '7から10を英語で言ってみよう',
    imageEmoji: '🔢', correctAnswer: 'Seven eight nine ten', phonetic: '/ˈsɛvən eɪt naɪn tɛn/',
  ),
  const Question(
    id: 's2_s4', type: QuestionType.speaking, difficulty: DifficultyLevel.intermediate,
    text: 'Eleven, twelve', textJa: '11、12を英語で言ってみよう',
    imageEmoji: '🔢', correctAnswer: 'Eleven twelve', phonetic: '/ɪˈlɛvən twɛlv/',
  ),
  const Question(
    id: 's2_s5', type: QuestionType.speaking, difficulty: DifficultyLevel.intermediate,
    text: 'Twenty, thirty', textJa: '20、30を英語で言ってみよう',
    imageEmoji: '🔢', correctAnswer: 'Twenty thirty', phonetic: '/ˈtwɛnti ˈθɜːrti/',
  ),
  const Question(
    id: 's2_s6', type: QuestionType.speaking, difficulty: DifficultyLevel.intermediate,
    text: 'How old are you?', textJa: '何歳ですか？と英語で聞いてみよう',
    imageEmoji: '🎂', correctAnswer: 'How old are you?', phonetic: '/haʊ oʊld ɑːr juː/',
  ),
  const Question(
    id: 's2_s7', type: QuestionType.speaking, difficulty: DifficultyLevel.advanced,
    text: "I'm eight years old", textJa: '私は8歳です、と英語で言ってみよう',
    imageEmoji: '🎈', correctAnswer: "I'm eight years old", phonetic: '/aɪm eɪt jɪrz oʊld/',
  ),
  const Question(
    id: 's2_s8', type: QuestionType.speaking, difficulty: DifficultyLevel.advanced,
    text: "What's your phone number?", textJa: '電話番号は何番ですか？と言ってみよう',
    imageEmoji: '📱', correctAnswer: "What's your phone number?", phonetic: '/wɒts jɔːr foʊn ˈnʌmbər/',
  ),

  // リーディング (3問)
  const Question(
    id: 's2_r1', type: QuestionType.reading, difficulty: DifficultyLevel.beginner,
    text: 'Three', textJa: '数字を英語で読もう',
    choices: ['2', '3', '4'], correctAnswer: '3',
  ),
  const Question(
    id: 's2_r2', type: QuestionType.reading, difficulty: DifficultyLevel.beginner,
    text: 'Eight', textJa: '数字を英語で読もう',
    choices: ['6', '7', '8'], correctAnswer: '8',
  ),
  const Question(
    id: 's2_r3', type: QuestionType.reading, difficulty: DifficultyLevel.intermediate,
    text: 'Fifteen', textJa: '数字を英語で読もう',
    choices: ['13', '14', '15'], correctAnswer: '15',
  ),

  // ライティング (2問)
  const Question(
    id: 's2_w1', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: '7（Seven）', textJa: '7を英語で書こう',
    choices: ['Six', 'Seven', 'Eight'], correctAnswer: 'Seven',
  ),
  const Question(
    id: 's2_w2', type: QuestionType.writing, difficulty: DifficultyLevel.intermediate,
    text: '12（Twelve）', textJa: '12を英語で書こう',
    choices: ['Eleven', 'Twelve', 'Thirteen'], correctAnswer: 'Twelve',
  ),
];

// ─── Stage 3: Colors（色） ────────────────────────────────────────────────

final stage3Questions = <Question>[
  const Question(
    id: 's3_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Red', textJa: '色を聞いて選ぼう', imageEmoji: '🔴',
    choices: ['赤', '青', '黄色', '緑'], correctAnswer: '赤', phonetic: '/rɛd/',
  ),
  const Question(
    id: 's3_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Blue', textJa: '色を聞いて選ぼう', imageEmoji: '🔵',
    choices: ['赤', '青', '黄色', '緑'], correctAnswer: '青', phonetic: '/bluː/',
  ),
  const Question(
    id: 's3_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Yellow', textJa: '色を聞いて選ぼう', imageEmoji: '🟡',
    choices: ['赤', '青', '黄色', '緑'], correctAnswer: '黄色', phonetic: '/ˈjɛloʊ/',
  ),
  const Question(
    id: 's3_l4', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Green', textJa: '色を聞いて選ぼう', imageEmoji: '🟢',
    choices: ['紫', '緑', 'ピンク', 'オレンジ'], correctAnswer: '緑', phonetic: '/ɡriːn/',
  ),
  const Question(
    id: 's3_l5', type: QuestionType.listening, difficulty: DifficultyLevel.intermediate,
    text: 'Purple', textJa: '色を聞いて選ぼう', imageEmoji: '🟣',
    choices: ['紫', '茶色', '黒', '白'], correctAnswer: '紫', phonetic: '/ˈpɜːrpəl/',
  ),
  const Question(
    id: 's3_l6', type: QuestionType.listening, difficulty: DifficultyLevel.intermediate,
    text: 'What color is this?', textJa: '質問を聞いて答えよう（🍎）',
    imageEmoji: '🍎',
    choices: ['Blue', 'Red', 'Green', 'Yellow'], correctAnswer: 'Red', phonetic: '/wɒt kʌlər ɪz ðɪs/',
  ),
  const Question(
    id: 's3_l7', type: QuestionType.listening, difficulty: DifficultyLevel.advanced,
    text: 'My favorite color is pink', textJa: '好きな色を聞いて選ぼう',
    imageEmoji: '🩷',
    choices: ['Red', 'Purple', 'Pink', 'Orange'], correctAnswer: 'Pink', phonetic: '/maɪ ˈfeɪvərɪt kʌlər ɪz pɪŋk/',
  ),
  const Question(
    id: 's3_s1', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'Red', textJa: '赤を英語で言ってみよう', imageEmoji: '🔴',
    correctAnswer: 'Red', phonetic: '/rɛd/',
  ),
  const Question(
    id: 's3_s2', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'Blue', textJa: '青を英語で言ってみよう', imageEmoji: '🔵',
    correctAnswer: 'Blue', phonetic: '/bluː/',
  ),
  const Question(
    id: 's3_s3', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'Yellow', textJa: '黄色を英語で言ってみよう', imageEmoji: '🟡',
    correctAnswer: 'Yellow', phonetic: '/ˈjɛloʊ/',
  ),
  const Question(
    id: 's3_s4', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'Green', textJa: '緑を英語で言ってみよう', imageEmoji: '🟢',
    correctAnswer: 'Green', phonetic: '/ɡriːn/',
  ),
  const Question(
    id: 's3_s5', type: QuestionType.speaking, difficulty: DifficultyLevel.intermediate,
    text: 'Orange and purple', textJa: 'オレンジと紫を英語で言ってみよう', imageEmoji: '🟠',
    correctAnswer: 'Orange and purple', phonetic: '/ˈɔːrɪndʒ ænd ˈpɜːrpəl/',
  ),
  const Question(
    id: 's3_s6', type: QuestionType.speaking, difficulty: DifficultyLevel.intermediate,
    text: "What color is this?", textJa: 'これは何色ですか？と英語で言ってみよう', imageEmoji: '❓',
    correctAnswer: "What color is this?", phonetic: '/wɒt kʌlər ɪz ðɪs/',
  ),
  const Question(
    id: 's3_s7', type: QuestionType.speaking, difficulty: DifficultyLevel.intermediate,
    text: 'My favorite color is blue', textJa: '私の好きな色は青です、と言ってみよう', imageEmoji: '💙',
    correctAnswer: 'My favorite color is blue', phonetic: '/maɪ ˈfeɪvərɪt kʌlər ɪz bluː/',
  ),
  const Question(
    id: 's3_s8', type: QuestionType.speaking, difficulty: DifficultyLevel.advanced,
    text: 'What is your favorite color?', textJa: '好きな色は何ですか？と英語で聞いてみよう', imageEmoji: '🎨',
    correctAnswer: 'What is your favorite color?', phonetic: '/wɒt ɪz jɔːr ˈfeɪvərɪt kʌlər/',
  ),
  const Question(
    id: 's3_r1', type: QuestionType.reading, difficulty: DifficultyLevel.beginner,
    text: 'Red', textJa: '英語の色の名前を読もう', imageEmoji: '🔴',
    choices: ['赤', '青', '緑'], correctAnswer: '赤',
  ),
  const Question(
    id: 's3_r2', type: QuestionType.reading, difficulty: DifficultyLevel.beginner,
    text: 'Yellow', textJa: '英語の色の名前を読もう', imageEmoji: '🟡',
    choices: ['赤', '黄色', '緑'], correctAnswer: '黄色',
  ),
  const Question(
    id: 's3_r3', type: QuestionType.reading, difficulty: DifficultyLevel.intermediate,
    text: 'Purple', textJa: '英語の色の名前を読もう', imageEmoji: '🟣',
    choices: ['ピンク', '紫', 'オレンジ'], correctAnswer: '紫',
  ),
  const Question(
    id: 's3_w1', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: '青（Blue）', textJa: '青を英語で選ぼう',
    choices: ['Green', 'Blue', 'Red'], correctAnswer: 'Blue',
  ),
  const Question(
    id: 's3_w2', type: QuestionType.writing, difficulty: DifficultyLevel.intermediate,
    text: '紫（Purple）', textJa: '紫を英語で選ぼう',
    choices: ['Pink', 'Orange', 'Purple'], correctAnswer: 'Purple',
  ),
];

// ─── Stage 4: Animals（動物） ─────────────────────────────────────────────

final stage4Questions = <Question>[
  const Question(
    id: 's4_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Dog', textJa: '動物を聞いて選ぼう', imageEmoji: '🐕',
    choices: ['猫', '犬', '鳥', '魚'], correctAnswer: '犬', phonetic: '/dɒɡ/',
  ),
  const Question(
    id: 's4_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Cat', textJa: '動物を聞いて選ぼう', imageEmoji: '🐈',
    choices: ['猫', '犬', '鳥', '魚'], correctAnswer: '猫', phonetic: '/kæt/',
  ),
  const Question(
    id: 's4_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Bird', textJa: '動物を聞いて選ぼう', imageEmoji: '🐦',
    choices: ['猫', '犬', '鳥', '魚'], correctAnswer: '鳥', phonetic: '/bɜːrd/',
  ),
  const Question(
    id: 's4_l4', type: QuestionType.listening, difficulty: DifficultyLevel.intermediate,
    text: 'Elephant', textJa: '動物を聞いて選ぼう', imageEmoji: '🐘',
    choices: ['ゾウ', 'キリン', 'ライオン', 'トラ'], correctAnswer: 'ゾウ', phonetic: '/ˈɛlɪfənt/',
  ),
  const Question(
    id: 's4_l5', type: QuestionType.listening, difficulty: DifficultyLevel.intermediate,
    text: 'Do you have a pet?', textJa: '質問を聞いて答えよう',
    imageEmoji: '🐾',
    choices: ['ペットを買いたい', 'ペットを持っているか聞いている', '動物園に行くか聞いている', '動物が好きか聞いている'],
    correctAnswer: 'ペットを持っているか聞いている', phonetic: '/duː juː hæv ə pɛt/',
  ),
  const Question(
    id: 's4_l6', type: QuestionType.listening, difficulty: DifficultyLevel.intermediate,
    text: 'I have a dog', textJa: '何を持っているか聞いて選ぼう',
    imageEmoji: '🐕',
    choices: ['猫', '犬', '鳥', 'うさぎ'], correctAnswer: '犬', phonetic: '/aɪ hæv ə dɒɡ/',
  ),
  const Question(
    id: 's4_l7', type: QuestionType.listening, difficulty: DifficultyLevel.advanced,
    text: 'What is your favorite animal?', textJa: '質問を聞いて答えよう',
    imageEmoji: '🐾',
    choices: ['動物園について聞いている', '好きな動物を聞いている', 'ペットについて聞いている', '動物の数を聞いている'],
    correctAnswer: '好きな動物を聞いている', phonetic: '/wɒt ɪz jɔːr ˈfeɪvərɪt ˈænɪməl/',
  ),
  const Question(
    id: 's4_s1', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'Dog', textJa: '犬を英語で言ってみよう', imageEmoji: '🐕',
    correctAnswer: 'Dog', phonetic: '/dɒɡ/',
  ),
  const Question(
    id: 's4_s2', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'Cat', textJa: '猫を英語で言ってみよう', imageEmoji: '🐈',
    correctAnswer: 'Cat', phonetic: '/kæt/',
  ),
  const Question(
    id: 's4_s3', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'Rabbit', textJa: 'うさぎを英語で言ってみよう', imageEmoji: '🐰',
    correctAnswer: 'Rabbit', phonetic: '/ˈræbɪt/',
  ),
  const Question(
    id: 's4_s4', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'Elephant', textJa: 'ぞうを英語で言ってみよう', imageEmoji: '🐘',
    correctAnswer: 'Elephant', phonetic: '/ˈɛlɪfənt/',
  ),
  const Question(
    id: 's4_s5', type: QuestionType.speaking, difficulty: DifficultyLevel.intermediate,
    text: 'I like dogs', textJa: '犬が好きです、と英語で言ってみよう', imageEmoji: '🐕',
    correctAnswer: 'I like dogs', phonetic: '/aɪ laɪk dɒɡz/',
  ),
  const Question(
    id: 's4_s6', type: QuestionType.speaking, difficulty: DifficultyLevel.intermediate,
    text: 'I have a cat', textJa: '猫を飼っています、と英語で言ってみよう', imageEmoji: '🐈',
    correctAnswer: 'I have a cat', phonetic: '/aɪ hæv ə kæt/',
  ),
  const Question(
    id: 's4_s7', type: QuestionType.speaking, difficulty: DifficultyLevel.intermediate,
    text: 'Do you have a pet?', textJa: 'ペットを飼っていますか？と英語で聞いてみよう', imageEmoji: '🐾',
    correctAnswer: 'Do you have a pet?', phonetic: '/duː juː hæv ə pɛt/',
  ),
  const Question(
    id: 's4_s8', type: QuestionType.speaking, difficulty: DifficultyLevel.advanced,
    text: 'My favorite animal is a lion', textJa: '私の好きな動物はライオンです、と言ってみよう', imageEmoji: '🦁',
    correctAnswer: 'My favorite animal is a lion', phonetic: '/maɪ ˈfeɪvərɪt ˈænɪməl ɪz ə ˈlaɪən/',
  ),
  const Question(
    id: 's4_r1', type: QuestionType.reading, difficulty: DifficultyLevel.beginner,
    text: 'Cat', textJa: '英語の動物名を読もう', imageEmoji: '🐈',
    choices: ['犬', '猫', '鳥'], correctAnswer: '猫',
  ),
  const Question(
    id: 's4_r2', type: QuestionType.reading, difficulty: DifficultyLevel.intermediate,
    text: 'Elephant', textJa: '英語の動物名を読もう', imageEmoji: '🐘',
    choices: ['ライオン', 'ゾウ', 'キリン'], correctAnswer: 'ゾウ',
  ),
  const Question(
    id: 's4_r3', type: QuestionType.reading, difficulty: DifficultyLevel.intermediate,
    text: 'I have a dog', textJa: '英文を読んで意味を選ぼう', imageEmoji: '🐕',
    choices: ['犬が好き', '犬を飼っている', '犬を見た'], correctAnswer: '犬を飼っている',
  ),
  const Question(
    id: 's4_w1', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: '鳥（Bird）', textJa: '鳥を英語で選ぼう',
    choices: ['Dog', 'Cat', 'Bird'], correctAnswer: 'Bird',
  ),
  const Question(
    id: 's4_w2', type: QuestionType.writing, difficulty: DifficultyLevel.intermediate,
    text: 'うさぎ（Rabbit）', textJa: 'うさぎを英語で選ぼう',
    choices: ['Rabbit', 'Hamster', 'Guinea pig'], correctAnswer: 'Rabbit',
  ),
];

// ─── Stage 5: Food（食べ物） ──────────────────────────────────────────────

final stage5Questions = <Question>[
  const Question(
    id: 's5_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Apple', textJa: '食べ物を聞いて選ぼう', imageEmoji: '🍎',
    choices: ['りんご', 'バナナ', 'オレンジ', 'いちご'], correctAnswer: 'りんご', phonetic: '/ˈæpəl/',
  ),
  const Question(
    id: 's5_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Banana', textJa: '食べ物を聞いて選ぼう', imageEmoji: '🍌',
    choices: ['りんご', 'バナナ', 'オレンジ', 'いちご'], correctAnswer: 'バナナ', phonetic: '/bəˈnɑːnə/',
  ),
  const Question(
    id: 's5_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Rice', textJa: '食べ物を聞いて選ぼう', imageEmoji: '🍚',
    choices: ['パン', 'ご飯', 'うどん', 'そば'], correctAnswer: 'ご飯', phonetic: '/raɪs/',
  ),
  const Question(
    id: 's5_l4', type: QuestionType.listening, difficulty: DifficultyLevel.intermediate,
    text: 'Do you like pizza?', textJa: '質問を聞いて答えよう',
    imageEmoji: '🍕',
    choices: ['ピザを注文した', 'ピザが好きか聞いている', 'ピザを作った', 'ピザを食べた'],
    correctAnswer: 'ピザが好きか聞いている', phonetic: '/duː juː laɪk ˈpiːtsə/',
  ),
  const Question(
    id: 's5_l5', type: QuestionType.listening, difficulty: DifficultyLevel.intermediate,
    text: "I don't like vegetables", textJa: '野菜が好きか聞いて選ぼう',
    imageEmoji: '🥦',
    choices: ['好き', 'どちらでも', '嫌い', 'わからない'], correctAnswer: '嫌い', phonetic: '/aɪ doʊnt laɪk ˈvɛdʒtəbəlz/',
  ),
  const Question(
    id: 's5_l6', type: QuestionType.listening, difficulty: DifficultyLevel.intermediate,
    text: 'What would you like to eat?', textJa: '質問を聞いて答えよう',
    imageEmoji: '🍽️',
    choices: ['何を飲みたいか聞いている', '何を食べたいか聞いている', 'どこで食べるか聞いている', 'いつ食べるか聞いている'],
    correctAnswer: '何を食べたいか聞いている', phonetic: '/wɒt wʊd juː laɪk tə iːt/',
  ),
  const Question(
    id: 's5_l7', type: QuestionType.listening, difficulty: DifficultyLevel.advanced,
    text: "I'd like some sushi, please", textJa: '何を頼んだか聞いて選ぼう',
    imageEmoji: '🍣',
    choices: ['ラーメン', '寿司', 'うどん', 'そば'], correctAnswer: '寿司', phonetic: '/aɪd laɪk sʌm ˈsuːʃi pliːz/',
  ),
  const Question(
    id: 's5_s1', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'Apple', textJa: 'りんごを英語で言ってみよう', imageEmoji: '🍎',
    correctAnswer: 'Apple', phonetic: '/ˈæpəl/',
  ),
  const Question(
    id: 's5_s2', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'Banana', textJa: 'バナナを英語で言ってみよう', imageEmoji: '🍌',
    correctAnswer: 'Banana', phonetic: '/bəˈnɑːnə/',
  ),
  const Question(
    id: 's5_s3', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'Pizza', textJa: 'ピザを英語で言ってみよう', imageEmoji: '🍕',
    correctAnswer: 'Pizza', phonetic: '/ˈpiːtsə/',
  ),
  const Question(
    id: 's5_s4', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'Sushi', textJa: '寿司を英語で言ってみよう', imageEmoji: '🍣',
    correctAnswer: 'Sushi', phonetic: '/ˈsuːʃi/',
  ),
  const Question(
    id: 's5_s5', type: QuestionType.speaking, difficulty: DifficultyLevel.intermediate,
    text: 'I like sushi', textJa: '寿司が好きです、と英語で言ってみよう', imageEmoji: '🍣',
    correctAnswer: 'I like sushi', phonetic: '/aɪ laɪk ˈsuːʃi/',
  ),
  const Question(
    id: 's5_s6', type: QuestionType.speaking, difficulty: DifficultyLevel.intermediate,
    text: "I don't like vegetables", textJa: '野菜が嫌いです、と英語で言ってみよう', imageEmoji: '🥦',
    correctAnswer: "I don't like vegetables", phonetic: '/aɪ doʊnt laɪk ˈvɛdʒtəbəlz/',
  ),
  const Question(
    id: 's5_s7', type: QuestionType.speaking, difficulty: DifficultyLevel.intermediate,
    text: 'Do you like pizza?', textJa: 'ピザが好きですか？と英語で聞いてみよう', imageEmoji: '🍕',
    correctAnswer: 'Do you like pizza?', phonetic: '/duː juː laɪk ˈpiːtsə/',
  ),
  const Question(
    id: 's5_s8', type: QuestionType.speaking, difficulty: DifficultyLevel.advanced,
    text: "What's your favorite food?", textJa: '好きな食べ物は何ですか？と英語で聞いてみよう', imageEmoji: '🍽️',
    correctAnswer: "What's your favorite food?", phonetic: '/wɒts jɔːr ˈfeɪvərɪt fuːd/',
  ),
  const Question(
    id: 's5_r1', type: QuestionType.reading, difficulty: DifficultyLevel.beginner,
    text: 'Apple', textJa: '英語の食べ物を読もう', imageEmoji: '🍎',
    choices: ['みかん', 'りんご', 'ぶどう'], correctAnswer: 'りんご',
  ),
  const Question(
    id: 's5_r2', type: QuestionType.reading, difficulty: DifficultyLevel.intermediate,
    text: 'I like sushi', textJa: '英文を読んで意味を選ぼう', imageEmoji: '🍣',
    choices: ['寿司が食べたい', '寿司が好き', '寿司を作った'], correctAnswer: '寿司が好き',
  ),
  const Question(
    id: 's5_r3', type: QuestionType.reading, difficulty: DifficultyLevel.intermediate,
    text: "I don't like vegetables", textJa: '英文を読んで意味を選ぼう', imageEmoji: '🥦',
    choices: ['野菜が食べたい', '野菜を食べた', '野菜が嫌い'], correctAnswer: '野菜が嫌い',
  ),
  const Question(
    id: 's5_w1', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'バナナ（Banana）', textJa: 'バナナを英語で選ぼう',
    choices: ['Apple', 'Banana', 'Orange'], correctAnswer: 'Banana',
  ),
  const Question(
    id: 's5_w2', type: QuestionType.writing, difficulty: DifficultyLevel.intermediate,
    text: '寿司（Sushi）', textJa: '寿司を英語で選ぼう',
    choices: ['Ramen', 'Tempura', 'Sushi'], correctAnswer: 'Sushi',
  ),
];

List<Question> getQuestionsForStage(int stageNumber) {
  switch (stageNumber) {
    case 1: return stage1Questions;
    case 2: return stage2Questions;
    case 3: return stage3Questions;
    case 4: return stage4Questions;
    case 5: return stage5Questions;
    default: return stage1Questions;
  }
}
