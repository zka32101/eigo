import '../models/stage.dart';
import 'question_data.dart';
import 'question_data_extra.dart';
import 'question_data_extra2.dart';
import 'question_data_extra3.dart';
import 'question_data_extra4.dart';
import 'writing_supplement.dart';
import 'question_data_extra5.dart';
import 'question_data_extra6.dart';

final allStages = <Stage>[
  // ── 既存 Stage 1-10 ──────────────────────────────────────────────────────
  Stage(id: 'stage_1',  grade: 1, stageNumber: 1,  title: 'Greetings',   titleJa: 'あいさつ',       emoji: '👋',  category: StageCategory.greetings, questions: stage1Questions),
  Stage(id: 'stage_2',  grade: 1, stageNumber: 2,  title: 'Numbers',     titleJa: '数字',           emoji: '🔢',  category: StageCategory.numbers,   questions: stage2Questions),
  Stage(id: 'stage_3',  grade: 2, stageNumber: 3,  title: 'Colors',      titleJa: '色',             emoji: '🎨',  category: StageCategory.colors,    questions: [...stage3Questions,  ...stage3Writing]),
  Stage(id: 'stage_4',  grade: 2, stageNumber: 4,  title: 'Animals',     titleJa: '動物',           emoji: '🐾',  category: StageCategory.animals,   questions: [...stage4Questions,  ...stage4Writing]),
  Stage(id: 'stage_5',  grade: 3, stageNumber: 5,  title: 'Food',        titleJa: '食べ物',         emoji: '🍽️', category: StageCategory.food,      questions: [...stage5Questions,  ...stage5Writing]),
  Stage(id: 'stage_6',  grade: 3, stageNumber: 6,  title: 'School',      titleJa: '学校',           emoji: '🏫',  category: StageCategory.school,    questions: [...stage6Questions,  ...stage6Writing]),
  Stage(id: 'stage_7',  grade: 4, stageNumber: 7,  title: 'Family',      titleJa: '家族',           emoji: '👨‍👩‍👧', category: StageCategory.family, questions: [...stage7Questions,  ...stage7Writing]),
  Stage(id: 'stage_8',  grade: 4, stageNumber: 8,  title: 'Body Parts',  titleJa: 'からだ',         emoji: '🧍',  category: StageCategory.body,      questions: [...stage8Questions,  ...stage8Writing]),
  Stage(id: 'stage_9',  grade: 5, stageNumber: 9,  title: 'Weather',     titleJa: '天気',           emoji: '⛅',  category: StageCategory.weather,   questions: [...stage9Questions,  ...stage9Writing]),
  Stage(id: 'stage_10', grade: 5, stageNumber: 10, title: 'Hobbies',     titleJa: '趣味',           emoji: '🎯',  category: StageCategory.hobbies,   questions: [...stage10Questions, ...stage10Writing]),

  // ── 新規 Stage 11-20 ─────────────────────────────────────────────────────
  Stage(id: 'stage_11', grade: 3, stageNumber: 11, title: 'Vehicles',    titleJa: '乗り物',         emoji: '🚗',  category: StageCategory.vehicles,  questions: [...stage11Questions, ...stage11Writing]),
  Stage(id: 'stage_12', grade: 3, stageNumber: 12, title: 'Sports',      titleJa: 'スポーツ',       emoji: '⚽',  category: StageCategory.sports,    questions: [...stage12Questions, ...stage12Writing]),
  Stage(id: 'stage_13', grade: 4, stageNumber: 13, title: 'Jobs',        titleJa: '職業',           emoji: '👩‍💼', category: StageCategory.jobs,      questions: [...stage13Questions, ...stage13Writing]),
  Stage(id: 'stage_14', grade: 4, stageNumber: 14, title: 'Seasons',     titleJa: '季節',           emoji: '🌸',  category: StageCategory.seasons,   questions: [...stage14Questions, ...stage14Writing]),
  Stage(id: 'stage_15', grade: 4, stageNumber: 15, title: 'Places',      titleJa: '町・場所',       emoji: '🏪',  category: StageCategory.places,    questions: [...stage15Questions, ...stage15Writing]),
  Stage(id: 'stage_16', grade: 4, stageNumber: 16, title: 'Nature',      titleJa: '自然',           emoji: '🌿',  category: StageCategory.nature,    questions: [...stage16Questions, ...stage16Writing]),
  Stage(id: 'stage_17', grade: 5, stageNumber: 17, title: 'Shapes',      titleJa: '形・サイズ',     emoji: '🔷',  category: StageCategory.shapes,    questions: [...stage17Questions, ...stage17Writing]),
  Stage(id: 'stage_18', grade: 5, stageNumber: 18, title: 'Clothes',     titleJa: '服・ファッション', emoji: '👗', category: StageCategory.clothes,   questions: [...stage18Questions, ...stage18Writing]),
  Stage(id: 'stage_19', grade: 5, stageNumber: 19, title: 'Feelings',    titleJa: '気持ち',         emoji: '😊',  category: StageCategory.feelings,  questions: [...stage19Questions, ...stage19Writing]),
  Stage(id: 'stage_20', grade: 5, stageNumber: 20, title: 'Fruits & Veg',titleJa: 'くだもの・野菜', emoji: '🍎',  category: StageCategory.fruitsVeg, questions: [...stage20Questions, ...stage20Writing]),

  // ── 新規 Stage 21-30 ─────────────────────────────────────────────────────
  Stage(id: 'stage_21', grade: 5, stageNumber: 21, title: 'Phrases 1',   titleJa: 'フレーズ①',     emoji: '💬',  category: StageCategory.phrases1,  questions: [...stage21Questions, ...stage21Writing]),
  Stage(id: 'stage_22', grade: 5, stageNumber: 22, title: 'Time',        titleJa: '時間',           emoji: '⏰',  category: StageCategory.timeWords, questions: [...stage22Questions, ...stage22Writing]),
  Stage(id: 'stage_23', grade: 6, stageNumber: 23, title: 'Days & Months',titleJa: '曜日・月',      emoji: '📅',  category: StageCategory.daysMonths,questions: [...stage23Questions, ...stage23Writing]),
  Stage(id: 'stage_24', grade: 6, stageNumber: 24, title: 'Countries',   titleJa: '国・言語',       emoji: '🌍',  category: StageCategory.countries, questions: [...stage24Questions, ...stage24Writing]),
  Stage(id: 'stage_25', grade: 6, stageNumber: 25, title: 'Shopping',    titleJa: '買い物',         emoji: '🛒',  category: StageCategory.shopping,  questions: [...stage25Questions, ...stage25Writing]),
  Stage(id: 'stage_26', grade: 6, stageNumber: 26, title: 'School 2',    titleJa: '学校②',         emoji: '📚',  category: StageCategory.school2,   questions: [...stage26Questions, ...stage26Writing]),
  Stage(id: 'stage_27', grade: 6, stageNumber: 27, title: 'Animals 2',   titleJa: '動物②',         emoji: '🦁',  category: StageCategory.animals2,  questions: [...stage27Questions, ...stage27Writing]),
  Stage(id: 'stage_28', grade: 6, stageNumber: 28, title: 'Phrases 2',   titleJa: 'フレーズ②',     emoji: '🗣️', category: StageCategory.phrases2,  questions: [...stage28Questions, ...stage28Writing]),
  Stage(id: 'stage_29', grade: 6, stageNumber: 29, title: 'Home & Rooms',titleJa: '家・部屋',       emoji: '🏠',  category: StageCategory.homeLife,  questions: [...stage29Questions, ...stage29Writing]),
  Stage(id: 'stage_30', grade: 6, stageNumber: 30, title: 'My Day',      titleJa: '1日の生活',     emoji: '📆',  category: StageCategory.myDay,     questions: [...stage30Questions, ...stage30Writing]),

  // ── 追加 Stage 31-40 ─────────────────────────────────────────────────────
  Stage(id: 'stage_31', grade: 4, stageNumber: 31, title: 'Daily Phrases',  titleJa: 'フレーズ③',     emoji: '💬',  category: StageCategory.phrases3,   questions: [...stage31Questions,  ...stage31Writing]),
  Stage(id: 'stage_32', grade: 3, stageNumber: 32, title: 'Park & Play',    titleJa: '公園・あそび',   emoji: '🛝',  category: StageCategory.park,        questions: [...stage32Questions,  ...stage32Writing]),
  Stage(id: 'stage_33', grade: 4, stageNumber: 33, title: 'Health',         titleJa: '健康・病院',     emoji: '🏥',  category: StageCategory.health,      questions: [...stage33Questions,  ...stage33Writing]),
  Stage(id: 'stage_34', grade: 4, stageNumber: 34, title: 'Transport',      titleJa: '交通・移動',     emoji: '🚃',  category: StageCategory.transport,   questions: [...stage34Questions,  ...stage34Writing]),
  Stage(id: 'stage_35', grade: 5, stageNumber: 35, title: 'Music & Art',    titleJa: '音楽・芸術',     emoji: '🎵',  category: StageCategory.musicArt,    questions: [...stage35Questions,  ...stage35Writing]),
  Stage(id: 'stage_36', grade: 5, stageNumber: 36, title: 'Technology',     titleJa: 'テクノロジー',   emoji: '💻',  category: StageCategory.technology,  questions: [...stage36Questions,  ...stage36Writing]),
  Stage(id: 'stage_37', grade: 5, stageNumber: 37, title: 'Holidays',       titleJa: '祝日・行事',     emoji: '🎉',  category: StageCategory.holidays,    questions: [...stage37Questions,  ...stage37Writing]),
  Stage(id: 'stage_38', grade: 4, stageNumber: 38, title: 'Classroom',      titleJa: '教室英語',       emoji: '🏫',  category: StageCategory.classroom,   questions: [...stage38Questions,  ...stage38Writing]),
  Stage(id: 'stage_39', grade: 4, stageNumber: 39, title: 'Cooking',        titleJa: '料理・キッチン', emoji: '🍳',  category: StageCategory.cooking,     questions: [...stage39Questions,  ...stage39Writing]),
  Stage(id: 'stage_40', grade: 5, stageNumber: 40, title: 'Outdoors',       titleJa: 'アウトドア・自然', emoji: '🌲', category: StageCategory.outdoors,   questions: [...stage40Questions,  ...stage40Writing]),

  // ── 拡充 Stage 41-60 ─────────────────────────────────────────────────────
  Stage(id: 'stage_41', grade: 5, stageNumber: 41, title: 'Space',          titleJa: '宇宙',           emoji: '🚀',  category: StageCategory.space,         questions: stage41Questions),
  Stage(id: 'stage_42', grade: 3, stageNumber: 42, title: 'Insects',        titleJa: '虫・こんちゅう', emoji: '🦋',  category: StageCategory.insects,       questions: stage42Questions),
  Stage(id: 'stage_43', grade: 4, stageNumber: 43, title: 'Sports 2',       titleJa: 'スポーツ②',     emoji: '🏸',  category: StageCategory.sports2,       questions: stage43Questions),
  Stage(id: 'stage_44', grade: 4, stageNumber: 44, title: 'Feelings 2',     titleJa: '気持ち②',       emoji: '🥺',  category: StageCategory.feelings2,     questions: stage44Questions),
  Stage(id: 'stage_45', grade: 5, stageNumber: 45, title: 'Comparing',      titleJa: '比較',           emoji: '⚖️', category: StageCategory.comparing,     questions: stage45Questions),
  Stage(id: 'stage_46', grade: 4, stageNumber: 46, title: 'Time & Clock',   titleJa: '時刻',           emoji: '🕐',  category: StageCategory.clock,         questions: stage46Questions),
  Stage(id: 'stage_47', grade: 4, stageNumber: 47, title: 'Ocean & Sea',    titleJa: '海・水族館',     emoji: '🐳',  category: StageCategory.ocean,         questions: stage47Questions),
  Stage(id: 'stage_48', grade: 3, stageNumber: 48, title: 'Farm & Nature',  titleJa: '農業・田舎',     emoji: '🌾',  category: StageCategory.farm,          questions: stage48Questions),
  Stage(id: 'stage_49', grade: 4, stageNumber: 49, title: 'My Town',        titleJa: 'まち・地域',     emoji: '🏘️', category: StageCategory.myTown,        questions: stage49Questions),
  Stage(id: 'stage_50', grade: 4, stageNumber: 50, title: 'Action Verbs',   titleJa: '動詞',           emoji: '🏃',  category: StageCategory.verbs,         questions: stage50Questions),
  Stage(id: 'stage_51', grade: 4, stageNumber: 51, title: 'Food 2',         titleJa: '食べ物②',       emoji: '🍜',  category: StageCategory.food2,         questions: stage51Questions),
  Stage(id: 'stage_52', grade: 5, stageNumber: 52, title: 'Japan & Culture',titleJa: '日本文化',       emoji: '⛩️', category: StageCategory.japanCulture,  questions: stage52Questions),
  Stage(id: 'stage_53', grade: 5, stageNumber: 53, title: 'Fantasy',        titleJa: 'ファンタジー',   emoji: '🐉',  category: StageCategory.fantasy,       questions: stage53Questions),
  Stage(id: 'stage_54', grade: 5, stageNumber: 54, title: 'School Events',  titleJa: '学校行事',       emoji: '🏆',  category: StageCategory.schoolEvents,  questions: stage54Questions),
  Stage(id: 'stage_55', grade: 5, stageNumber: 55, title: 'Question Words', titleJa: '疑問詞',         emoji: '❓',  category: StageCategory.questionWords, questions: stage55Questions),
  Stage(id: 'stage_56', grade: 6, stageNumber: 56, title: 'Science',        titleJa: '理科',           emoji: '🔬',  category: StageCategory.science,       questions: stage56Questions),
  Stage(id: 'stage_57', grade: 6, stageNumber: 57, title: 'World Culture',  titleJa: '世界の文化',     emoji: '🗺️', category: StageCategory.worldCulture,  questions: stage57Questions),
  Stage(id: 'stage_58', grade: 5, stageNumber: 58, title: 'Sports 3',       titleJa: 'スポーツ③',     emoji: '🏆',  category: StageCategory.sports3,       questions: stage58Questions),
  Stage(id: 'stage_59', grade: 5, stageNumber: 59, title: 'Daily Routine 2',titleJa: '日課②',         emoji: '🌅',  category: StageCategory.dailyRoutine2, questions: stage59Questions),
  Stage(id: 'stage_60', grade: 6, stageNumber: 60, title: 'Final Review',   titleJa: '総まとめ',       emoji: '🌟',  category: StageCategory.review,        questions: stage60Questions),

  // ── 英検5級対応 Stage 61-80 ──────────────────────────────────────────────
  Stage(id: 'stage_61', grade: 5, stageNumber: 61, title: 'Advanced Verbs',      titleJa: '動詞（上級）',     emoji: '🏃',  category: StageCategory.verbsAdv,        questions: stage61Questions),
  Stage(id: 'stage_62', grade: 5, stageNumber: 62, title: 'Advanced Time',       titleJa: '時間（上級）',     emoji: '⏰',  category: StageCategory.timeAdv,         questions: stage62Questions),
  Stage(id: 'stage_63', grade: 5, stageNumber: 63, title: 'Advanced Food',       titleJa: '食べ物（上級）',   emoji: '🍕',  category: StageCategory.foodAdv,         questions: stage63Questions),
  Stage(id: 'stage_64', grade: 5, stageNumber: 64, title: 'Advanced Animals',    titleJa: '動物（上級）',     emoji: '🐘',  category: StageCategory.animalsAdv,      questions: stage64Questions),
  Stage(id: 'stage_65', grade: 5, stageNumber: 65, title: 'Places & Directions', titleJa: '場所・道案内',     emoji: '🗺️', category: StageCategory.placesDir,       questions: stage65Questions),
  Stage(id: 'stage_66', grade: 5, stageNumber: 66, title: 'Daily Routine Adv',   titleJa: '日課（上級）',     emoji: '🌅',  category: StageCategory.dailyRoutineAdv, questions: stage66Questions),
  Stage(id: 'stage_67', grade: 5, stageNumber: 67, title: 'Advanced Sports',     titleJa: 'スポーツ（上級）', emoji: '🏆',  category: StageCategory.sportsAdv,       questions: stage67Questions),
  Stage(id: 'stage_68', grade: 5, stageNumber: 68, title: 'Advanced Nature',     titleJa: '自然（上級）',     emoji: '🌋',  category: StageCategory.natureAdv2,      questions: stage68Questions),
  Stage(id: 'stage_69', grade: 5, stageNumber: 69, title: 'Family & People',     titleJa: '家族・人々',       emoji: '👨‍👩‍👧‍👦', category: StageCategory.familyPeople,   questions: stage69Questions),
  Stage(id: 'stage_70', grade: 5, stageNumber: 70, title: 'School Subjects',     titleJa: '教科・勉強',       emoji: '📐',  category: StageCategory.schoolSubjects,  questions: stage70Questions),
  Stage(id: 'stage_71', grade: 6, stageNumber: 71, title: 'Advanced Jobs',       titleJa: '職業（上級）',     emoji: '👨‍💻', category: StageCategory.jobsAdv,         questions: stage71Questions),
  Stage(id: 'stage_72', grade: 6, stageNumber: 72, title: 'Body & Health 2',     titleJa: '体・健康②',       emoji: '💊',  category: StageCategory.bodyHealth2,     questions: stage72Questions),
  Stage(id: 'stage_73', grade: 6, stageNumber: 73, title: 'Advanced Emotions',   titleJa: '感情（上級）',     emoji: '🎭',  category: StageCategory.emotionsAdv,     questions: stage73Questions),
  Stage(id: 'stage_74', grade: 6, stageNumber: 74, title: 'Clothes & Fashion',   titleJa: '服・ファッション②', emoji: '👔', category: StageCategory.clothesFashion,  questions: stage74Questions),
  Stage(id: 'stage_75', grade: 6, stageNumber: 75, title: 'Advanced Tech',       titleJa: 'テクノロジー②',   emoji: '🤖',  category: StageCategory.technologyAdv,   questions: stage75Questions),
  Stage(id: 'stage_76', grade: 6, stageNumber: 76, title: 'Travel & Transport',  titleJa: '旅行・交通',       emoji: '✈️',  category: StageCategory.travelTransport, questions: stage76Questions),
  Stage(id: 'stage_77', grade: 6, stageNumber: 77, title: 'Holidays & Events',   titleJa: '祝日・イベント',   emoji: '🎆',  category: StageCategory.holidaysEvents,  questions: stage77Questions),
  Stage(id: 'stage_78', grade: 6, stageNumber: 78, title: 'Sentence Practice',   titleJa: '文章練習',         emoji: '📝',  category: StageCategory.sentencePractice, questions: stage78Questions),
  Stage(id: 'stage_79', grade: 6, stageNumber: 79, title: 'Eiken Grade 5',       titleJa: '英検5級対策',      emoji: '📋',  category: StageCategory.eiken5prep,      questions: stage79Questions),
  Stage(id: 'stage_80', grade: 6, stageNumber: 80, title: 'Final Master Review', titleJa: '最終まとめ',       emoji: '🏅',  category: StageCategory.finalReview,     questions: stage80Questions),
];
