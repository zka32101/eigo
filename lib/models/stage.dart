import 'question.dart';

enum StageCategory {
  // Stage 1-10 (既存)
  greetings, numbers, colors, animals, food, school, family, body, weather, hobbies,
  // Stage 11-20 (新規)
  vehicles, sports, jobs, seasons, places, nature, shapes, clothes, feelings, fruitsVeg,
  // Stage 21-30 (新規)
  phrases1, timeWords, daysMonths, countries, shopping, school2, animals2, phrases2, homeLife, myDay,
  // Stage 31-40 (追加)
  phrases3, park, health, transport, musicArt, technology, holidays, classroom, cooking, outdoors,
  // Stage 41-60 (拡充)
  space, insects, sports2, feelings2, comparing, clock, ocean, farm, myTown, verbs,
  food2, japanCulture, fantasy, schoolEvents, questionWords, science, worldCulture, sports3, dailyRoutine2, review,
  // Stage 61-80 (英検5級対応)
  verbsAdv, timeAdv, foodAdv, animalsAdv, placesDir,
  dailyRoutineAdv, sportsAdv, natureAdv2, familyPeople, schoolSubjects,
  jobsAdv, bodyHealth2, emotionsAdv, clothesFashion, technologyAdv,
  travelTransport, holidaysEvents, sentencePractice, eiken5prep, finalReview,
}

class Stage {
  final String id;
  final int grade;
  final int stageNumber;
  final String title;
  final String titleJa;
  final String emoji;
  final StageCategory category;
  final List<Question> questions;
  final int passingScore;

  const Stage({
    required this.id,
    required this.grade,
    required this.stageNumber,
    required this.title,
    required this.titleJa,
    required this.emoji,
    required this.category,
    required this.questions,
    this.passingScore = 60,
  });

  int get listeningCount => questions.where((q) => q.type == QuestionType.listening).length;
  int get speakingCount  => questions.where((q) => q.type == QuestionType.speaking).length;
  int get readingCount   => questions.where((q) => q.type == QuestionType.reading).length;
  int get writingCount   => questions.where((q) => q.type == QuestionType.writing).length;
}

String stageCategoryLabel(StageCategory cat) {
  switch (cat) {
    case StageCategory.greetings:  return 'あいさつ';
    case StageCategory.numbers:    return '数字';
    case StageCategory.colors:     return '色';
    case StageCategory.animals:    return '動物';
    case StageCategory.food:       return '食べ物';
    case StageCategory.school:     return '学校';
    case StageCategory.family:     return '家族';
    case StageCategory.body:       return 'からだ';
    case StageCategory.weather:    return '天気';
    case StageCategory.hobbies:    return '趣味';
    case StageCategory.vehicles:   return '乗り物';
    case StageCategory.sports:     return 'スポーツ';
    case StageCategory.jobs:       return '職業';
    case StageCategory.seasons:    return '季節';
    case StageCategory.places:     return '町・場所';
    case StageCategory.nature:     return '自然';
    case StageCategory.shapes:     return '形・サイズ';
    case StageCategory.clothes:    return '服・ファッション';
    case StageCategory.feelings:   return '気持ち';
    case StageCategory.fruitsVeg:  return 'くだもの・野菜';
    case StageCategory.phrases1:   return 'フレーズ①';
    case StageCategory.timeWords:  return '時間';
    case StageCategory.daysMonths: return '曜日・月';
    case StageCategory.countries:  return '国・言語';
    case StageCategory.shopping:   return '買い物';
    case StageCategory.school2:    return '学校②';
    case StageCategory.animals2:   return '動物②';
    case StageCategory.phrases2:   return 'フレーズ②';
    case StageCategory.homeLife:   return '家・部屋';
    case StageCategory.myDay:      return '1日の生活';
    case StageCategory.phrases3:   return 'フレーズ③';
    case StageCategory.park:       return '公園・あそび';
    case StageCategory.health:     return '健康・病院';
    case StageCategory.transport:  return '交通・移動';
    case StageCategory.musicArt:   return '音楽・芸術';
    case StageCategory.technology: return 'テクノロジー';
    case StageCategory.holidays:   return '祝日・行事';
    case StageCategory.classroom:  return '教室英語';
    case StageCategory.cooking:    return '料理・キッチン';
    case StageCategory.outdoors:      return 'アウトドア・自然';
    case StageCategory.space:         return '宇宙';
    case StageCategory.insects:       return '虫・こんちゅう';
    case StageCategory.sports2:       return 'スポーツ②';
    case StageCategory.feelings2:     return '気持ち②';
    case StageCategory.comparing:     return '比較';
    case StageCategory.clock:         return '時刻';
    case StageCategory.ocean:         return '海・水族館';
    case StageCategory.farm:          return '農業・田舎';
    case StageCategory.myTown:        return 'まち・地域';
    case StageCategory.verbs:         return '動詞';
    case StageCategory.food2:         return '食べ物②';
    case StageCategory.japanCulture:  return '日本文化';
    case StageCategory.fantasy:       return 'ファンタジー';
    case StageCategory.schoolEvents:  return '学校行事';
    case StageCategory.questionWords: return '疑問詞';
    case StageCategory.science:       return '理科';
    case StageCategory.worldCulture:  return '世界の文化';
    case StageCategory.sports3:       return 'スポーツ③';
    case StageCategory.dailyRoutine2: return '日課②';
    case StageCategory.review:        return '総まとめ';
    case StageCategory.verbsAdv:      return '動詞（上級）';
    case StageCategory.timeAdv:       return '時間（上級）';
    case StageCategory.foodAdv:       return '食べ物（上級）';
    case StageCategory.animalsAdv:    return '動物（上級）';
    case StageCategory.placesDir:     return '場所・道案内';
    case StageCategory.dailyRoutineAdv: return '日課（上級）';
    case StageCategory.sportsAdv:     return 'スポーツ（上級）';
    case StageCategory.natureAdv2:    return '自然（上級）';
    case StageCategory.familyPeople:  return '家族・人々';
    case StageCategory.schoolSubjects: return '教科・勉強';
    case StageCategory.jobsAdv:       return '職業（上級）';
    case StageCategory.bodyHealth2:   return '体・健康②';
    case StageCategory.emotionsAdv:   return '感情（上級）';
    case StageCategory.clothesFashion: return '服・ファッション②';
    case StageCategory.technologyAdv: return 'テクノロジー②';
    case StageCategory.travelTransport: return '旅行・交通';
    case StageCategory.holidaysEvents: return '祝日・イベント';
    case StageCategory.sentencePractice: return '文章練習';
    case StageCategory.eiken5prep:    return '英検5級対策';
    case StageCategory.finalReview:   return '最終まとめ';
  }
}
