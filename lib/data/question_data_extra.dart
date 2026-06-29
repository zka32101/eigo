import '../models/question.dart';

// ─── Stage 6: School（学校） ──────────────────────────────────────────────

final stage6Questions = <Question>[
  // リスニング (7問)
  const Question(
    id: 's6_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Pencil', textJa: '文具を聞いて選ぼう', imageEmoji: '✏️',
    choices: ['えんぴつ', 'ノート', '消しゴム', '定規'], correctAnswer: 'えんぴつ', phonetic: '/ˈpɛnsəl/',
  ),
  const Question(
    id: 's6_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Teacher', textJa: '人を聞いて選ぼう', imageEmoji: '👩‍🏫',
    choices: ['生徒', '先生', '校長先生', '友達'], correctAnswer: '先生', phonetic: '/ˈtiːtʃər/',
  ),
  const Question(
    id: 's6_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Classroom', textJa: '場所を聞いて選ぼう', imageEmoji: '🏫',
    choices: ['校庭', '体育館', '教室', '図書館'], correctAnswer: '教室', phonetic: '/ˈklæsruːm/',
  ),
  const Question(
    id: 's6_l4', type: QuestionType.listening, difficulty: DifficultyLevel.intermediate,
    text: 'What subject do you like?', textJa: '質問を聞いて答えよう',
    imageEmoji: '📚',
    choices: ['好きな食べ物を聞いている', '好きな科目を聞いている', '好きな動物を聞いている', '好きな色を聞いている'],
    correctAnswer: '好きな科目を聞いている', phonetic: '/wɒt ˈsʌbdʒɪkt duː juː laɪk/',
  ),
  const Question(
    id: 's6_l5', type: QuestionType.listening, difficulty: DifficultyLevel.intermediate,
    text: 'I like math', textJa: '好きな科目を選ぼう', imageEmoji: '➕',
    choices: ['体育', '算数・数学', '理科', '国語'], correctAnswer: '算数・数学', phonetic: '/aɪ laɪk mæθ/',
  ),
  const Question(
    id: 's6_l6', type: QuestionType.listening, difficulty: DifficultyLevel.intermediate,
    text: 'Open your textbook', textJa: '指示を聞いて何をするか選ぼう', imageEmoji: '📖',
    choices: ['本を閉じる', 'ノートを開く', '教科書を開く', '立つ'],
    correctAnswer: '教科書を開く', phonetic: '/ˈoʊpən jɔːr ˈtɛkstbʊk/',
  ),
  const Question(
    id: 's6_l7', type: QuestionType.listening, difficulty: DifficultyLevel.advanced,
    text: 'Can I go to the bathroom?', textJa: '何を聞いているか選ぼう', imageEmoji: '🚻',
    choices: ['図書館に行ってよいか', 'トイレに行ってよいか', '保健室に行ってよいか', '校庭に行ってよいか'],
    correctAnswer: 'トイレに行ってよいか', phonetic: '/kæn aɪ ɡoʊ tə ðə ˈbæθruːm/',
  ),

  // スピーキング (8問)
  const Question(
    id: 's6_s1', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'Pencil', textJa: 'えんぴつを英語で言ってみよう', imageEmoji: '✏️',
    correctAnswer: 'Pencil', phonetic: '/ˈpɛnsəl/',
  ),
  const Question(
    id: 's6_s2', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'Teacher', textJa: '先生を英語で言ってみよう', imageEmoji: '👩‍🏫',
    correctAnswer: 'Teacher', phonetic: '/ˈtiːtʃər/',
  ),
  const Question(
    id: 's6_s3', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'Classroom', textJa: '教室を英語で言ってみよう', imageEmoji: '🏫',
    correctAnswer: 'Classroom', phonetic: '/ˈklæsruːm/',
  ),
  const Question(
    id: 's6_s4', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'Homework', textJa: '宿題を英語で言ってみよう', imageEmoji: '📝',
    correctAnswer: 'Homework', phonetic: '/ˈhoʊmwɜːrk/',
  ),
  const Question(
    id: 's6_s5', type: QuestionType.speaking, difficulty: DifficultyLevel.intermediate,
    text: 'I like English', textJa: '英語が好きです、と言ってみよう', imageEmoji: '🇬🇧',
    correctAnswer: 'I like English', phonetic: '/aɪ laɪk ˈɪŋɡlɪʃ/',
  ),
  const Question(
    id: 's6_s6', type: QuestionType.speaking, difficulty: DifficultyLevel.intermediate,
    text: "What's your favorite subject?", textJa: '好きな科目は何ですか？と聞いてみよう', imageEmoji: '📚',
    correctAnswer: "What's your favorite subject?", phonetic: '/wɒts jɔːr ˈfeɪvərɪt ˈsʌbdʒɪkt/',
  ),
  const Question(
    id: 's6_s7', type: QuestionType.speaking, difficulty: DifficultyLevel.intermediate,
    text: 'Open your book', textJa: '本を開いてください、と英語で言ってみよう', imageEmoji: '📖',
    correctAnswer: 'Open your book', phonetic: '/ˈoʊpən jɔːr bʊk/',
  ),
  const Question(
    id: 's6_s8', type: QuestionType.speaking, difficulty: DifficultyLevel.advanced,
    text: 'Can I go to the bathroom please?', textJa: 'トイレに行ってよいですか？と言ってみよう', imageEmoji: '🚻',
    correctAnswer: 'Can I go to the bathroom please?', phonetic: '/kæn aɪ ɡoʊ tə ðə ˈbæθruːm pliːz/',
  ),

  // リーディング (3問)
  const Question(
    id: 's6_r1', type: QuestionType.reading, difficulty: DifficultyLevel.beginner,
    text: 'Teacher', textJa: '英語を読んで意味を選ぼう', imageEmoji: '👩‍🏫',
    choices: ['生徒', '先生', '友達'], correctAnswer: '先生',
  ),
  const Question(
    id: 's6_r2', type: QuestionType.reading, difficulty: DifficultyLevel.beginner,
    text: 'Homework', textJa: '英語を読んで意味を選ぼう', imageEmoji: '📝',
    choices: ['教科書', '宿題', 'テスト'], correctAnswer: '宿題',
  ),
  const Question(
    id: 's6_r3', type: QuestionType.reading, difficulty: DifficultyLevel.intermediate,
    text: 'I like math', textJa: '英文を読んで意味を選ぼう', imageEmoji: '➕',
    choices: ['数学が嫌い', '数学が好き', '数学ができる'], correctAnswer: '数学が好き',
  ),

  // ライティング (2問)
  const Question(
    id: 's6_w1', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: '先生（Teacher）', textJa: '先生を英語で選ぼう',
    choices: ['Student', 'Teacher', 'Principal'], correctAnswer: 'Teacher',
  ),
  const Question(
    id: 's6_w2', type: QuestionType.writing, difficulty: DifficultyLevel.intermediate,
    text: '教室（Classroom）', textJa: '教室を英語で選ぼう',
    choices: ['Gym', 'Library', 'Classroom'], correctAnswer: 'Classroom',
  ),
];

