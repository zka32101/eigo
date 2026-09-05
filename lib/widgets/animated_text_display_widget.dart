import 'package:flutter/material.dart';

/// アニメーション付きテキスト表示ウィジェット
/// テキストが段階的に表示されるアニメーション
class AnimatedTextDisplayWidget extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration characterDuration;
  final TextAlign textAlign;
  final int maxLines;
  final VoidCallback? onComplete;
  final bool autoPlay;

  const AnimatedTextDisplayWidget({
    Key? key,
    required this.text,
    this.style,
    this.characterDuration = const Duration(milliseconds: 30),
    this.textAlign = TextAlign.left,
    this.maxLines = 10,
    this.onComplete,
    this.autoPlay = true,
  }) : super(key: key);

  @override
  State<AnimatedTextDisplayWidget> createState() =>
      _AnimatedTextDisplayWidgetState();
}

class _AnimatedTextDisplayWidgetState extends State<AnimatedTextDisplayWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  int _displayedCharacters = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(
        milliseconds: widget.characterDuration.inMilliseconds * widget.text.length,
      ),
      vsync: this,
    );

    _controller.addListener(_updateDisplayedText);

    if (widget.autoPlay) {
      _controller.forward();
    }
  }

  void _updateDisplayedText() {
    final newCharCount = (widget.text.length * _controller.value).toInt();
    if (newCharCount != _displayedCharacters) {
      setState(() {
        _displayedCharacters = newCharCount;
      });

      // テキスト表示完了チェック
      if (_displayedCharacters == widget.text.length) {
        widget.onComplete?.call();
      }
    }
  }

  void play() {
    _controller.forward(from: _controller.value);
  }

  void pause() {
    _controller.stop();
  }

  void reset() {
    _controller.reset();
    setState(() {
      _displayedCharacters = 0;
    });
  }

  void skipToEnd() {
    _controller.animateTo(1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text.substring(0, _displayedCharacters),
      style: widget.style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
