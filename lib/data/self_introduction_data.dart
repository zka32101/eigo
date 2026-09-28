import '../models/question.dart';

/// Stage 81「自己紹介」— アプリの目標である「基本的な会話ができる」の
/// 総仕上げとして、名前・年齢・好きなものを英語で伝える実践フレーズを扱う。
final stage81Questions = <Question>[
  // リスニング
  const Question(
    id: 's81_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'What is your name?', textJa: '次の英語を聞いて、正しい意味を選ぼう',
    imageEmoji: '🙋',
    choices: ['お名前は？', '何歳ですか？', 'どこから来ましたか？', '元気ですか？'],
    correctAnswer: 'お名前は？', phonetic: '/wʌt ɪz jɔːr neɪm/',
  ),
  const Question(
    id: 's81_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'My name is Yuki', textJa: '次の英語を聞いて、正しい意味を選ぼう',
    imageEmoji: '😊',
    choices: ['私はユキです', 'あなたはユキです', 'ユキが好きです', 'ユキに会いたいです'],
    correctAnswer: '私はユキです', phonetic: '/maɪ neɪm ɪz/',
  ),
  const Question(
    id: 's81_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'How old are you?', textJa: '次の英語を聞いて、正しい意味を選ぼう',
    imageEmoji: '🎂',
    choices: ['お名前は？', '何歳ですか？', '誕生日はいつ？', '元気ですか？'],
    correctAnswer: '何歳ですか？', phonetic: '/haʊ oʊld ɑːr juː/',
  ),
  const Question(
    id: 's81_l4', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'I am eleven years old', textJa: '次の英語を聞いて、正しい意味を選ぼう',
    imageEmoji: '🔢',
    choices: ['私は11歳です', '私は11人です', '私は11番です', '私は11時です'],
    correctAnswer: '私は11歳です', phonetic: '/aɪ æm ɪˈlɛvən jɪrz oʊld/',
  ),
  const Question(
    id: 's81_l5', type: QuestionType.listening, difficulty: DifficultyLevel.intermediate,
    text: 'What do you like?', textJa: '次の英語を聞いて、正しい意味を選ぼう',
    imageEmoji: '❤️',
    choices: ['何が好きですか？', '何歳ですか？', '何がしたいですか？', 'どこにいますか？'],
    correctAnswer: '何が好きですか？', phonetic: '/wʌt duː juː laɪk/',
  ),
  const Question(
    id: 's81_l6', type: QuestionType.listening, difficulty: DifficultyLevel.intermediate,
    text: 'I like soccer', textJa: '次の英語を聞いて、正しい意味を選ぼう',
    imageEmoji: '⚽',
    choices: ['私はサッカーが好きです', '私はサッカーをします', '私はサッカーが上手です', '私はサッカーを見ます'],
    correctAnswer: '私はサッカーが好きです', phonetic: '/aɪ laɪk ˈsɒkər/',
  ),
  const Question(
    id: 's81_l7', type: QuestionType.listening, difficulty: DifficultyLevel.intermediate,
    text: 'Nice to meet you too', textJa: '次の英語を聞いて、正しい意味を選ぼう',
    imageEmoji: '🤝',
    choices: ['こちらこそ、はじめまして', 'さようなら', 'また会いましょう', 'ありがとう'],
    correctAnswer: 'こちらこそ、はじめまして', phonetic: '/naɪs tuː miːt juː tuː/',
  ),

  // スピーキング
  const Question(
    id: 's81_s1', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'My name is Yuki', textJa: '「私はユキです」と英語で自己紹介してみよう（名前は自分の名前でOK）',
    imageEmoji: '🙋', correctAnswer: 'My name is Yuki', phonetic: '/maɪ neɪm ɪz/',
  ),
  const Question(
    id: 's81_s2', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'I am eleven years old', textJa: '「私は11歳です」と英語で言ってみよう',
    imageEmoji: '🎂', correctAnswer: 'I am eleven years old', phonetic: '/aɪ æm ɪˈlɛvən jɪrz oʊld/',
  ),
  const Question(
    id: 's81_s3', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'I like soccer', textJa: '「私はサッカーが好きです」と英語で言ってみよう',
    imageEmoji: '⚽', correctAnswer: 'I like soccer', phonetic: '/aɪ laɪk ˈsɒkər/',
  ),
  const Question(
    id: 's81_s4', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'Nice to meet you', textJa: '「はじめまして」と英語で言ってみよう',
    imageEmoji: '🤝', correctAnswer: 'Nice to meet you', phonetic: '/naɪs tuː miːt juː/',
  ),
  const Question(
    id: 's81_s5', type: QuestionType.speaking, difficulty: DifficultyLevel.intermediate,
    text: 'What is your name?', textJa: '「お名前は？」と英語で聞いてみよう',
    imageEmoji: '❓', correctAnswer: 'What is your name?', phonetic: '/wʌt ɪz jɔːr neɪm/',
  ),
  const Question(
    id: 's81_s6', type: QuestionType.speaking, difficulty: DifficultyLevel.intermediate,
    text: 'I am from Japan', textJa: '「私は日本出身です」と英語で言ってみよう',
    imageEmoji: '🇯🇵', correctAnswer: 'I am from Japan', phonetic: '/aɪ æm frʌm dʒəˈpæn/',
  ),
];