// ─── Stage 7: Family（家族） ──────────────────────────────────────────────

final stage7Questions = <Question>[
  // リスニング (7問)
  const Question(
    id: 's7_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Mother', textJa: '家族を聞いて選ぼう', imageEmoji: '👩',
    choices: ['父', '母', '兄', '妹'], correctAnswer: '母', phonetic: '/ˈmʌðər/',
  ),
  const Question(
    id: 's7_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Father', textJa: '家族を聞いて選ぼう', imageEmoji: '👨',
    choices: ['父', '母', '祖父', '叔父'], correctAnswer: '父', phonetic: '/ˈfɑːðər/',
  ),
  const Question(
    id: 's7_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Brother', textJa: '家族を聞いて選ぼう', imageEmoji: '👦',
    choices: ['妹', '姉', '兄弟', '祖母'], correctAnswer: '兄弟', phonetic: '/ˈbrʌðər/',
  ),
  const Question(
    id: 's7_l4', type: QuestionType.listening, difficulty: DifficultyLevel.intermediate,
    text: 'How many people are in your family?', textJa: '質問を聞いて答えよう',
    imageEmoji: '👨‍👩‍👧‍👦',
    choices: ['家族は何人か聞いている', '家族の名前を聞いている', '家族はどこに住むか聞いている', '家族は何歳か聞いている'],
    correctAnswer: '家族は何人か聞いている', phonetic: '/haʊ ˈmɛni ˈpiːpəl ɑːr ɪn jɔːr ˈfæmɪli/',
  ),
  const Question(
    id: 's7_l5', type: QuestionType.listening, difficulty: DifficultyLevel.intermediate,
    text: 'I have one sister', textJa: '姉妹の数を聞いて選ぼう', imageEmoji: '👧',
    choices: ['0人', '1人', '2人', '3人'], correctAnswer: '1人', phonetic: '/aɪ hæv wʌn ˈsɪstər/',
  ),
  const Question(
    id: 's7_l6', type: QuestionType.listening, difficulty: DifficultyLevel.intermediate,
    text: 'My grandmother is kind', textJa: 'どんな人かを聞いて選ぼう', imageEmoji: '👵',
    choices: ['厳しい', '優しい', '面白い', '元気'], correctAnswer: '優しい', phonetic: '/maɪ ˈɡrænd mʌðər ɪz kaɪnd/',
  ),
  const Question(
    id: 's7_l7', type: QuestionType.listening, difficulty: DifficultyLevel.advanced,
    text: 'My family has four people', textJa: '家族の人数を聞いて選ぼう', imageEmoji: '👨‍👩‍👧‍👦',
    choices: ['2人', '3人', '4人', '5人'], correctAnswer: '4人', phonetic: '/maɪ ˈfæmɪli hæz fɔːr ˈpiːpəl/',
  ),

  // スピーキング (8問)
  const Question(
    id: 's7_s1', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'Mother', textJa: 'お母さんを英語で言ってみよう', imageEmoji: '👩',
    correctAnswer: 'Mother', phonetic: '/ˈmʌðər/',
  ),
  const Question(
    id: 's7_s2', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'Father', textJa: 'お父さんを英語で言ってみよう', imageEmoji: '👨',
    correctAnswer: 'Father', phonetic: '/ˈfɑːðər/',
  ),
  const Question(
    id: 's7_s3', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'Sister', textJa: '姉妹を英語で言ってみよう', imageEmoji: '👧',
    correctAnswer: 'Sister', phonetic: '/ˈsɪstər/',
  ),
  const Question(
    id: 's7_s4', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'Grandmother', textJa: 'おばあちゃんを英語で言ってみよう', imageEmoji: '👵',
    correctAnswer: 'Grandmother', phonetic: '/ˈɡrænmʌðər/',
  ),
  const Question(
    id: 's7_s5', type: QuestionType.speaking, difficulty: DifficultyLevel.intermediate,
    text: 'I have one brother', textJa: '兄弟が1人います、と言ってみよう', imageEmoji: '👦',
    correctAnswer: 'I have one brother', phonetic: '/aɪ hæv wʌn ˈbrʌðər/',
  ),
  const Question(
    id: 's7_s6', type: QuestionType.speaking, difficulty: DifficultyLevel.intermediate,
    text: 'My family has four people', textJa: '家族は4人です、と言ってみよう', imageEmoji: '👨‍👩‍👧‍👦',
    correctAnswer: 'My family has four people', phonetic: '/maɪ ˈfæmɪli hæz fɔːr ˈpiːpəl/',
  ),
  const Question(
    id: 's7_s7', type: QuestionType.speaking, difficulty: DifficultyLevel.intermediate,
    text: 'My mother is kind', textJa: '私の母は優しいです、と言ってみよう', imageEmoji: '👩',
    correctAnswer: 'My mother is kind', phonetic: '/maɪ ˈmʌðər ɪz kaɪnd/',
  ),
  const Question(
    id: 's7_s8', type: QuestionType.speaking, difficulty: DifficultyLevel.advanced,
    text: 'How many people are in your family?', textJa: '家族は何人ですか？と聞いてみよう', imageEmoji: '👨‍👩‍👧',
    correctAnswer: 'How many people are in your family?', phonetic: '/haʊ ˈmɛni ˈpiːpəl ɑːr ɪn jɔːr ˈfæmɪli/',
  ),

  // リーディング (3問)
  const Question(
    id: 's7_r1', type: QuestionType.reading, difficulty: DifficultyLevel.beginner,
    text: 'Mother', textJa: '英語を読んで意味を選ぼう', imageEmoji: '👩',
    choices: ['父', '母', '祖母'], correctAnswer: '母',
  ),
  const Question(
    id: 's7_r2', type: QuestionType.reading, difficulty: DifficultyLevel.intermediate,
    text: 'I have one brother', textJa: '英文を読んで意味を選ぼう', imageEmoji: '👦',
    choices: ['兄弟が2人', '兄弟が1人', '姉妹が1人'], correctAnswer: '兄弟が1人',
  ),
  const Question(
    id: 's7_r3', type: QuestionType.reading, difficulty: DifficultyLevel.intermediate,
    text: 'My grandmother is kind', textJa: '英文を読んで意味を選ぼう', imageEmoji: '👵',
    choices: ['祖母は優しい', '祖母は厳しい', '祖母は元気'], correctAnswer: '祖母は優しい',
  ),

  // ライティング (2問)
  const Question(
    id: 's7_w1', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: '父（Father）', textJa: '父を英語で選ぼう',
    choices: ['Brother', 'Father', 'Grandfather'], correctAnswer: 'Father',
  ),
  const Question(
    id: 's7_w2', type: QuestionType.writing, difficulty: DifficultyLevel.intermediate,
    text: '姉妹（Sister）', textJa: '姉妹を英語で選ぼう',
    choices: ['Brother', 'Sister', 'Cousin'], correctAnswer: 'Sister',
  ),
];

