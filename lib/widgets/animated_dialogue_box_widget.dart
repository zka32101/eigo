import 'package:flutter/material.dart';
import 'package:eigo/services/npc_animation_service.dart';
import 'package:eigo/services/npc_sound_effects_service.dart';

/// アニメーション付きダイアログボックスウィジェット
/// テキストが段階的に表示されるダイアログボックス
class AnimatedDialogueBoxWidget extends StatefulWidget {
  final String npcName;
  final String dialogueText;
  final String emoticon;
  final VoidCallback? onComplete;
  final Duration textAnimationDuration;
  final bool autoPlay;

  const AnimatedDialogueBoxWidget({
    Key? key,
    required this.npcName,
    required this.dialogueText,
    this.emoticon = '✨',
    this.onComplete,
    this.textAnimationDuration = const Duration(milliseconds: 30),
    this.autoPlay = true,
  }) : super(key: key);

  @override
  State<AnimatedDialogueBoxWidget> createState() =>
      _AnimatedDialogueBoxWidgetState();
}

class _AnimatedDialogueBoxWidgetState extends State<AnimatedDialogueBoxWidget>
    with TickerProviderStateMixin {
  late AnimationController _appearanceController;
  late AnimationController _textController;
  late Animation<double> _appearanceAnimation;
  int _displayedCharacters = 0;

  final NPCAnimationService _animationService = NPCAnimationService.getInstance();
  final NPCSoundEffectsService _soundService = NPCSoundEffectsService.getInstance();

  @override
  void initState() {
    super.initState();

    // 出現アニメーション
    _appearanceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _appearanceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _appearanceController, curve: Curves.easeOut),
    );

    // テキストアニメーション
    _textController = AnimationController(
      duration: Duration(
        milliseconds: widget.textAnimationDuration.inMilliseconds *
            widget.dialogueText.length,
      ),
      vsync: this,
    );

    if (widget.autoPlay) {
      _startAnimation();
    }

    _textController.addListener(_updateDisplayedText);
  }

  void _startAnimation() async {
    await _appearanceController.forward();
    _soundService.playDialogueOpenSound();
    await _textController.forward();
    widget.onComplete?.call();
  }

  void _updateDisplayedText() {
    final newCharCount =
        (widget.dialogueText.length * _textController.value).toInt();
    if (newCharCount != _displayedCharacters) {
      setState(() {
        _displayedCharacters = newCharCount;
      });
      // テキスト入力音を再生（ミュート時は再生されない）
      _soundService.playTextTypeSound();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _appearanceAnimation,
      child: ScaleTransition(
        scale: _appearanceAnimation,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.amber.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // NPC 名と感情
              Row(
                children: [
                  Text(
                    widget.emoticon,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.npcName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade700,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ダイアログテキスト（段階的表示）
              Text(
                widget.dialogueText.substring(0, _displayedCharacters),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                      color: Colors.grey.shade800,
                    ),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),

              // テキスト完了インジケーター
              if (_displayedCharacters == widget.dialogueText.length)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _buildContinueIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(
              parent: _textController,
              curve: Curves.elasticOut,
            ),
          ),
          child: const Icon(
            Icons.arrow_forward,
            color: Colors.amber,
            size: 20,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _appearanceController.dispose();
    _textController.dispose();
    super.dispose();
  }
}
