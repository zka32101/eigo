import 'package:flutter/animation.dart';

/// ロケーション遷移のアニメーション設定
class LocationTransitionAnimation {
  /// アニメーション期間
  final Duration duration;

  /// 曲線（イージング）
  final Curve curve;

  /// スライド距離（ピクセル）
  final double slideDistance;

  /// フェードインの期間
  final Duration fadeInDuration;

  LocationTransitionAnimation({
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeInOut,
    this.slideDistance = 20.0,
    this.fadeInDuration = const Duration(milliseconds: 300),
  });
}

/// タウンアニメーションサービス（シングルトンパターン）
/// ロケーション遷移のアニメーション効果を管理
class TownAnimationService {
  static final TownAnimationService _instance =
      TownAnimationService._internal();

  factory TownAnimationService() {
    return _instance;
  }

  TownAnimationService._internal();

  /// デフォルトアニメーション設定
  late LocationTransitionAnimation _defaultAnimation =
      LocationTransitionAnimation();

  /// シングルトンインスタンスを取得
  static TownAnimationService getInstance() {
    return _instance;
  }

  /// デフォルトアニメーション設定を設定
  void setDefaultAnimation(LocationTransitionAnimation animation) {
    _defaultAnimation = animation;
  }

  /// デフォルトアニメーション設定を取得
  LocationTransitionAnimation getDefaultAnimation() {
    return _defaultAnimation;
  }

  /// スライドアニメーション値を計算（0.0～1.0の進捗から）
  double calculateSlideValue(double progress) {
    final curve = _defaultAnimation.curve;
    final curvedProgress = curve.transform(progress);
    return curvedProgress * _defaultAnimation.slideDistance;
  }

  /// フェードアニメーション値を計算（0.0～1.0の進捗から）
  double calculateFadeValue(double progress) {
    // フェードインは全体の60%で完了
    final fadeProgress = (progress / 0.6).clamp(0.0, 1.0);
    return fadeProgress;
  }

  /// スケールアニメーション値を計算（0.0～1.0の進捗から）
  double calculateScaleValue(double progress) {
    // 0.8～1.0のスケール範囲でアニメーション
    final curve = _defaultAnimation.curve;
    final curvedProgress = curve.transform(progress);
    return 0.8 + (curvedProgress * 0.2);
  }

  /// 回転アニメーション値を計算（度数法で返す）
  double calculateRotationValue(double progress) {
    final curve = _defaultAnimation.curve;
    final curvedProgress = curve.transform(progress);
    return curvedProgress * 5.0; // 最大5度回転
  }

  /// オフセット値を計算（スライド方向）
  Offset calculateOffsetValue(double progress, bool isOutgoing) {
    final slideValue = calculateSlideValue(progress);
    final x = isOutgoing ? -slideValue : slideValue;
    return Offset(x, 0);
  }

  /// アニメーション時間を計算（ミリ秒）
  int getAnimationDurationMs() {
    return _defaultAnimation.duration.inMilliseconds;
  }

  /// アニメーション曲線を取得
  Curve getAnimationCurve() {
    return _defaultAnimation.curve;
  }

  /// フェードイン期間を取得
  Duration getFadeInDuration() {
    return _defaultAnimation.fadeInDuration;
  }

  /// 複雑なアニメーション用のカスタム曲線を生成
  /// （複数の段階を組み合わせたアニメーション）
  double calculateComplexAnimationValue(double progress, String type) {
    final curve = _defaultAnimation.curve;
    final curvedProgress = curve.transform(progress);

    switch (type) {
      case 'slideOut':
        return -_defaultAnimation.slideDistance * curvedProgress;
      case 'slideIn':
        return _defaultAnimation.slideDistance * (1.0 - curvedProgress);
      case 'fadeOut':
        return 1.0 - curvedProgress;
      case 'fadeIn':
        return curvedProgress;
      case 'scale':
        return 0.9 + (curvedProgress * 0.1);
      default:
        return curvedProgress;
    }
  }
}
