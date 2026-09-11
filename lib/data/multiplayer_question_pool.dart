import 'dart:math';

import '../models/question.dart';
import 'stage_data.dart';

class MultiplayerQuestionPool {
  const MultiplayerQuestionPool._();

  static List<Question>? _cache;

  static List<Question> get _all {
    return _cache ??= allStages
        .expand((stage) => stage.questions)
        .where((q) =>
            q.choices.length >= 2 &&
            (q.type == QuestionType.listening || q.type == QuestionType.reading))
        .toList(growable: false);
  }

  /// [count] 問をランダムに抽出する（[seed] を与えると両プレイヤー間で
  /// 同じ問題セットを再現できる）。
  static List<Question> draw({int count = 10, int? seed}) {
    final pool = List<Question>.from(_all);
    pool.shuffle(seed != null ? Random(seed) : Random());
    if (pool.length <= count) return pool;
    return pool.take(count).toList();
  }
}
