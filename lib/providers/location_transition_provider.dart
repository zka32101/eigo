import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eigo/models/english_town_model.dart';

/// ロケーション遷移状態を管理するStateNotifier
class LocationTransitionNotifier
    extends StateNotifier<LocationTransition?> {
  LocationTransitionNotifier() : super(null);

  /// ロケーション遷移を開始
  void startTransition(String fromLocationId, String toLocationId) {
    state = LocationTransition(
      fromLocationId: fromLocationId,
      toLocationId: toLocationId,
      durationMs: 500,
      status: 'animating',
      progress: 0.0,
      startedAt: DateTime.now(),
    );
  }

  /// 遷移の進捗を更新（0.0～1.0）
  void updateProgress(double progress) {
    if (state != null) {
      final clampedProgress = progress.clamp(0.0, 1.0);
      state = state!.copyWith(progress: clampedProgress);

      // 完了時にステータスを更新
      if (clampedProgress >= 1.0) {
        state = state!.copyWith(status: 'complete');
      }
    }
  }

  /// 遷移をクリア
  void clearTransition() {
    state = null;
  }

  /// 進捗率に基づいて遷移ステータスを計算
  double getElapsedProgress() {
    if (state == null) return 0.0;
    final elapsed = DateTime.now().difference(state!.startedAt).inMilliseconds;
    return (elapsed / state!.durationMs).clamp(0.0, 1.0);
  }
}

/// ロケーション遷移プロバイダー
final locationTransitionProvider =
    StateNotifierProvider<LocationTransitionNotifier, LocationTransition?>(
  (ref) => LocationTransitionNotifier(),
);

/// 現在遷移中かどうかを示すプロバイダー
final isTransitioningProvider = Provider<bool>((ref) {
  final transition = ref.watch(locationTransitionProvider);
  return transition != null && transition.status != 'complete';
});

/// 遷移の進捗率（0.0～1.0）を計算
final transitionProgressProvider = Provider<double>((ref) {
  final transition = ref.watch(locationTransitionProvider);
  if (transition == null) return 0.0;

  final elapsed =
      DateTime.now().difference(transition.startedAt).inMilliseconds;
  return (elapsed / transition.durationMs).clamp(0.0, 1.0);
});

/// 遷移開始アクション
final startLocationTransitionProvider =
    Provider.family<void, (String, String)>((ref, params) {
  final fromLocationId = params.$1;
  final toLocationId = params.$2;

  ref.read(locationTransitionProvider.notifier)
      .startTransition(fromLocationId, toLocationId);
});

/// 遷移終了アクション
final completeLocationTransitionProvider = Provider<void>((ref) {
  ref.read(locationTransitionProvider.notifier).clearTransition();
});