// ─── Stage 8: Body Parts（からだ） ────────────────────────────────────────

final stage8Questions = <Question>[
  // リスニング (7問)
  const Question(
    id: 's8_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Head', textJa: '体の部位を聞いて選ぼう', imageEmoji: '🤯',
    choices: ['頭', '手', '足', '目'], correctAnswer: '頭', phonetic: '/hɛd/',
  ),
  const Question(
    id: 's8_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Hand', textJa: '体の部位を聞いて選ぼう', imageEmoji: '🖐️',
    choices: ['頭', '手', '足', '腕'], correctAnswer: '手', phonetic: '/hænd/',
  ),
  const Question(
    id: 's8_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Eyes', textJa: '体の部位を聞いて選ぼう', imageEmoji: '👀',
    choices: ['耳', '目', '鼻', '口'], correctAnswer: '目', phonetic: '/aɪz/',
  ),
  const Question(
    id: 's8_l4', type: QuestionType.listening, difficulty: DifficultyLevel.intermediate,
    text: 'Touch your nose', textJa: '指示を聞いて、何をするか選ぼう', imageEmoji: '👃',
    choices: ['耳を触る', '口を触る', '鼻を触る', '目を触る'], correctAnswer: '鼻を触る', phonetic: '/tʌtʃ jɔːr noʊz/',
  ),
  const Question(
    id: 's8_l5', type: QuestionType.listening, difficulty: DifficultyLevel.intermediate,
    text: 'My leg hurts', textJa: 'どこが痛いか聞いて選ぼう', imageEmoji: '🦵',
    choices: ['腕', '足', '頭', 'おなか'], correctAnswer: '足', phonetic: '/maɪ lɛɡ hɜːrts/',
  ),
  const Question(
    id: 's8_l6', type: QuestionType.listening, difficulty: DifficultyLevel.intermediate,
    text: 'How many fingers do you have?', textJa: '質問を聞いて答えよう', imageEmoji: '🖐️',
    choices: ['何本の指があるか聞いている', '何本の足があるか聞いている', '何本の腕があるか聞いている', '何本の歯があるか聞いている'],
    correctAnswer: '何本の指があるか聞いている', phonetic: '/haʊ ˈmɛni ˈfɪŋɡərz duː juː hæv/',
  ),
  const Question(
    id: 's8_l7', type: QuestionType.listening, difficulty: DifficultyLevel.advanced,
    text: 'I have a stomachache', textJa: 'どこが悪いか聞いて選ぼう', imageEmoji: '🤕',
    choices: ['頭痛', '歯痛', '腹痛', '足痛'], correctAnswer: '腹痛', phonetic: '/aɪ hæv ə ˈstʌməkeɪk/',
  ),

  // スピーキング (8問)
  const Question(
    id: 's8_s1', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'Head', textJa: '頭を英語で言ってみよう', imageEmoji: '🤯',
    correctAnswer: 'Head', phonetic: '/hɛd/',
  ),
  const Question(
    id: 's8_s2', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'Hand', textJa: '手を英語で言ってみよう', imageEmoji: '🖐️',
    correctAnswer: 'Hand', phonetic: '/hænd/',
  ),
  const Question(
    id: 's8_s3', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'Eyes', textJa: '目を英語で言ってみよう', imageEmoji: '👀',
    correctAnswer: 'Eyes', phonetic: '/aɪz/',
  ),
  const Question(
    id: 's8_s4', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'Nose', textJa: '鼻を英語で言ってみよう', imageEmoji: '👃',
    correctAnswer: 'Nose', phonetic: '/noʊz/',
  ),
  const Question(
    id: 's8_s5', type: QuestionType.speaking, difficulty: DifficultyLevel.intermediate,
    text: 'Touch your head', textJa: '頭を触って、と英語で言ってみよう', imageEmoji: '🤯',
    correctAnswer: 'Touch your head', phonetic: '/tʌtʃ jɔːr hɛd/',
  ),
  const Question(
    id: 's8_s6', type: QuestionType.speaking, difficulty: DifficultyLevel.intermediate,
    text: 'My head hurts', textJa: '頭が痛い、と英語で言ってみよう', imageEmoji: '🤕',
    correctAnswer: 'My head hurts', phonetic: '/maɪ hɛd hɜːrts/',
  ),
  const Question(
    id: 's8_s7', type: QuestionType.speaking, difficulty: DifficultyLevel.intermediate,
    text: 'I have a stomachache', textJa: 'おなかが痛い、と英語で言ってみよう', imageEmoji: '😣',
    correctAnswer: 'I have a stomachache', phonetic: '/aɪ hæv ə ˈstʌməkeɪk/',
  ),
  const Question(
    id: 's8_s8', type: QuestionType.speaking, difficulty: DifficultyLevel.advanced,
    text: 'Head, shoulders, knees and toes', textJa: '体の部位を英語で言ってみよう', imageEmoji: '🧍',
    correctAnswer: 'Head shoulders knees and toes', phonetic: '/hɛd ˈʃoʊldərz niːz ænd toʊz/',
  ),

  // リーディング (3問)
  const Question(
    id: 's8_r1', type: QuestionType.reading, difficulty: DifficultyLevel.beginner,
    text: 'Eyes', textJa: '英語を読んで意味を選ぼう', imageEmoji: '👀',
    choices: ['耳', '目', '鼻'], correctAnswer: '目',
  ),
  const Question(
    id: 's8_r2', type: QuestionType.reading, difficulty: DifficultyLevel.intermediate,
    text: 'My leg hurts', textJa: '英文を読んで意味を選ぼう', imageEmoji: '🦵',
    choices: ['手が痛い', '足が痛い', '頭が痛い'], correctAnswer: '足が痛い',
  ),
  const Question(
    id: 's8_r3', type: QuestionType.reading, difficulty: DifficultyLevel.advanced,
    text: 'Touch your nose', textJa: '英文を読んで何をするか選ぼう', imageEmoji: '👃',
    choices: ['目を触る', '耳を触る', '鼻を触る'], correctAnswer: '鼻を触る',
  ),

  // ライティング (2問)
  const Question(
    id: 's8_w1', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: '手（Hand）', textJa: '手を英語で選ぼう',
    choices: ['Foot', 'Hand', 'Arm'], correctAnswer: 'Hand',
  ),
  const Question(
    id: 's8_w2', type: QuestionType.writing, difficulty: DifficultyLevel.intermediate,
    text: '鼻（Nose）', textJa: '鼻を英語で選ぼう',
    choices: ['Mouth', 'Nose', 'Ear'], correctAnswer: 'Nose',
  ),
];

