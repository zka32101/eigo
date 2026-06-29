import '../models/question.dart';

// ライティング問題補完 - Stage 3-40 (各2問)
// stage_data.dart で [...stageXXQuestions, ...stageXXWriting] として結合

// Stage 3: Colors
final stage3Writing = <Question>[
  const Question(id: 's3_w1', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'あか', textJa: '日本語を英語にしよう',
    choices: ['red', 'blue', 'green'], correctAnswer: 'red'),
  const Question(id: 's3_w2', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'しろ', textJa: '日本語を英語にしよう',
    choices: ['black', 'white', 'yellow'], correctAnswer: 'white'),
];

// Stage 4: Animals
final stage4Writing = <Question>[
  const Question(id: 's4_w1', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'ねこ', textJa: '日本語を英語にしよう',
    choices: ['dog', 'cat', 'bird'], correctAnswer: 'cat'),
  const Question(id: 's4_w2', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'うま', textJa: '日本語を英語にしよう',
    choices: ['cow', 'horse', 'sheep'], correctAnswer: 'horse'),
];

// Stage 5: Food
final stage5Writing = <Question>[
  const Question(id: 's5_w1', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'パン', textJa: '日本語を英語にしよう',
    choices: ['bread', 'rice', 'cake'], correctAnswer: 'bread'),
  const Question(id: 's5_w2', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'たまご', textJa: '日本語を英語にしよう',
    choices: ['milk', 'egg', 'butter'], correctAnswer: 'egg'),
];

// Stage 6: School
final stage6Writing = <Question>[
  const Question(id: 's6_w1', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'えんぴつ', textJa: '日本語を英語にしよう',
    choices: ['pen', 'pencil', 'eraser'], correctAnswer: 'pencil'),
  const Question(id: 's6_w2', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'つくえ', textJa: '日本語を英語にしよう',
    choices: ['chair', 'desk', 'board'], correctAnswer: 'desk'),
];

// Stage 7: Family
final stage7Writing = <Question>[
  const Question(id: 's7_w1', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'おかあさん', textJa: '日本語を英語にしよう',
    choices: ['father', 'mother', 'sister'], correctAnswer: 'mother'),
  const Question(id: 's7_w2', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'おにいさん', textJa: '日本語を英語にしよう',
    choices: ['brother', 'sister', 'cousin'], correctAnswer: 'brother'),
];

// Stage 8: Body Parts
final stage8Writing = <Question>[
  const Question(id: 's8_w1', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'て', textJa: '日本語を英語にしよう',
    choices: ['foot', 'hand', 'arm'], correctAnswer: 'hand'),
  const Question(id: 's8_w2', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'め', textJa: '日本語を英語にしよう',
    choices: ['ear', 'nose', 'eye'], correctAnswer: 'eye'),
];

// Stage 9: Weather
final stage9Writing = <Question>[
  const Question(id: 's9_w1', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'あめ', textJa: '日本語を英語にしよう',
    choices: ['snow', 'rain', 'wind'], correctAnswer: 'rain'),
  const Question(id: 's9_w2', type: QuestionType.writing, difficulty: DifficultyLevel.intermediate,
    text: 'くもり', textJa: '日本語を英語にしよう',
    choices: ['sunny', 'cloudy', 'windy'], correctAnswer: 'cloudy'),
];

// Stage 10: Hobbies
final stage10Writing = <Question>[
  const Question(id: 's10_w1', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'えをかく', textJa: '日本語を英語にしよう',
    choices: ['draw', 'read', 'sing'], correctAnswer: 'draw'),
  const Question(id: 's10_w2', type: QuestionType.writing, difficulty: DifficultyLevel.intermediate,
    text: 'およぐ', textJa: '日本語を英語にしよう',
    choices: ['run', 'swim', 'jump'], correctAnswer: 'swim'),
];

