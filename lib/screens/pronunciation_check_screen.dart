import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../data/stage_data.dart';
import '../providers/pronunciation_provider.dart';
import '../models/stage.dart';
import '../theme/app_theme.dart';
import '../theme/spacing.dart';
import '../theme/sizes.dart';
import '../theme/typography.dart';

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
            padding: AppSpacing.allPaddingLg,
            child: Column(
              children: [
                // Progress
                Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.xl),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${index + 1}/${_wordsToCheck.length}',
                        style: AppTypography.bodySmall.copyWith(color: Colors.grey),
                      ),
                      AppSpacing.horizontalSpacerXs,
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
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
                  padding: EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
                  ),
                  child: Column(
                    children: [
                      Text('発音してください', style: AppTypography.bodySmall.copyWith(color: Colors.grey)),
                      AppSpacing.verticalSpacerSm,
                      Text(
                        word,
                        style: AppTypography.headlineLarge.copyWith(
                          color: const Color(0xFF378ADD),
                        ),
                      ),
                      AppSpacing.verticalSpacerXl,
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
                AppSpacing.verticalSpacerXxl,

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
                  AppSpacing.verticalSpacerXs,
                  Text(
                    pronunciationState.isListening
                        ? '話してください...'
                        : 'マイクボタンを押して発音',
                    style: AppTypography.bodySmall.copyWith(color: Colors.grey),
                  ),
                ],

                // Result Display
                if (isCurrentWord) ...[
                  AppSpacing.verticalSpacerXl,
                  Container(
                    padding: AppSpacing.allPaddingMd,
                    decoration: BoxDecoration(
                      color: result!.isPassed ? Colors.green[50] : Colors.orange[50],
                      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
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
                              style: AppTypography.bodySmall,
                            ),
                            Text(
                              result.feedbackEmoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ],
                        ),
                        AppSpacing.verticalSpacerXs,
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                          child: LinearProgressIndicator(
                            value: result.accuracy,
                            minHeight: 8,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              result.isPassed ? Colors.green : Colors.orange,
                            ),
                          ),
                        ),
                        AppSpacing.verticalSpacerXs,
                        Text(
                          result.accuracyPercentage,
                          style: AppTypography.labelLarge.copyWith(
                            color: result.isPassed
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                        AppSpacing.verticalSpacerXs,
                        Text(
                          result.feedback,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.verticalSpacerXl,
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
                        style: AppTypography.labelLarge,
                      ),
                    ),
                  ),
                ],

                if (pronunciationState.errorMessage != null) ...[
                  AppSpacing.verticalSpacerSm,
                  Container(
                    padding: AppSpacing.allPaddingXs,
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Text(
                      pronunciationState.errorMessage!,
                      style: AppTypography.bodySmall.copyWith(color: Colors.red),
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
