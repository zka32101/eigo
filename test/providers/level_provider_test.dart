import 'package:flutter_test/flutter_test.dart';
import 'package:eigo_kore/providers/level_provider.dart';

void main() {
  group('LevelState', () {
    test('初期状態は Lv1、XP=0', () {
      const state = LevelState();
      expect(state.level, 1);
      expect(state.totalXp, 0);
      expect(state.rank, 'ビギナー');
      expect(state.rankEmoji, '🌱');
    });

    test('XP=100 で Lv2 になる', () {
      final state = const LevelState().copyWith(totalXp: 100);
      expect(state.level, 2);
    });

    test('XP=99 は Lv1 のまま', () {
      final state = const LevelState().copyWith(totalXp: 99);
      expect(state.level, 1);
    });

    test('XP=400 で Lv3 になる', () {
      final state = const LevelState().copyWith(totalXp: 400);
      expect(state.level, 3);
    });

    test('Lv10 のランクは アドバンスト', () {
      expect(LevelState.rankFor(10), 'アドバンスト');
    });

    test('Lv15 のランクは エキスパート', () {
      expect(LevelState.rankFor(15), 'エキスパート');
    });

    test('Lv20 のランクは マスター', () {
      expect(LevelState.rankFor(20), 'マスター');
    });

    test('progressToNext は 0.0 〜 1.0 の範囲', () {
      final state = const LevelState().copyWith(totalXp: 50);
      expect(state.progressToNext, greaterThanOrEqualTo(0.0));
      expect(state.progressToNext, lessThanOrEqualTo(1.0));
    });

    test('Lv2 の途中: progressToNext は 0.5 (xp=250/400)', () {
      // Lv2: 100-399 XP、Lv3: 400XP
      // (250-100) / (400-100) = 150/300 = 0.5
      final state = const LevelState().copyWith(totalXp: 250);
      expect(state.level, 2);
      expect(state.progressToNext, closeTo(0.5, 0.01));
    });
  });

  group('LevelNotifier XP 計算', () {
    test('レッスン完了 XP: 全問正解 + 初回クリア = 50+50+30 = 130', () {
      final xp = LevelNotifier.xpForLesson(correct: 10, total: 10, isFirstClear: true);
      expect(xp, 130);
    });

    test('レッスン完了 XP: 全問正解、初回でない = 50+50 = 100', () {
      final xp = LevelNotifier.xpForLesson(correct: 10, total: 10);
      expect(xp, 100);
    });

    test('レッスン完了 XP: 正解率60% = 50+30 = 80', () {
      final xp = LevelNotifier.xpForLesson(correct: 6, total: 10);
      expect(xp, 80);
    });

    test('スピーキング練習 XP: 8問 = 40', () {
      expect(LevelNotifier.xpForSpeaking(8), 40);
    });

    test('テスト対策 XP: 全問正解 = 30+50 = 80', () {
      final xp = LevelNotifier.xpForTestPrep(correct: 10, total: 10);
      expect(xp, 80);
    });

    test('バッジ獲得 XP = 20', () {
      expect(LevelNotifier.xpForBadge(), 20);
    });

    test('7日連続 XP = 100', () {
      expect(LevelNotifier.xpForStreak(7), 100);
    });

    test('30日連続 XP = 500', () {
      expect(LevelNotifier.xpForStreak(30), 500);
    });
  });
}
