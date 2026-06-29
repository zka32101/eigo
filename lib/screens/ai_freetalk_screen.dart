import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../providers/claude_conversation_provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/ai_api_key_provider.dart';

class AiFreetalkScreen extends ConsumerStatefulWidget {
  const AiFreetalkScreen({super.key});

  @override
  ConsumerState<AiFreetalkScreen> createState() => _AiFreetalkScreenState();
}

class _AiFreetalkScreenState extends ConsumerState<AiFreetalkScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _tts = FlutterTts();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApiServices();
    _initializeTts();
  }

  Future<void> _initializeApiServices() async {
    final currentUser = ref.read(currentUserProvider);
    final apiKeys = ref.read(aiApiKeysProvider);

    if (currentUser != null && !_isInitialized) {
      ref.read(claudeConversationProvider.notifier).initializeApiServices(
        geminiKey: apiKeys.geminiKey,
        claudeKey: apiKeys.claudeKey,
        userGrade: '${currentUser.grade}',
      );
      setState(() => _isInitialized = true);
    }
  }

  Future<void> _initializeTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
  }

  Future<void> _speak(String text) async {
    await _tts.speak(text);
  }

  Future<void> _sendMessage() async {
    if (_textController.text.isEmpty) return;

    final message = _textController.text;
    _textController.clear();

    await ref.read(claudeConversationProvider.notifier).sendMessage(message);

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conversation = ref.watch(claudeConversationProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 AIフリートーク'),
        centerTitle: true,
        backgroundColor: const Color(0xFF378ADD),
      ),
      body: Column(
        children: [
          if (conversation.error != null)
            Container(
              color: Colors.red[50],
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      conversation.error!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => ref.read(claudeConversationProvider.notifier).clearConversation(),
                    child: const Icon(Icons.close, color: Colors.red),
                  ),
                ],
              ),
            ),
          Expanded(
            child: conversation.messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${currentUser?.avatar ?? '👧'} ${currentUser?.name ?? 'フレンド'}',
                          style: const TextStyle(fontSize: 48),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Hello! Let\'s chat in English!\n英語でお話ししよう！',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: conversation.messages.length,
                    itemBuilder: (context, index) {
                      final message = conversation.messages[index];
                      final isUser = message.role == 'user';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Align(
                          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.8,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isUser ? const Color(0xFF378ADD) : Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.text,
                                  style: TextStyle(
                                    color: isUser ? Colors.white : Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                                if (!isUser && !message.isError)
                                  GestureDetector(
                                    onTap: () => _speak(message.text),
                                    child: const Icon(
                                      Icons.volume_up,
                                      size: 14,
                                      color: Color(0xFF378ADD),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'メッセージを入力...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    enabled: !conversation.isLoading,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: const Color(0xFF378ADD),
                  onPressed: conversation.isLoading ? null : _sendMessage,
                  child: conversation.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
