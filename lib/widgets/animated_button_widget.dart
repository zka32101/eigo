import 'package:flutter/material.dart';
import 'package:eigo/services/npc_animation_service.dart';
import 'package:eigo/services/npc_sound_effects_service.dart';

/// アニメーション付きボタンウィジェット
/// タップ時にスケール/フェードアニメーション付きの反応
class AnimatedButtonWidget extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final bool enabled;
  final double width;
  final double height;
  final EdgeInsets? padding;

  const AnimatedButtonWidget({
    Key? key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.enabled = true,
    this.width = 200,
    this.height = 50,
    this.padding,
  }) : super(key: key);

  @override
  State<AnimatedButtonWidget> createState() => _AnimatedButtonWidgetState();
}

class _AnimatedButtonWidgetState extends State<AnimatedButtonWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;

  final NPCAnimationService _animationService = NPCAnimationService.getInstance();
  final NPCSoundEffectsService _soundService = NPCSoundEffectsService.getInstance();

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    // スケールアニメーション（ボタン押下時）
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );

    // ホバーアニメーション
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _hoverAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.enabled) return;

    setState(() => _isPressed = true);
    _scaleController.forward();
    _soundService.playButtonClickSound();
  }

  void _onTapUp(TapUpDetails details) {
    if (!widget.enabled) return;

    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _onTapCancel() {
    if (!widget.enabled) return;

    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _onPressed() {
    if (!widget.enabled) return;

    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: MouseRegion(
          onEnter: (_) {
            if (widget.enabled) {
              _hoverController.forward();
            }
          },
          onExit: (_) {
            if (widget.enabled) {
              _hoverController.reverse();
            }
          },
          child: ScaleTransition(
            scale: _hoverAnimation,
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              onTap: _onPressed,
              child: Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  color: widget.enabled
                      ? (widget.backgroundColor ?? Colors.amber)
                      : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.amber.shade700,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: widget.enabled
                              ? (widget.textColor ?? Colors.white)
                              : Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _hoverController.dispose();
    super.dispose();
  }
}
