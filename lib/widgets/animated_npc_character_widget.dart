import 'package:flutter/material.dart';
import 'package:eigo/services/npc_animation_service.dart';

/// アニメーション付きNPCキャラクターウィジェット
/// NPCの出現・動作・感情表現をアニメーションで表現
class AnimatedNPCCharacterWidget extends StatefulWidget {
  final String npcId;
  final String? npcName;
  final String? characterImage;
  final String emoticon;
  final NPCAnimationService.EmotionType emotion;
  final bool isAnimating;
  final Duration animationDuration;
  final VoidCallback? onAnimationComplete;

  const AnimatedNPCCharacterWidget({
    Key? key,
    required this.npcId,
    this.npcName,
    this.characterImage,
    this.emoticon = '✨',
    this.emotion = NPCAnimationService.EmotionType.neutral,
    this.isAnimating = true,
    this.animationDuration = const Duration(milliseconds: 500),
    this.onAnimationComplete,
  }) : super(key: key);

  @override
  State<AnimatedNPCCharacterWidget> createState() =>
      _AnimatedNPCCharacterWidgetState();
}

class _AnimatedNPCCharacterWidgetState extends State<AnimatedNPCCharacterWidget>
    with TickerProviderStateMixin {
  late AnimationController _appearanceController;
  late AnimationController _emotionController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _emotionAnimation;
  late Animation<Offset> _slideAnimation;

  final NPCAnimationService _animationService = NPCAnimationService.getInstance();

  @override
  void initState() {
    super.initState();

    // 出現アニメーション
    _appearanceController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _appearanceController, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _appearanceController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _appearanceController, curve: Curves.easeOut),
    );

    // 感情アニメーション
    _emotionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _emotionAnimation = _getEmotionAnimation(widget.emotion);

    if (widget.isAnimating) {
      _startAnimation();
    }
  }

  Animation<double> _getEmotionAnimation(NPCAnimationService.EmotionType emotion) {
    return _animationService.getEmotionAnimation(widget.npcId, emotion);
  }

  void _startAnimation() async {
    await _appearanceController.forward();
    _emotionController.forward();
    widget.onAnimationComplete?.call();
  }

  @override
  void didUpdateWidget(AnimatedNPCCharacterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 感情が変わった場合、アニメーションをリセット
    if (oldWidget.emotion != widget.emotion) {
      _emotionController.reset();
      _emotionAnimation = _getEmotionAnimation(widget.emotion);
      _emotionController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: AnimatedBuilder(
            animation: _emotionAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_emotionAnimation.value * 0.1),
                child: child,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // キャラクター画像または感情アイコン
                  if (widget.characterImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        widget.characterImage!,
                        width: 200,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      width: 200,
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.amber.shade700,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          widget.emoticon,
                          style: const TextStyle(fontSize: 80),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),

                  // NPC名
                  if (widget.npcName != null)
                    Text(
                      widget.npcName!,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade700,
                          ),
                    ),

                  // 感情状態インジケーター
                  const SizedBox(height: 8),
                  _buildEmotionIndicator(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmotionIndicator() {
    final emotionText = _getEmotionText(widget.emotion);
    final emotionColor = _getEmotionColor(widget.emotion);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: emotionColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: emotionColor, width: 1),
      ),
      child: Text(
        emotionText,
        style: TextStyle(
          color: emotionColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getEmotionText(NPCAnimationService.EmotionType emotion) {
    switch (emotion) {
      case NPCAnimationService.EmotionType.happy:
        return '😊 嬉しい';
      case NPCAnimationService.EmotionType.sad:
        return '😢 悲しい';
      case NPCAnimationService.EmotionType.angry:
        return '😠 怒っている';
      case NPCAnimationService.EmotionType.surprised:
        return '😮 驚いている';
      case NPCAnimationService.EmotionType.excited:
        return '🤩 興奮している';
      case NPCAnimationService.EmotionType.confused:
        return '🤔 戸惑っている';
      case NPCAnimationService.EmotionType.thinking:
        return '💭 考えている';
      default:
        return '😐 普通';
    }
  }

  Color _getEmotionColor(NPCAnimationService.EmotionType emotion) {
    switch (emotion) {
      case NPCAnimationService.EmotionType.happy:
        return Colors.green;
      case NPCAnimationService.EmotionType.sad:
        return Colors.blue;
      case NPCAnimationService.EmotionType.angry:
        return Colors.red;
      case NPCAnimationService.EmotionType.surprised:
        return Colors.yellow;
      case NPCAnimationService.EmotionType.excited:
        return Colors.pink;
      case NPCAnimationService.EmotionType.confused:
        return Colors.orange;
      case NPCAnimationService.EmotionType.thinking:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _appearanceController.dispose();
    _emotionController.dispose();
    super.dispose();
  }
}
