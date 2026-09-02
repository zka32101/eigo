import '../design_system/design_system.dart';
import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/stage.dart';
import '../services/tts_service.dart';

class WordReviewScreen extends StatefulWidget {
  final Stage stage;
  const WordReviewScreen({super.key, required this.stage});

  @override
  State<WordReviewScreen> createState() => _WordReviewScreenState();
}

class _WordReviewScreenState extends State<WordReviewScreen> {
  final _tts = TtsService();
  int _currentIndex = 0;
  bool _showBack = false;

  List<Question> get _cards => widget.stage.questions
      .where((q) => q.type == QuestionType.speaking || q.type == QuestionType.listening)
      .toList();

  Question get _current => _cards[_currentIndex];

  void _next() {
    if (_currentIndex < _cards.length - 1) {
      setState(() { _currentIndex++; _showBack = false; });
    } else {
      Navigator.pop(context);
    }
  }

  void _prev() {
    if (_currentIndex > 0) {
      setState(() { _currentIndex--; _showBack = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('📚 ${widget.stage.titleJa} 単語カード'),
        backgroundColor: AppColors.primary,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: AppSpacing.lg),
            child: Center(
              child: Text(
                '${_currentIndex + 1} / ${_cards.length}',
                style: AppTypography.labelLarge.copyWith(color: AppColors.textWhite),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // プログレス
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _cards.length,
            backgroundColor:AppColors.textMuted,
            color: AppColors.primary,
            minHeight: 4,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  // フラッシュカード
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _showBack = !_showBack),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                        child: _showBack ? _BackCard(question: _current) : _FrontCard(question: _current),
                      ),
                    ),
                  ),
                  AppSpacing.verticalSpacerMd,
                  // ヒント
                  Text(
                    _showBack ? '表に戻すにはタップ' : 'タップして意味を確認',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                  ),
                  AppSpacing.verticalSpacerLg,
                  // ボタン列
                  Row(
                    children: [
                      // 発音ボタン
                      IconButton.outlined(
                        icon: const Icon(Icons.volume_up),
                        onPressed: () => _tts.speak(_current.text),
                        style: IconButton.styleFrom(foregroundColor: AppColors.primary),
                      ),
                      AppSpacing.horizontalSpacerXs,
                      // ゆっくりボタン
                      OutlinedButton.icon(
                        icon: const Icon(Icons.slow_motion_video, size: 16),
                        label: const Text('ゆっくり'),
                        onPressed: () => _tts.speakSlow(_current.text),
                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary),
                      ),
                      const Spacer(),
                      // 前へ
                      IconButton.filled(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: _currentIndex > 0 ? _prev : null,
                        style: IconButton.styleFrom(backgroundColor:AppColors.textMuted),
                      ),
                      AppSpacing.horizontalSpacerXs,
                      // 次へ
                      ElevatedButton.icon(
                        icon: Icon(_currentIndex < _cards.length - 1 ? Icons.arrow_forward : Icons.check),
                        label: Text(_currentIndex < _cards.length - 1 ? 'つぎへ' : '完了'),
                        onPressed: _next,
                      ),
                    ],
                  ),
                  AppSpacing.verticalSpacerMd,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FrontCard extends StatelessWidget {
  final Question question;
  const _FrontCard({required this.question});

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const ValueKey('front'),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge)),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withAlpha(25)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
        ),
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (question.imageEmoji != null)
              Text(question.imageEmoji!, style: const TextStyle(fontSize: 72)),
            const SizedBox(height: 20),
            Text(
              question.text,
              style: AppTypography.headlineLarge.copyWith(
                color:AppColors.textWhite,
                letterSpacing: 1,
              ),
              textAlign: TextAlign.center,
            ),
            if (question.phonetic != null) ...[
              const SizedBox(height: 8),
              Text(
                question.phonetic!,
                style: AppTypography.bodySmall.copyWith(color: AppColors.textWhite.withOpacity(0.7), fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BackCard extends StatelessWidget {
  final Question question;
  const _BackCard({required this.question});

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const ValueKey('back'),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge)),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color:AppColors.textWhite,
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
          border: Border.all(color: AppColors.primary.withAlpha(76), width: 2),
        ),
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🇯🇵', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 16),
            Text(
              question.textJa.contains('言ってみよう') || question.textJa.contains('聞いて')
                  ? question.correctAnswer
                  : question.textJa,
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: AppSpacing.allPaddingMd,
              decoration: BoxDecoration(
                color: kBgLight,
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              ),
              child: Text(
                question.text,
                style: AppTypography.labelLarge.copyWith(fontSize: 22, color: AppColors.primary),
              ),
            ),
            if (question.phonetic != null) ...[
              const SizedBox(height: 8),
              Text(
                question.phonetic!,
                style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
