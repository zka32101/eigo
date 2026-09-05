import 'package:flutter/material.dart';

/// スクリーントランジションウィジェット
/// スクリーン遷移時のアニメーション（フェード、スライド、スケール）
class ScreenTransitionWidget extends StatefulWidget {
  final Widget child;
  final TransitionType transitionType;
  final Duration duration;
  final bool isEntering;
  final VoidCallback? onTransitionComplete;

  const ScreenTransitionWidget({
    Key? key,
    required this.child,
    this.transitionType = TransitionType.fadeSlide,
    this.duration = const Duration(milliseconds: 500),
    this.isEntering = true,
    this.onTransitionComplete,
  }) : super(key: key);

  @override
  State<ScreenTransitionWidget> createState() => _ScreenTransitionWidgetState();
}

enum TransitionType {
  fade,
  slide,
  scale,
  fadeSlide,
  fadeScale,
  slideScale,
}

class _ScreenTransitionWidgetState extends State<ScreenTransitionWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _setupAnimations();

    if (widget.isEntering) {
      _controller.forward().then((_) {
        widget.onTransitionComplete?.call();
      });
    } else {
      _controller.reverse().then((_) {
        widget.onTransitionComplete?.call();
      });
    }
  }

  void _setupAnimations() {
    // オパシティアニメーション
    _opacityAnimation = Tween<double>(
      begin: widget.isEntering ? 0.0 : 1.0,
      end: widget.isEntering ? 1.0 : 0.0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // スライドアニメーション
    _slideAnimation = Tween<Offset>(
      begin: widget.isEntering ? const Offset(1.0, 0.0) : Offset.zero,
      end: widget.isEntering ? Offset.zero : const Offset(-1.0, 0.0),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // スケールアニメーション
    _scaleAnimation = Tween<double>(
      begin: widget.isEntering ? 0.8 : 1.0,
      end: widget.isEntering ? 1.0 : 0.8,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTransitionWidget();
  }

  Widget _buildTransitionWidget() {
    switch (widget.transitionType) {
      case TransitionType.fade:
        return FadeTransition(
          opacity: _opacityAnimation,
          child: widget.child,
        );

      case TransitionType.slide:
        return SlideTransition(
          position: _slideAnimation,
          child: widget.child,
        );

      case TransitionType.scale:
        return ScaleTransition(
          scale: _scaleAnimation,
          child: widget.child,
        );

      case TransitionType.fadeSlide:
        return FadeTransition(
          opacity: _opacityAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: widget.child,
          ),
        );

      case TransitionType.fadeScale:
        return FadeTransition(
          opacity: _opacityAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: widget.child,
          ),
        );

      case TransitionType.slideScale:
        return SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: widget.child,
          ),
        );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
