import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/teacher_mode_model.dart';
import '../providers/teacher_mode_provider.dart';
import '../theme/app_theme.dart';
import '../theme/spacing.dart';
import '../theme/sizes.dart';
import '../theme/typography.dart';
import 'teacher_mode_interactive_screen.dart';

class TeacherModeScreen extends ConsumerStatefulWidget {
  const TeacherModeScreen({super.key});

  @override
  ConsumerState<TeacherModeScreen> createState() => _TeacherModeScreenState();
}

class _TeacherModeScreenState extends ConsumerState<TeacherModeScreen> {
  TeacherModeDifficulty _selectedDifficulty = TeacherModeDifficulty.easy;
  String? _selectedPhrase;

  final List<_PhraseItem> _availablePhrases = [
    _PhraseItem('What is your name?', 'あなたの名前は何ですか？'),
    _PhraseItem('Nice to meet you', 'よろしくお願いします'),
    _PhraseItem('How are you?', 'お元気ですか？'),
    _PhraseItem('My name is...', '私の名前は...です'),
    _PhraseItem('Thank you', 'ありがとうございます'),
    _PhraseItem('Please help me', 'どうか手伝ってください'),
  ];

  void _navigateToSession() {
    if (_selectedPhrase == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('フレーズを選んでください')),
      );
      return;
    }

    final phrase = _availablePhrases.firstWhere((p) => p.english == _selectedPhrase);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TeacherModeInteractiveScreen(
          phrase: phrase.english,
          phraseMeaning: phrase.japanese,
          difficulty: _selectedDifficulty,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(teacherModeStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🧑‍🏫 先生ごっこ'),
        backgroundColor: kPrimaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.allPaddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 説明セクション
            _buildDescriptionCard(),
            AppSpacing.verticalSpacerLg,

            // 統計セクション
            _buildStatsSection(stats),
            AppSpacing.verticalSpacerLg,

            // 難易度選択
            _buildDifficultySelector(),
            AppSpacing.verticalSpacerLg,

            // フレーズ選択
            _buildPhraseSelector(),
            AppSpacing.verticalSpacerLg,

            // 開始ボタン
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _navigateToSession,
                icon: const Icon(Icons.play_arrow),
                label: const Text(
                  'セッションを開始',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccentGreen,
                ),
              ),
            ),
            AppSpacing.verticalSpacerXxl,
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        color: kPrimaryColor.withAlpha(10),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: kPrimaryColor.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('先生になりきって学ぶ', style: AppTypography.labelLarge),
          AppSpacing.verticalSpacerSm,
          Text(
            'あなたが先生役になって、AIの先生が間違えた言い方を直してあげます。教えることで、より深く学べます！',
            style: AppTypography.bodySmall.copyWith(color: kTextMuted),
            maxLines: 4,
          ),
          AppSpacing.verticalSpacerMd,
          Container(
            padding: AppSpacing.allPaddingSm,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: kAccentOrange, size: 20),
                AppSpacing.horizontalSpacerSm,
                Expanded(
                  child: Text(
                    'ラーニングピラミッド：人に教えるのは定着率90%!',
                    style: AppTypography.bodySmall.copyWith(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(TeacherModeStats stats) {
    return Container(
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        color: kAccentGreen.withAlpha(10),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: kAccentGreen.withAlpha(50)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard('セッション数', '${stats.totalSessions}'),
          Container(width: 1, height: 40, color: kAccentGreen.withAlpha(30)),
          _buildStatCard('正解数', '${stats.totalCorrections}'),
          Container(width: 1, height: 40, color: kAccentGreen.withAlpha(30)),
          _buildStatCard('平均精度', '${stats.averageAccuracy.toStringAsFixed(0)}%'),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTypography.headlineSmall.copyWith(color: kAccentGreen)),
        AppSpacing.verticalSpacerXs,
        Text(label, style: AppTypography.bodySmall.copyWith(color: kTextMuted, fontSize: 11)),
      ],
    );
  }

  Widget _buildDifficultySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('難易度を選ぶ', style: AppTypography.labelLarge),
        AppSpacing.verticalSpacerMd,
        Row(
          children: [
            _buildDifficultyChip(
              TeacherModeDifficulty.easy,
              '初級 🌱',
              'AIが発音ミスをします',
            ),
            AppSpacing.horizontalSpacerMd,
            _buildDifficultyChip(
              TeacherModeDifficulty.medium,
              '中級 📚',
              'AIが文法ミスをします',
            ),
            AppSpacing.horizontalSpacerMd,
            _buildDifficultyChip(
              TeacherModeDifficulty.hard,
              '上級 🎓',
              'AIが意味ミスをします',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDifficultyChip(
    TeacherModeDifficulty difficulty,
    String label,
    String description,
  ) {
    final isSelected = _selectedDifficulty == difficulty;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDifficulty = difficulty),
        child: Container(
          padding: AppSpacing.allPaddingMd,
          decoration: BoxDecoration(
            color: isSelected ? kPrimaryColor.withAlpha(20) : Colors.grey[100],
            border: Border.all(
              color: isSelected ? kPrimaryColor : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: AppTypography.labelLarge.copyWith(
                  color: isSelected ? kPrimaryColor : kTextMuted,
                ),
              ),
              AppSpacing.verticalSpacerXs,
              Text(
                description,
                style: AppTypography.bodySmall.copyWith(
                  fontSize: 10,
                  color: kTextMuted,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhraseSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('フレーズを選ぶ', style: AppTypography.labelLarge),
        AppSpacing.verticalSpacerMd,
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _availablePhrases.length,
          itemBuilder: (context, index) {
            final phrase = _availablePhrases[index];
            final isSelected = _selectedPhrase == phrase.english;

            return GestureDetector(
              onTap: () => setState(() => _selectedPhrase = phrase.english),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? kPrimaryColor.withAlpha(20) : Colors.white,
                  border: Border.all(
                    color: isSelected ? kPrimaryColor : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      phrase.english,
                      style: AppTypography.labelLarge.copyWith(
                        color: isSelected ? kPrimaryColor : Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.verticalSpacerXs,
                    Text(
                      phrase.japanese,
                      style: AppTypography.bodySmall.copyWith(
                        color: kTextMuted,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _PhraseItem {
  final String english;
  final String japanese;

  _PhraseItem(this.english, this.japanese);
}
