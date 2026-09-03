import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eigo/models/english_town_model.dart';
import 'package:eigo/design_system/design_system.dart';
import 'package:eigo/services/town_animation_service.dart';

/// ロケーション遷移画面
/// ロケーション間を移動する際のアニメーション遷移を管理
class LocationTransitionScreen extends ConsumerStatefulWidget {
  final Location fromLocation;
  final Location toLocation;
  final VoidCallback onTransitionComplete;

  const LocationTransitionScreen({
    Key? key,
    required this.fromLocation,
    required this.toLocation,
    required this.onTransitionComplete,
  }) : super(key: key);

  @override
  ConsumerState<LocationTransitionScreen> createState() =>
      _LocationTransitionScreenState();
}

class _LocationTransitionScreenState
    extends ConsumerState<LocationTransitionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  final _animationService = TownAnimationService();

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  /// アニメーションを初期化
  void _initializeAnimation() {
    final animConfig = _animationService.getDefaultAnimation();

    _animationController = AnimationController(
      duration: animConfig.duration,
      vsync: this,
    );

    // フェードアニメーション
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // スライドアニメーション（左へスライドアウト、右からスライドイン）
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.0, 0.0),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    // スケールアニメーション
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    // アニメーション終了時にコールバック
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onTransitionComplete();
      }
    });

    // アニメーションを開始
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 出発地ロケーション（フェードアウト）
        FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildLocationView(widget.fromLocation),
          ),
        ),

        // 目的地ロケーション（フェードイン＆スケールイン）
        FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
            ),
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
              ),
            ),
            child: _buildLocationView(widget.toLocation),
          ),
        ),

        // ローディングインジケーター
        Center(
          child: FadeTransition(
            opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
              ),
            ),
            child: _buildTransitionOverlay(),
          ),
        ),
      ],
    );
  }

  /// ロケーションビューを構築
  Widget _buildLocationView(Location location) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.surfaceLight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            location.emoji,
            style: const TextStyle(fontSize: 80),
          ),
          SizedBox(height: AppSpacing.spacingLg),
          Text(
            location.name,
            style: AppTypography.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ) ?? const TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.spacingMd),
          Text(
            location.description,
            style: AppTypography.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ) ?? const TextStyle(color: Colors.grey, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 遷移中のオーバーレイを構築
  Widget _buildTransitionOverlay() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.accentGreen,
              width: 3,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.accentGreen,
              ),
            ),
          ),
        ),
        SizedBox(height: AppSpacing.spacingMd),
        Text(
          'Moving to ${widget.toLocation.name}...',
          style: AppTypography.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ) ?? const TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }
}

/// スケールトランジション（カスタム）
class ScaleTransition extends AnimatedWidget {
  final Widget child;
  final Alignment alignment;

  const ScaleTransition({
    Key? key,
    required Animation<double> scale,
    required this.child,
    this.alignment = Alignment.center,
  }) : super(key: key, listenable: scale);

  Animation<double> get scale => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    final value = scale.value;
    return Transform.scale(
      scale: value,
      alignment: alignment,
      child: child,
    );
  }
}