// Stage 11: Vehicles
final stage11Writing = <Question>[
  const Question(id: 's11_w1', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'じてんしゃ', textJa: '日本語を英語にしよう',
    choices: ['car', 'bike', 'truck'], correctAnswer: 'bike'),
  const Question(id: 's11_w2', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'ひこうき', textJa: '日本語を英語にしよう',
    choices: ['ship', 'train', 'airplane'], correctAnswer: 'airplane'),
];

// Stage 12: Sports
final stage12Writing = <Question>[
  const Question(id: 's12_w1', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'サッカー', textJa: '日本語を英語にしよう',
    choices: ['baseball', 'soccer', 'tennis'], correctAnswer: 'soccer'),
  const Question(id: 's12_w2', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'やきゅう', textJa: '日本語を英語にしよう',
    choices: ['basketball', 'baseball', 'volleyball'], correctAnswer: 'baseball'),
];

// Stage 13: Jobs
final stage13Writing = <Question>[
  const Question(id: 's13_w1', type: QuestionType.writing, difficulty: DifficultyLevel.intermediate,
    text: 'せんせい', textJa: '日本語を英語にしよう',
    choices: ['doctor', 'teacher', 'nurse'], correctAnswer: 'teacher'),
  const Question(id: 's13_w2', type: QuestionType.writing, difficulty: DifficultyLevel.intermediate,
    text: 'しょうぼうし', textJa: '日本語を英語にしよう',
    choices: ['police officer', 'firefighter', 'pilot'], correctAnswer: 'firefighter'),
];

// Stage 14: Seasons
final stage14Writing = <Question>[
  const Question(id: 's14_w1', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'はる', textJa: '日本語を英語にしよう',
    choices: ['summer', 'spring', 'autumn'], correctAnswer: 'spring'),
  const Question(id: 's14_w2', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'ふゆ', textJa: '日本語を英語にしよう',
    choices: ['winter', 'spring', 'summer'], correctAnswer: 'winter'),
];

// Stage 15: Places
final stage15Writing = <Question>[
  const Question(id: 's15_w1', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'こうえん', textJa: '日本語を英語にしよう',
    choices: ['park', 'school', 'shop'], correctAnswer: 'park'),
  const Question(id: 's15_w2', type: QuestionType.writing, difficulty: DifficultyLevel.intermediate,
    text: 'びょういん', textJa: '日本語を英語にしよう',
    choices: ['bank', 'hospital', 'library'], correctAnswer: 'hospital'),
];

// Stage 16: Nature
final stage16Writing = <Question>[
  const Question(id: 's16_w1', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'やま', textJa: '日本語を英語にしよう',
    choices: ['river', 'sea', 'mountain'], correctAnswer: 'mountain'),
  const Question(id: 's16_w2', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'もり', textJa: '日本語を英語にしよう',
    choices: ['forest', 'field', 'desert'], correctAnswer: 'forest'),
];

// Stage 17: Shapes
final stage17Writing = <Question>[
  const Question(id: 's17_w1', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'まる', textJa: '日本語を英語にしよう',
    choices: ['square', 'circle', 'triangle'], correctAnswer: 'circle'),
  const Question(id: 's17_w2', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'しかく', textJa: '日本語を英語にしよう',
    choices: ['circle', 'square', 'star'], correctAnswer: 'square'),
];

// Stage 18: Clothes
final stage18Writing = <Question>[
  const Question(id: 's18_w1', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'ぼうし', textJa: '日本語を英語にしよう',
    choices: ['coat', 'hat', 'scarf'], correctAnswer: 'hat'),
  const Question(id: 's18_w2', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'くつ', textJa: '日本語を英語にしよう',
    choices: ['shoes', 'socks', 'gloves'], correctAnswer: 'shoes'),
];

// Stage 19: Feelings
final stage19Writing = <Question>[
  const Question(id: 's19_w1', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'うれしい', textJa: '日本語を英語にしよう',
    choices: ['sad', 'happy', 'angry'], correctAnswer: 'happy'),
  const Question(id: 's19_w2', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'こわい', textJa: '日本語を英語にしよう',
    choices: ['scared', 'tired', 'bored'], correctAnswer: 'scared'),
];