// ─── Stage 9: Weather（天気） ─────────────────────────────────────────────

final stage9Questions = <Question>[
  // リスニング (7問)
  const Question(
    id: 's9_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Sunny', textJa: '天気を聞いて選ぼう', imageEmoji: '☀️',
    choices: ['晴れ', '雨', '曇り', '雪'], correctAnswer: '晴れ', phonetic: '/ˈsʌni/',
  ),
  const Question(
    id: 's9_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Rainy', textJa: '天気を聞いて選ぼう', imageEmoji: '🌧️',
    choices: ['晴れ', '雨', '曇り', '雪'], correctAnswer: '雨', phonetic: '/ˈreɪni/',
  ),
  const Question(
    id: 's9_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Snowy', textJa: '天気を聞いて選ぼう', imageEmoji: '❄️',
    choices: ['晴れ', '台風', '曇り', '雪'], correctAnswer: '雪', phonetic: '/ˈsnoʊi/',
  ),
  const Question(
    id: 's9_l4', type: QuestionType.listening, difficulty: DifficultyLevel.intermediate,
    text: "How's the weather today?", textJa: '質問を聞いて答えよう', imageEmoji: '⛅',
    choices: ['今日の天気を聞いている', '今日の気温を聞いている', '今日の時間を聞いている', '今日の日付を聞いている'],
    correctAnswer: '今日の天気を聞いている', phonetic: '/haʊz ðə ˈwɛðər təˈdeɪ/',
  ),
  const Question(
    id: 's9_l5', type: QuestionType.listening, difficulty: DifficultyLevel.intermediate,
    text: "It's cloudy today", textJa: '今日の天気を聞いて選ぼう', imageEmoji: '☁️',
    choices: ['晴れ', '雨', '曇り', '雪'], correctAnswer: '曇り', phonetic: '/ɪts ˈklaʊdi təˈdeɪ/',
  ),
  const Question(
    id: 's9_l6', type: QuestionType.listening, difficulty: DifficultyLevel.intermediate,
    text: "Don't forget your umbrella", textJa: '何を持っていくよう言っているか選ぼう', imageEmoji: '☂️',
    choices: ['コート', '帽子', '傘', '手袋'],
    correctAnswer: '傘', phonetic: '/doʊnt fərˈɡɛt jɔːr ʌmˈbrɛlə/',
  ),
  const Question(
    id: 's9_l7', type: QuestionType.listening, difficulty: DifficultyLevel.advanced,
    text: "It's hot and humid today", textJa: '今日の天気・気候を聞いて選ぼう', imageEmoji: '🌡️',
    choices: ['寒くて乾燥', '暑くて蒸し暑い', '涼しくて快適', '寒くて雪'], correctAnswer: '暑くて蒸し暑い', phonetic: '/ɪts hɒt ænd hjuːmɪd təˈdeɪ/',
  ),

  // スピーキング (8問)
  const Question(
    id: 's9_s1', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'Sunny', textJa: '晴れを英語で言ってみよう', imageEmoji: '☀️',
    correctAnswer: 'Sunny', phonetic: '/ˈsʌni/',
  ),
  const Question(
    id: 's9_s2', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'Rainy', textJa: '雨を英語で言ってみよう', imageEmoji: '🌧️',
    correctAnswer: 'Rainy', phonetic: '/ˈreɪni/',
  ),
  const Question(
    id: 's9_s3', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'Cloudy', textJa: '曇りを英語で言ってみよう', imageEmoji: '☁️',
    correctAnswer: 'Cloudy', phonetic: '/ˈklaʊdi/',
  ),
  const Question(
    id: 's9_s4', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'Windy', textJa: '風が強いを英語で言ってみよう', imageEmoji: '💨',
    correctAnswer: 'Windy', phonetic: '/ˈwɪndi/',
  ),
  const Question(
    id: 's9_s5', type: QuestionType.speaking, difficulty: DifficultyLevel.intermediate,
    text: "It's sunny today", textJa: '今日は晴れです、と英語で言ってみよう', imageEmoji: '☀️',
    correctAnswer: "It's sunny today", phonetic: '/ɪts ˈsʌni təˈdeɪ/',
  ),
  const Question(
    id: 's9_s6', type: QuestionType.speaking, difficulty: DifficultyLevel.intermediate,
    text: "How's the weather today?", textJa: '今日の天気はどうですか？と聞いてみよう', imageEmoji: '⛅',
    correctAnswer: "How's the weather today?", phonetic: '/haʊz ðə ˈwɛðər təˈdeɪ/',
  ),
  const Question(
    id: 's9_s7', type: QuestionType.speaking, difficulty: DifficultyLevel.intermediate,
    text: "It's cold today", textJa: '今日は寒い、と英語で言ってみよう', imageEmoji: '🥶',
    correctAnswer: "It's cold today", phonetic: '/ɪts koʊld təˈdeɪ/',
  ),
  const Question(
    id: 's9_s8', type: QuestionType.speaking, difficulty: DifficultyLevel.advanced,
    text: "Don't forget your umbrella", textJa: '傘を忘れずに、と英語で言ってみよう', imageEmoji: '☂️',
    correctAnswer: "Don't forget your umbrella", phonetic: '/doʊnt fərˈɡɛt jɔːr ʌmˈbrɛlə/',
  ),

  // リーディング (3問)
  const Question(
    id: 's9_r1', type: QuestionType.reading, difficulty: DifficultyLevel.beginner,
    text: 'Sunny', textJa: '英語を読んで意味を選ぼう', imageEmoji: '☀️',
    choices: ['雨', '晴れ', '曇り'], correctAnswer: '晴れ',
  ),
  const Question(
    id: 's9_r2', type: QuestionType.reading, difficulty: DifficultyLevel.intermediate,
    text: "It's rainy today", textJa: '英文を読んで意味を選ぼう', imageEmoji: '🌧️',
    choices: ['今日は晴れ', '今日は雨', '今日は曇り'], correctAnswer: '今日は雨',
  ),
  const Question(
    id: 's9_r3', type: QuestionType.reading, difficulty: DifficultyLevel.advanced,
    text: "How's the weather today?", textJa: '英文を読んで何を聞いているか選ぼう', imageEmoji: '⛅',
    choices: ['今日の時間', '今日の天気', '今日の予定'], correctAnswer: '今日の天気',
  ),

  // ライティング (2問)
  const Question(
    id: 's9_w1', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: '雨（Rainy）', textJa: '雨を英語で選ぼう',
    choices: ['Sunny', 'Rainy', 'Cloudy'], correctAnswer: 'Rainy',
  ),
  const Question(
    id: 's9_w2', type: QuestionType.writing, difficulty: DifficultyLevel.intermediate,
    text: '雪（Snowy）', textJa: '雪を英語で選ぼう',
    choices: ['Windy', 'Stormy', 'Snowy'], correctAnswer: 'Snowy',
  ),
];

