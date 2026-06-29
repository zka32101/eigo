import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// レベル・XP システム
///
/// XP 獲得源:
///   レッスン完了       : 50 XP + 正解率ボーナス最大50XP
///   スピーキング練習   : 5 XP/問
///   テスト対策完了     : 30 XP + 正解率ボーナス
///   7日連続            : 100 XP ボーナス
///   バッジ獲得         : 20 XP/個
///
/// レベル閾値: (level-1)^2 * 100 XP
///   Lv1→2:  100 XP   Lv2→3:  400 XP   Lv3→4:  900 XP   Lv10→11: 10000 XP
class LevelState {
  final int totalXp;
  final int level;
  final int xpToNextLevel;
  final String rank;
  final String rankEmoji;

  const LevelState({
    this.totalXp = 0,
    this.level = 1,
    this.xpToNextLevel = 100,
    this.rank = 'ビギナー',
    this.rankEmoji = '🌱',
  });

  double get progressToNext {
    final prevLevelXp = _xpForLevel(level);
    final nextLevelXp = _xpForLevel(level + 1);
    if (nextLevelXp <= prevLevelXp) return 1.0;
    return (totalXp - prevLevelXp) / (nextLevelXp - prevLevelXp);
  }

  int get currentLevelXp => totalXp - _xpForLevel(level);
  int get xpNeededForNext => _xpForLevel(level + 1) - _xpForLevel(level);

  static int _xpForLevel(int lv) => lv <= 1 ? 0 : (lv - 1) * (lv - 1) * 100;

  static int levelForXp(int xp) {
    int lv = 1;
    while (_xpForLevel(lv + 1) <= xp) { lv++; }
    return lv;
  }

  static String rankFor(int lv) {
    if (lv >= 20) return 'マスター';
    if (lv >= 15) return 'エキスパート';
    if (lv >= 10) return 'アドバンスト';
    if (lv >= 7) return 'インターメディエイト';
    if (lv >= 4) return 'ビギナー+';
    return 'ビギナー';
  }

  static String rankEmojiFor(int lv) {
    if (lv >= 20) return '👑';
    if (lv >= 15) return '💎';
    if (lv >= 10) return '🏆';
    if (lv >= 7) return '⭐';
    if (lv >= 4) return '🌟';
    return '🌱';
  }

  LevelState copyWith({int? totalXp}) {
    final xp = totalXp ?? this.totalXp;
    final lv = levelForXp(xp);
    return LevelState(
      totalXp: xp,
      level: lv,
      xpToNextLevel: _xpForLevel(lv + 1) - xp,
      rank: rankFor(lv),
      rankEmoji: rankEmojiFor(lv),
    );
  }
}

class LevelNotifier extends StateNotifier<LevelState> {
  LevelNotifier() : super(const LevelState()) {
    _load();
  }

  static const _key = 'total_xp';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final xp = prefs.getInt(_key) ?? 0;
    state = state.copyWith(totalXp: xp);
  }

  /// XP を追加し、レベルアップした数を返す
  Future<int> addXp(int amount) async {
    final prevLevel = state.level;
    final newXp = state.totalXp + amount;
    state = state.copyWith(totalXp: newXp);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, newXp);
    return state.level - prevLevel;
  }

  // ─── XP 計算ヘルパー ────────────────────────────────────────

  static int xpForLesson({required int correct, required int total, bool isFirstClear = false}) {
    final accuracy = total > 0 ? correct / total : 0.0;
    return 50 + (accuracy * 50).round() + (isFirstClear ? 30 : 0);
  }

  static int xpForSpeaking(int questionCount) => questionCount * 5;

  static int xpForTestPrep({required int correct, required int total}) {
    final accuracy = total > 0 ? correct / total : 0.0;
    return 30 + (accuracy * 50).round();
  }

  static int xpForBadge() => 20;

  static int xpForStreak(int days) {
    if (days == 30) return 500;
    if (days == 7) return 100;
    if (days % 7 == 0) return 50;
    return 10;
  }
}

final levelProvider = StateNotifierProvider<LevelNotifier, LevelState>(
  (ref) => LevelNotifier(),
);

// レベルアップ演出用の一時的な通知
class LevelUpNotifier extends StateNotifier<int?> {
  LevelUpNotifier() : super(null);
  void notifyLevelUp(int newLevel) => state = newLevel;
  void clear() => state = null;
}

final levelUpNotifier = StateNotifierProvider<LevelUpNotifier, int?>(
  (ref) => LevelUpNotifier(),
);