// Stage 20: Fruits & Veg
final stage20Writing = <Question>[
  const Question(id: 's20_w1', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'りんご', textJa: '日本語を英語にしよう',
    choices: ['grape', 'apple', 'orange'], correctAnswer: 'apple'),
  const Question(id: 's20_w2', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'にんじん', textJa: '日本語を英語にしよう',
    choices: ['carrot', 'onion', 'potato'], correctAnswer: 'carrot'),
];

// Stage 21: Phrases 1
final stage21Writing = <Question>[
  const Question(id: 's21_w1', type: QuestionType.writing, difficulty: DifficultyLevel.intermediate,
    text: 'もう一度', textJa: '日本語を英語にしよう',
    choices: ['Again', 'Please', 'Sorry'], correctAnswer: 'Again'),
  const Question(id: 's21_w2', type: QuestionType.writing, difficulty: DifficultyLevel.intermediate,
    text: 'どういたしまして', textJa: '日本語を英語にしよう',
    choices: ['Sorry', 'You are welcome', 'Please'], correctAnswer: 'You are welcome'),
];

// Stage 22: Time Words
final stage22Writing = <Question>[
  const Question(id: 's22_w1', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'きょう', textJa: '日本語を英語にしよう',
    choices: ['yesterday', 'today', 'tomorrow'], correctAnswer: 'today'),
  const Question(id: 's22_w2', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'あした', textJa: '日本語を英語にしよう',
    choices: ['today', 'yesterday', 'tomorrow'], correctAnswer: 'tomorrow'),
];

// Stage 23: Days & Months
final stage23Writing = <Question>[
  const Question(id: 's23_w1', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'げつようび', textJa: '日本語を英語にしよう',
    choices: ['Sunday', 'Monday', 'Tuesday'], correctAnswer: 'Monday'),
  const Question(id: 's23_w2', type: QuestionType.writing, difficulty: DifficultyLevel.intermediate,
    text: 'さんがつ', textJa: '日本語を英語にしよう',
    choices: ['February', 'March', 'April'], correctAnswer: 'March'),
];

// Stage 24: Countries
final stage24Writing = <Question>[
  const Question(id: 's24_w1', type: QuestionType.writing, difficulty: DifficultyLevel.intermediate,
    text: 'にほん', textJa: '日本語を英語にしよう',
    choices: ['China', 'Japan', 'Korea'], correctAnswer: 'Japan'),
  const Question(id: 's24_w2', type: QuestionType.writing, difficulty: DifficultyLevel.intermediate,
    text: 'アメリカ', textJa: '日本語を英語にしよう',
    choices: ['America', 'Australia', 'Austria'], correctAnswer: 'America'),
];

// Stage 25: Shopping
final stage25Writing = <Question>[
  const Question(id: 's25_w1', type: QuestionType.writing, difficulty: DifficultyLevel.intermediate,
    text: 'いくらですか', textJa: '日本語を英語にしよう',
    choices: ['How much is it?', 'Where is it?', 'What is it?'], correctAnswer: 'How much is it?'),
  const Question(id: 's25_w2', type: QuestionType.writing, difficulty: DifficultyLevel.intermediate,
    text: 'これをください', textJa: '日本語を英語にしよう',
    choices: ['I want this please', 'Thank you', 'How much?'], correctAnswer: 'I want this please'),
];

// Stage 26: School 2
final stage26Writing = <Question>[
  const Question(id: 's26_w1', type: QuestionType.writing, difficulty: DifficultyLevel.intermediate,
    text: 'しゅくだい', textJa: '日本語を英語にしよう',
    choices: ['test', 'homework', 'textbook'], correctAnswer: 'homework'),
  const Question(id: 's26_w2', type: QuestionType.writing, difficulty: DifficultyLevel.intermediate,
    text: 'しけん', textJa: '日本語を英語にしよう',
    choices: ['test', 'class', 'grade'], correctAnswer: 'test'),
];