// ─── Stage 10: Hobbies（趣味） ────────────────────────────────────────────

final stage10Questions = <Question>[
  // リスニング (7問)
  const Question(
    id: 's10_l1', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Reading', textJa: '趣味を聞いて選ぼう', imageEmoji: '📚',
    choices: ['読書', 'スポーツ', '料理', '音楽'], correctAnswer: '読書', phonetic: '/ˈriːdɪŋ/',
  ),
  const Question(
    id: 's10_l2', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Swimming', textJa: '趣味を聞いて選ぼう', imageEmoji: '🏊',
    choices: ['走る', '泳ぐ', '踊る', '歌う'], correctAnswer: '泳ぐ', phonetic: '/ˈswɪmɪŋ/',
  ),
  const Question(
    id: 's10_l3', type: QuestionType.listening, difficulty: DifficultyLevel.beginner,
    text: 'Drawing', textJa: '趣味を聞いて選ぼう', imageEmoji: '🎨',
    choices: ['絵を描く', '写真を撮る', '料理をする', '音楽を聴く'], correctAnswer: '絵を描く', phonetic: '/ˈdrɔːɪŋ/',
  ),
  const Question(
    id: 's10_l4', type: QuestionType.listening, difficulty: DifficultyLevel.intermediate,
    text: 'What is your hobby?', textJa: '質問を聞いて答えよう', imageEmoji: '🎯',
    choices: ['好きな食べ物を聞いている', '好きな科目を聞いている', '趣味を聞いている', '誕生日を聞いている'],
    correctAnswer: '趣味を聞いている', phonetic: '/wɒt ɪz jɔːr ˈhɒbi/',
  ),
  const Question(
    id: 's10_l5', type: QuestionType.listening, difficulty: DifficultyLevel.intermediate,
    text: 'I like playing soccer', textJa: '趣味を聞いて選ぼう', imageEmoji: '⚽',
    choices: ['野球', 'バスケ', 'サッカー', 'テニス'], correctAnswer: 'サッカー', phonetic: '/aɪ laɪk ˈpleɪɪŋ ˈsɒkər/',
  ),
  const Question(
    id: 's10_l6', type: QuestionType.listening, difficulty: DifficultyLevel.advanced,
    text: "I enjoy listening to music", textJa: '趣味を聞いて選ぼう', imageEmoji: '🎵',
    choices: ['音楽を演奏する', '音楽を聴く', '音楽を作る', '音楽を歌う'], correctAnswer: '音楽を聴く', phonetic: '/aɪ ɪnˈdʒɔɪ ˈlɪsənɪŋ tə ˈmjuːzɪk/',
  ),
  const Question(
    id: 's10_l7', type: QuestionType.listening, difficulty: DifficultyLevel.advanced,
    text: "Do you have any hobbies?", textJa: '質問を聞いて答えよう', imageEmoji: '🤔',
    choices: ['趣味があるか聞いている', 'スポーツが好きか聞いている', '時間があるか聞いている', '友達がいるか聞いている'],
    correctAnswer: '趣味があるか聞いている', phonetic: '/duː juː hæv ˈɛni ˈhɒbiz/',
  ),

  // スピーキング (8問)
  const Question(
    id: 's10_s1', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'Reading', textJa: '読書を英語で言ってみよう', imageEmoji: '📚',
    correctAnswer: 'Reading', phonetic: '/ˈriːdɪŋ/',
  ),
  const Question(
    id: 's10_s2', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'Swimming', textJa: '水泳を英語で言ってみよう', imageEmoji: '🏊',
    correctAnswer: 'Swimming', phonetic: '/ˈswɪmɪŋ/',
  ),
  const Question(
    id: 's10_s3', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'Drawing', textJa: '絵を描くを英語で言ってみよう', imageEmoji: '🎨',
    correctAnswer: 'Drawing', phonetic: '/ˈdrɔːɪŋ/',
  ),
  const Question(
    id: 's10_s4', type: QuestionType.speaking, difficulty: DifficultyLevel.beginner,
    text: 'Cooking', textJa: '料理を英語で言ってみよう', imageEmoji: '🍳',
    correctAnswer: 'Cooking', phonetic: '/ˈkʊkɪŋ/',
  ),
  const Question(
    id: 's10_s5', type: QuestionType.speaking, difficulty: DifficultyLevel.intermediate,
    text: 'My hobby is reading', textJa: '趣味は読書です、と言ってみよう', imageEmoji: '📚',
    correctAnswer: 'My hobby is reading', phonetic: '/maɪ ˈhɒbi ɪz ˈriːdɪŋ/',
  ),
  const Question(
    id: 's10_s6', type: QuestionType.speaking, difficulty: DifficultyLevel.intermediate,
    text: 'I like playing soccer', textJa: 'サッカーが好きです、と言ってみよう', imageEmoji: '⚽',
    correctAnswer: 'I like playing soccer', phonetic: '/aɪ laɪk ˈpleɪɪŋ ˈsɒkər/',
  ),
  const Question(
    id: 's10_s7', type: QuestionType.speaking, difficulty: DifficultyLevel.intermediate,
    text: 'What is your hobby?', textJa: '趣味は何ですか？と聞いてみよう', imageEmoji: '🎯',
    correctAnswer: 'What is your hobby?', phonetic: '/wɒt ɪz jɔːr ˈhɒbi/',
  ),
  const Question(
    id: 's10_s8', type: QuestionType.speaking, difficulty: DifficultyLevel.advanced,
    text: 'I enjoy listening to music', textJa: '音楽を聴くのが好きです、と言ってみよう', imageEmoji: '🎵',
    correctAnswer: 'I enjoy listening to music', phonetic: '/aɪ ɪnˈdʒɔɪ ˈlɪsənɪŋ tə ˈmjuːzɪk/',
  ),

  // リーディング (3問)
  const Question(
    id: 's10_r1', type: QuestionType.reading, difficulty: DifficultyLevel.beginner,
    text: 'Swimming', textJa: '英語を読んで意味を選ぼう', imageEmoji: '🏊',
    choices: ['走る', '泳ぐ', '跳ぶ'], correctAnswer: '泳ぐ',
  ),
  const Question(
    id: 's10_r2', type: QuestionType.reading, difficulty: DifficultyLevel.intermediate,
    text: 'I like playing soccer', textJa: '英文を読んで意味を選ぼう', imageEmoji: '⚽',
    choices: ['バスケが好き', 'サッカーが好き', '野球が好き'], correctAnswer: 'サッカーが好き',
  ),
  const Question(
    id: 's10_r3', type: QuestionType.reading, difficulty: DifficultyLevel.advanced,
    text: 'My hobby is reading books', textJa: '英文を読んで意味を選ぼう', imageEmoji: '📚',
    choices: ['趣味は読書', '趣味は料理', '趣味は音楽'], correctAnswer: '趣味は読書',
  ),

  // ライティング (2問)
  const Question(
    id: 's10_w1', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: '読書（Reading）', textJa: '読書を英語で選ぼう',
    choices: ['Drawing', 'Reading', 'Cooking'], correctAnswer: 'Reading',
  ),
  const Question(
    id: 's10_w2', type: QuestionType.writing, difficulty: DifficultyLevel.advanced,
    text: '趣味（Hobby）', textJa: '趣味を英語で選ぼう',
    choices: ['Interest', 'Hobby', 'Activity'], correctAnswer: 'Hobby',
  ),
];
