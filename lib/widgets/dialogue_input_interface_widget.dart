import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eigo/providers/dialogue_context_provider.dart';

/// ダイアログ入力インターフェースウィジェット
/// プレイヤーがNPCに応答を入力するためのインターフェース
class DialogueInputInterfaceWidget extends ConsumerStatefulWidget {
  final void Function(String)? onSubmit;
  final int minCharacters;
  final int maxCharacters;
  final bool showCharacterCount;
  final String submitButtonLabel;
  final bool enableVoiceInput;

  const DialogueInputInterfaceWidget({
    Key? key,
    this.onSubmit,
    this.minCharacters = 2,
    this.maxCharacters = 500,
    this.showCharacterCount = true,
    this.submitButtonLabel = 'Send',
    this.enableVoiceInput = false,
  }) : super(key: key);

  @override
  ConsumerState<DialogueInputInterfaceWidget> createState() =>
      _DialogueInputInterfaceWidgetState();
}

class _DialogueInputInterfaceWidgetState
    extends ConsumerState<DialogueInputInterfaceWidget> {
  late TextEditingController _textController;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _textController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// 入力を検証
  void _validateInput() {
    setState(() {
      _isValid = _textController.text.trim().length >= widget.minCharacters &&
          _textController.text.length <= widget.maxCharacters;
    });
  }

  /// 入力を送信
  void _submitInput() {
    if (!_isValid) return;

    final input = _textController.text.trim();
    final dialogueContextNotifier =
        ref.read(dialogueContextProvider.notifier);

    // コンテキストを更新
    dialogueContextNotifier.setPlayerInput(input);

    // コールバックを実行
    widget.onSubmit?.call(input);

    // テキストフィールドをクリア
    _textController.clear();
  }

  /// 音声入力を開始（プレースホルダー）
  void _startVoiceInput() {
    // TODO: 音声入力実装
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voice input not yet implemented')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // テキスト入力フィールド
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ラベル
              const Text(
                'Your Response',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),

              // 入力フィールド
              TextField(
                controller: _textController,
                maxLines: 3,
                minLines: 1,
                maxLength: widget.maxCharacters,
                textInputAction: TextInputAction.send,
                onSubmitted: _isValid ? (_) => _submitInput() : null,
                decoration: InputDecoration(
                  hintText: 'Type your response here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  suffixIcon: _textController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _textController.clear();
                          },
                        )
                      : null,
                ),
              ),

              // 文字数表示
              if (widget.showCharacterCount) ...[
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    '${_textController.text.length}/${widget.maxCharacters}',
                    style: TextStyle(
                      fontSize: 10,
                      color: _textController.text.length > widget.maxCharacters
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                ),
              ],

              // 最小文字数警告
              if (_textController.text.isNotEmpty &&
                  _textController.text.length < widget.minCharacters) ...[
                const SizedBox(height: 6),
                Text(
                  'Minimum ${widget.minCharacters} characters required',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.orange,
                  ),
                ),
              ],
            ],
          ),
        ),

        // ボタン行
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 音声入力ボタン
              if (widget.enableVoiceInput)
                FloatingActionButton.small(
                  onPressed: _startVoiceInput,
                  backgroundColor: Colors.grey,
                  child: const Icon(Icons.mic),
                ),

              // 送信ボタン
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: widget.enableVoiceInput ? 8.0 : 0,
                  ),
                  child: ElevatedButton(
                    onPressed: _isValid ? _submitInput : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isValid ? Colors.blue : Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      widget.submitButtonLabel,
                      style: TextStyle(
                        color: _isValid ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ヒント/クイック応答（オプション）
        _buildQuickResponses(),
      ],
    );
  }

  /// クイック応答を構築
  Widget _buildQuickResponses() {
    const suggestions = [
      'That sounds great!',
      'I see what you mean.',
      'Can you tell me more?',
      'That\'s interesting.',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Quick Responses',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: suggestions.map((suggestion) {
              return InputChip(
                label: Text(
                  suggestion,
                  style: const TextStyle(fontSize: 11),
                ),
                onPressed: () {
                  _textController.text = suggestion;
                  _validateInput();
                },
                backgroundColor: Colors.grey.shade100,
                side: BorderSide(color: Colors.grey.shade300),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// ミニマル入力ウィジェット（シンプル版）
class MinimalDialogueInputWidget extends ConsumerStatefulWidget {
  final void Function(String)? onSubmit;
  final bool showSendButton;

  const MinimalDialogueInputWidget({
    Key? key,
    this.onSubmit,
    this.showSendButton = true,
  }) : super(key: key);

  @override
  ConsumerState<MinimalDialogueInputWidget> createState() =>
      _MinimalDialogueInputWidgetState();
}

class _MinimalDialogueInputWidgetState
    extends ConsumerState<MinimalDialogueInputWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_controller.text.isEmpty) return;

    widget.onSubmit?.call(_controller.text);
    ref.read(dialogueContextProvider.notifier).setPlayerInput(_controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type your response...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                isDense: true,
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
          if (widget.showSendButton) ...[
            const SizedBox(width: 8),
            FloatingActionButton.small(
              onPressed: _submit,
              child: const Icon(Icons.send),
            ),
          ],
        ],
      ),
    );
  }
}