// Stage 27: Animals 2
final stage27Writing = <Question>[
  const Question(id: 's27_w1', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'ライオン', textJa: '日本語を英語にしよう',
    choices: ['tiger', 'lion', 'bear'], correctAnswer: 'lion'),
  const Question(id: 's27_w2', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'ぞう', textJa: '日本語を英語にしよう',
    choices: ['giraffe', 'elephant', 'hippo'], correctAnswer: 'elephant'),
];

// Stage 28: Phrases 2
final stage28Writing = <Question>[
  const Question(id: 's28_w1', type: QuestionType.writing, difficulty: DifficultyLevel.intermediate,
    text: 'がんばって', textJa: '日本語を英語にしよう',
    choices: ['Good luck', 'Good job', 'Good night'], correctAnswer: 'Good luck'),
  const Question(id: 's28_w2', type: QuestionType.writing, difficulty: DifficultyLevel.intermediate,
    text: 'だいじょうぶ', textJa: '日本語を英語にしよう',
    choices: ['No problem', 'Thank you', 'Sorry'], correctAnswer: 'No problem'),
];

// Stage 29: Home & Rooms
final stage29Writing = <Question>[
  const Question(id: 's29_w1', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'だいどころ', textJa: '日本語を英語にしよう',
    choices: ['bedroom', 'kitchen', 'bathroom'], correctAnswer: 'kitchen'),
  const Question(id: 's29_w2', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'まど', textJa: '日本語を英語にしよう',
    choices: ['door', 'window', 'wall'], correctAnswer: 'window'),
];

// Stage 30: My Day
final stage30Writing = <Question>[
  const Question(id: 's30_w1', type: QuestionType.writing, difficulty: DifficultyLevel.intermediate,
    text: 'おきる', textJa: '日本語を英語にしよう',
    choices: ['sleep', 'wake up', 'eat'], correctAnswer: 'wake up'),
  const Question(id: 's30_w2', type: QuestionType.writing, difficulty: DifficultyLevel.intermediate,
    text: 'ねる', textJa: '日本語を英語にしよう',
    choices: ['go to bed', 'get up', 'go to school'], correctAnswer: 'go to bed'),
];

// Stage 31: Phrases 3
final stage31Writing = <Question>[
  const Question(id: 's31_w1', type: QuestionType.writing, difficulty: DifficultyLevel.intermediate,
    text: 'ちょっと待って', textJa: '日本語を英語にしよう',
    choices: ['Wait a moment', 'Come here', 'Go away'], correctAnswer: 'Wait a moment'),
  const Question(id: 's31_w2', type: QuestionType.writing, difficulty: DifficultyLevel.intermediate,
    text: 'ごめんなさい', textJa: '日本語を英語にしよう',
    choices: ['Thank you', 'I am sorry', 'You are welcome'], correctAnswer: 'I am sorry'),
];

// Stage 32: Park & Play
final stage32Writing = <Question>[
  const Question(id: 's32_w1', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'ブランコ', textJa: '日本語を英語にしよう',
    choices: ['slide', 'swing', 'see-saw'], correctAnswer: 'swing'),
  const Question(id: 's32_w2', type: QuestionType.writing, difficulty: DifficultyLevel.intermediate,
    text: 'かくれんぼ', textJa: '日本語を英語にしよう',
    choices: ['tag', 'hide and seek', 'jump rope'], correctAnswer: 'hide and seek'),
];

// Stage 33: Health
final stage33Writing = <Question>[
  const Question(id: 's33_w1', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'ねつ', textJa: '日本語を英語にしよう',
    choices: ['cold', 'fever', 'cough'], correctAnswer: 'fever'),
  const Question(id: 's33_w2', type: QuestionType.writing, difficulty: DifficultyLevel.intermediate,
    text: 'くすり', textJa: '日本語を英語にしよう',
    choices: ['doctor', 'medicine', 'hospital'], correctAnswer: 'medicine'),
];

