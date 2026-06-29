import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../data/stage_data.dart';
import '../providers/pronunciation_provider.dart';
import '../models/stage.dart';

class PronunciationCheckScreen extends ConsumerStatefulWidget {
  final Stage stage;

  const PronunciationCheckScreen({super.key, required this.stage});

  @override
  ConsumerState<PronunciationCheckScreen> createState() =>
      _PronunciationCheckScreenState();
}

class _PronunciationCheckScreenState
    extends ConsumerState<PronunciationCheckScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  List<String> _wordsToCheck = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _extractWordsFromStage();
  }

  void _extractWordsFromStage() {
    // ステージから最初の10個のユニークな単語を取得
    Set<String> wordsSet = {};
    for (var question in widget.stage.questions) {
      if (question.text.isNotEmpty && question.text.length < 30) {
        wordsSet.add(question.text);
        if (wordsSet.length >= 10) break;
      }
    }
    _wordsToCheck = wordsSet.toList();
  }

  Future<void> _checkWord(String word) async {
    await ref
        .read(pronunciationStateProvider.notifier)
        .checkPronunciation(word);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pronunciationState = ref.watch(pronunciationStateProvider);

    if (_wordsToCheck.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('🎤 発音チェック')),
        body: const Center(
          child: Text('チェックする単語がありません'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎤 発音チェック'),
        centerTitle: true,
        backgroundColor: const Color(0xFF378ADD),
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemCount: _wordsToCheck.length,
        itemBuilder: (context, index) {
          final word = _wordsToCheck[index];
          final result = pronunciationState.lastResult;
          final isCurrentWord =
              result != null && result.word == word && pronunciationState.isCheckingComplete;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Progress
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${index + 1}/${_wordsToCheck.length}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (index + 1) / _wordsToCheck.length,
                            minHeight: 6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Word Display
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text('発音してください', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      Text(
                        word,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF378ADD),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FloatingActionButton.extended(
                        onPressed: () async {
                          await ref
                              .read(pronunciationStateProvider.notifier)
                              .playExample(word);
                        },
                        icon: const Icon(Icons.volume_up),
                        label: const Text('例を聞く'),
                        backgroundColor: Colors.amber,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Recording Button
                if (!pronunciationState.isCheckingComplete ||
                    !isCurrentWord) ...[
                  FloatingActionButton.large(
                    onPressed: pronunciationState.isListening
                        ? () => ref
                            .read(pronunciationStateProvider.notifier)
                            .stopListening()
                            .then((_) => _checkWord(word))
                        : () => ref
                            .read(pronunciationStateProvider.notifier)
                            .startListening(),
                    backgroundColor: pronunciationState.isListening
                        ? Colors.red
                        : const Color(0xFF378ADD),
                    child: Icon(
                      pronunciationState.isListening
                          ? Icons.stop
                          : Icons.mic,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    pronunciationState.isListening
                        ? '話してください...'
                        : 'マイクボタンを押して発音',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],

                // Result Display
                if (isCurrentWord) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: result!.isPassed ? Colors.green[50] : Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: result.isPassed ? Colors.green : Colors.orange,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'あなたの発音: ${result.userPronunciation}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              result.feedbackEmoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: result.accuracy,
                            minHeight: 8,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              result.isPassed ? Colors.green : Colors.orange,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          result.accuracyPercentage,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: result.isPassed
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          result.feedback,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (index < _wordsToCheck.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                          ref
                              .read(pronunciationStateProvider.notifier)
                              .reset();
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        index < _wordsToCheck.length - 1
                            ? '次の単語へ'
                            : '完了',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],

                if (pronunciationState.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Text(
                      pronunciationState.errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
