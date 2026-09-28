import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 無料トライアルの期間（日数）
const int kTrialDurationDays = 14;

class TrialState {
  /// 初回起動日時（未ロード時は null）
  final DateTime? firstLaunchAt;
  final bool isLoaded;

  const TrialState({this.firstLaunchAt, this.isLoaded = false});

  /// トライアル開始からの経過日数
  int get elapsedDays {
    if (firstLaunchAt == null) return 0;
    return DateTime.now().difference(firstLaunchAt!).inDays;
  }

  /// トライアル期間内かどうか（初回起動日を含め14日間）
  bool get isInTrial => isLoaded && elapsedDays < kTrialDurationDays;

  /// トライアル残り日数（0未満にはならない）
  int get remainingDays {
    final remaining = kTrialDurationDays - elapsedDays;
    return remaining < 0 ? 0 : remaining;
  }

  TrialState copyWith({DateTime? firstLaunchAt, bool? isLoaded}) {
    return TrialState(
      firstLaunchAt: firstLaunchAt ?? this.firstLaunchAt,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

/// 初回起動日時をSharedPreferencesに記録し、14日間の無料トライアル期間の
/// 判定に使う。初回起動時に一度だけ日時を保存し、以降はその日時を基準に
/// 経過日数を計算する。
class TrialNotifier extends StateNotifier<TrialState> {
  static const String _storageKey = 'eigo_kore_first_launch_at';

  TrialNotifier() : super(const TrialState()) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_storageKey);
    DateTime firstLaunchAt;
    if (stored != null) {
      firstLaunchAt = DateTime.parse(stored);
    } else {
      firstLaunchAt = DateTime.now();
      await prefs.setString(_storageKey, firstLaunchAt.toIso8601String());
    }
    state = TrialState(firstLaunchAt: firstLaunchAt, isLoaded: true);
  }
}

final trialProvider = StateNotifierProvider<TrialNotifier, TrialState>((ref) {
  return TrialNotifier();
});