// Stage 34: Transport
final stage34Writing = <Question>[
  const Question(id: 's34_w1', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'でんしゃ', textJa: '日本語を英語にしよう',
    choices: ['bus', 'train', 'taxi'], correctAnswer: 'train'),
  const Question(id: 's34_w2', type: QuestionType.writing, difficulty: DifficultyLevel.intermediate,
    text: 'きっぷ', textJa: '日本語を英語にしよう',
    choices: ['ticket', 'passport', 'card'], correctAnswer: 'ticket'),
];

// Stage 35: Music & Art
final stage35Writing = <Question>[
  const Question(id: 's35_w1', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'おんがく', textJa: '日本語を英語にしよう',
    choices: ['dance', 'music', 'art'], correctAnswer: 'music'),
  const Question(id: 's35_w2', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'ギター', textJa: '日本語を英語にしよう',
    choices: ['piano', 'drum', 'guitar'], correctAnswer: 'guitar'),
];

// Stage 36: Technology
final stage36Writing = <Question>[
  const Question(id: 's36_w1', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'コンピューター', textJa: '日本語を英語にしよう',
    choices: ['tablet', 'computer', 'phone'], correctAnswer: 'computer'),
  const Question(id: 's36_w2', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'カメラ', textJa: '日本語を英語にしよう',
    choices: ['camera', 'speaker', 'screen'], correctAnswer: 'camera'),
];

// Stage 37: Holidays
final stage37Writing = <Question>[
  const Question(id: 's37_w1', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'たんじょうび', textJa: '日本語を英語にしよう',
    choices: ['Christmas', 'birthday', 'Halloween'], correctAnswer: 'birthday'),
  const Question(id: 's37_w2', type: QuestionType.writing, difficulty: DifficultyLevel.intermediate,
    text: 'プレゼント', textJa: '日本語を英語にしよう',
    choices: ['card', 'present', 'flower'], correctAnswer: 'present'),
];

// Stage 38: Classroom
final stage38Writing = <Question>[
  const Question(id: 's38_w1', type: QuestionType.writing, difficulty: DifficultyLevel.intermediate,
    text: 'て を あげて', textJa: '日本語を英語にしよう',
    choices: ['Sit down', 'Raise your hand', 'Open your book'], correctAnswer: 'Raise your hand'),
  const Question(id: 's38_w2', type: QuestionType.writing, difficulty: DifficultyLevel.intermediate,
    text: 'よくできました', textJa: '日本語を英語にしよう',
    choices: ['Good luck', 'Well done', 'Good morning'], correctAnswer: 'Well done'),
];

// Stage 39: Cooking
final stage39Writing = <Question>[
  const Question(id: 's39_w1', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'おいしい', textJa: '日本語を英語にしよう',
    choices: ['spicy', 'sour', 'delicious'], correctAnswer: 'delicious'),
  const Question(id: 's39_w2', type: QuestionType.writing, difficulty: DifficultyLevel.intermediate,
    text: 'だいどころ', textJa: '日本語を英語にしよう',
    choices: ['bathroom', 'kitchen', 'bedroom'], correctAnswer: 'kitchen'),
];

// Stage 40: Outdoors
final stage40Writing = <Question>[
  const Question(id: 's40_w1', type: QuestionType.writing, difficulty: DifficultyLevel.beginner,
    text: 'やま', textJa: '日本語を英語にしよう',
    choices: ['river', 'mountain', 'forest'], correctAnswer: 'mountain'),
  const Question(id: 's40_w2', type: QuestionType.writing, difficulty: DifficultyLevel.intermediate,
    text: 'キャンプ', textJa: '日本語を英語にしよう',
    choices: ['hiking', 'camping', 'fishing'], correctAnswer: 'camping'),
];
