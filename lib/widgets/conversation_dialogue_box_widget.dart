import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eigo/models/dialogue_template_model.dart';
import 'package:eigo/providers/dialogue_context_provider.dart';

/// 会話ダイアログボックスウィジェット
/// NPC とプレイヤー間の会話メッセージを表示
class ConversationDialogueBoxWidget extends ConsumerWidget {
  final String npcName;
  final ScrollController? scrollController;
  final bool showTimestamps;
  final bool showTranslations;

  const ConversationDialogueBoxWidget({
    Key? key,
    required this.npcName,
    this.scrollController,
    this.showTimestamps = true,
    this.showTranslations = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(conversationHistoryProvider);

    if (history.isEmpty) {
      return Center(
        child: Text(
          'No messages yet. Start a conversation!',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(12.0),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final message = history[index];
        final isNPC = message.speaker == 'npc';

        return _buildMessageBubble(
          context,
          message,
          isNPC,
        );
      },
    );
  }

  /// メッセージバブルを構築
  Widget _buildMessageBubble(
    BuildContext context,
    DialogueMessage message,
    bool isNPC,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            isNPC ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                color: isNPC ? Colors.blue.shade100 : Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              child: Column(
                crossAxisAlignment:
                    isNPC ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                children: [
                  // スピーカー名と感情
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isNPC && message.emotion != null) ...[
                        Text(
                          message.emotion!,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        isNPC ? npcName : 'You',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isNPC ? Colors.blue : Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // メッセージテキスト
                  Text(
                    message.text,
                    style: const TextStyle(fontSize: 14),
                  ),

                  // 英語翻訳
                  if (showTranslations &&
                      message.englishTranslation != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      message.englishTranslation!,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],

                  // タイムスタンプ
                  if (showTimestamps) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 時刻をフォーマット
  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

/// メッセージバブル表示ウィジェット（スタンドアロン版）
class MessageBubbleWidget extends StatelessWidget {
  final String message;
  final bool isNPC;
  final String speaker;
  final String? emotion;
  final String? translation;
  final DateTime? timestamp;

  const MessageBubbleWidget({
    Key? key,
    required this.message,
    required this.isNPC,
    required this.speaker,
    this.emotion,
    this.translation,
    this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            isNPC ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                color: isNPC ? Colors.blue.shade100 : Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              child: Column(
                crossAxisAlignment:
                    isNPC ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                children: [
                  // スピーカー情報
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (emotion != null) ...[
                        Text(
                          emotion!,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        speaker,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isNPC ? Colors.blue : Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // メッセージ
                  Text(
                    message,
                    style: const TextStyle(fontSize: 14),
                  ),

                  // 翻訳
                  if (translation != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      translation!,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],

                  // タイムスタンプ
                  if (timestamp != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(timestamp!),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

/// ストリーミング応答メッセージウィジェット
class StreamingMessageBubbleWidget extends StatefulWidget {
  final String npcName;
  final String initialText;
  final String? emotion;
  final Stream<String> stream;

  const StreamingMessageBubbleWidget({
    Key? key,
    required this.npcName,
    required this.initialText,
    required this.stream,
    this.emotion,
  }) : super(key: key);

  @override
  State<StreamingMessageBubbleWidget> createState() =>
      _StreamingMessageBubbleWidgetState();
}

class _StreamingMessageBubbleWidgetState
    extends State<StreamingMessageBubbleWidget> {
  late String _displayText;

  @override
  void initState() {
    super.initState();
    _displayText = widget.initialText;

    // ストリーミング応答を監視
    widget.stream.listen((chunk) {
      setState(() {
        _displayText += chunk;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // スピーカー
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.emotion != null) ...[
                        Text(
                          widget.emotion!,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        widget.npcName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // ストリーミングテキスト
                  Text(
                    _displayText,
                    style: const TextStyle(fontSize: 14),
                  ),

                  // カーソル（アニメーション）
                  const SizedBox(height: 4),
                  _buildStreamingCursor(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ストリーミングカーソルを構築
  Widget _buildStreamingCursor() {
    return SizedBox(
      width: 2,
      height: 16,
      child: ColoredBox(
        color: Colors.blue.shade400,
      ),
    );
  }
}
