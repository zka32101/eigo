import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../data/stage_intro_data.dart';
import '../models/stage.dart';
import '../theme/app_theme.dart';
import '../theme/spacing.dart';
import '../theme/sizes.dart';
import '../theme/typography.dart';

class StageIntroScreen extends StatefulWidget {
  final Stage stage;
  const StageIntroScreen({super.key, required this.stage});

  @override
  State<StageIntroScreen> createState() => _StageIntroScreenState();
}

class _StageIntroScreenState extends State<StageIntroScreen> {
  final _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('en-US');
    _tts.setSpeechRate(0.6);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  void _startLesson() {
    Navigator.of(context).pushReplacementNamed('/lesson', arguments: widget.stage);
  }

  @override
  Widget build(BuildContext context) {
    final intro = stageIntroData[widget.stage.id];

    return Scaffold(
      backgroundColor: kBgLight,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text('${widget.stage.emoji} ${widget.stage.titleJa}'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.allPaddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ヘッダーカード
            _HeaderCard(stage: widget.stage, intro: intro),
            AppSpacing.verticalSpacerMd,

            if (intro != null) ...[
              // キー単語
              _VocabSection(intro: intro, tts: _tts),
              AppSpacing.verticalSpacerMd,

              // 文法・使い方ティップス
              _TipCard(intro: intro),
              AppSpacing.verticalSpacerMd,

              // 例文
              _ExampleCard(intro: intro, tts: _tts),
              AppSpacing.verticalSpacerMd,
            ] else ...[
              // データなしの場合は問題タイプ説明
              _QuestionTypeInfo(stage: widget.stage),
              AppSpacing.verticalSpacerMd,
            ],

            // 問題構成
            _ContentBreakdownCard(stage: widget.stage),
            AppSpacing.verticalSpacerXxl,

            // スタートボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow, size: 28),
                label: const Text(
                  'レッスンスタート！',
                  style: AppTypography.headlineSmall,
                ),
                onPressed: _startLesson,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  backgroundColor: kAccentGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
                  ),
                ),
              ),
            ),
            AppSpacing.verticalSpacerXxl,
          ],
        ),
      ),
    );
  }
}

// ─── Header Card ────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  final Stage stage;
  final StageIntro? intro;
  const _HeaderCard({required this.stage, required this.intro});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
          gradient: const LinearGradient(
            colors: [kPrimaryColor, Color(0xFF5B9BD5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Text(stage.emoji, style: AppTypography.headlineLarge),
            AppSpacing.verticalSpacerXs,
            Text(
              stage.titleJa,
              style: AppTypography.headlineMedium.copyWith(
                color: Colors.white,
              ),
            ),
            Text(
              stage.title,
              style: AppTypography.bodySmall.copyWith(color: Colors.white.withAlpha(200)),
            ),
            if (intro != null) ...[
              AppSpacing.verticalSpacerSm,
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge * 2),
                ),
                child: Text(
                  intro!.overviewJa,
                  style: AppTypography.bodySmall.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Vocab Section ───────────────────────────────────────────────

class _VocabSection extends StatelessWidget {
  final StageIntro intro;
  final FlutterTts tts;
  const _VocabSection({required this.intro, required this.tts});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.xs),
          child: Text(
            '📝 キーワード',
            style: AppTypography.labelLarge.copyWith(color: kTextDark),
          ),
        ),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.1,
          children: intro.highlights.map((v) => _VocabChip(vocab: v, tts: tts)).toList(),
        ),
      ],
    );
  }
}

class _VocabChip extends StatelessWidget {
  final VocabHighlight vocab;
  final FlutterTts tts;
  const _VocabChip({required this.vocab, required this.tts});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => tts.speak(vocab.english),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: AppSpacing.allPaddingSm,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(vocab.emoji, style: AppTypography.headlineSmall),
              AppSpacing.verticalSpacerXs,
              Text(
                vocab.english,
                style: AppTypography.labelLarge.copyWith(
                  color: kPrimaryColor,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                vocab.japanese,
                style: AppTypography.bodySmall.copyWith(color: kTextMuted),
                textAlign: TextAlign.center,
              ),
              if (vocab.phonetic.isNotEmpty)
                Text(
                  vocab.phonetic,
                  style: AppTypography.bodySmall.copyWith(fontSize: 9, color: kTextMuted),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Tip Card ───────────────────────────────────────────────────

class _TipCard extends StatelessWidget {
  final StageIntro intro;
  const _TipCard({required this.intro});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFF8E1),
      child: Padding(
        padding: AppSpacing.allPaddingLg,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('💡', style: AppTypography.headlineSmall.copyWith(fontSize: 28)),
            AppSpacing.horizontalSpacerSm,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ポイント！',
                    style: AppTypography.labelLarge.copyWith(
                      color: kAccentOrange,
                    ),
                  ),
                  AppSpacing.verticalSpacerXs,
                  Text(
                    intro.tipJa,
                    style: AppTypography.bodySmall.copyWith(color: kTextDark, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Example Card ────────────────────────────────────────────────

class _ExampleCard extends StatelessWidget {
  final StageIntro intro;
  final FlutterTts tts;
  const _ExampleCard({required this.intro, required this.tts});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: kPrimaryColor.withAlpha(13),
      child: Padding(
        padding: AppSpacing.allPaddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🗣️ 例文',
              style: AppTypography.labelLarge.copyWith(color: kTextDark),
            ),
            AppSpacing.verticalSpacerSm,
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        intro.exampleEn,
                        style: AppTypography.headlineSmall.copyWith(
                          color: kPrimaryColor,
                        ),
                      ),
                      AppSpacing.verticalSpacerXs,
                      Text(
                        intro.exampleJa,
                        style: AppTypography.bodySmall.copyWith(color: kTextMuted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up, color: kPrimaryColor),
                  onPressed: () => tts.speak(intro.exampleEn),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Content Breakdown Card ──────────────────────────────────────

class _ContentBreakdownCard extends StatelessWidget {
  final Stage stage;
  const _ContentBreakdownCard({required this.stage});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.allPaddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 このレッスンの内容',
              style: AppTypography.labelLarge,
            ),
            AppSpacing.verticalSpacerSm,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (stage.listeningCount > 0)
                  _TypeCount('👂', 'リスニング', stage.listeningCount, kListeningColor),
                if (stage.speakingCount > 0)
                  _TypeCount('🎤', 'スピーキング', stage.speakingCount, kSpeakingColor),
                if (stage.readingCount > 0)
                  _TypeCount('📖', 'リーディング', stage.readingCount, kReadingColor),
                if (stage.writingCount > 0)
                  _TypeCount('✏️', 'ライティング', stage.writingCount, kWritingColor),
              ],
            ),
            AppSpacing.verticalSpacerSm,
            Text(
              '合計 ${stage.questions.length} 問',
              style: AppTypography.bodySmall.copyWith(
                color: kTextMuted,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeCount extends StatelessWidget {
  final String emoji;
  final String label;
  final int count;
  final Color color;
  const _TypeCount(this.emoji, this.label, this.count, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: AppTypography.headlineSmall.copyWith(fontSize: 22)),
        AppSpacing.verticalSpacerXs,
        Text(
          '$count問',
          style: AppTypography.labelLarge.copyWith(color: color),
        ),
        Text(label, style: AppTypography.bodySmall.copyWith(fontSize: 10, color: kTextMuted)),
      ],
    );
  }
}

// ─── Question Type Info (no intro data) ─────────────────────────

class _QuestionTypeInfo extends StatelessWidget {
  final Stage stage;
  const _QuestionTypeInfo({required this.stage});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFF0F4FF),
      child: Padding(
        padding: AppSpacing.allPaddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🎯 学習内容',
              style: AppTypography.labelLarge,
            ),
            AppSpacing.verticalSpacerXs,
            _InfoRow('👂 リスニング', '英語を聞いて正解を選ぼう'),
            _InfoRow('🎤 スピーキング', '英語を声に出して発音しよう'),
            _InfoRow('📖 リーディング', '英文を読んで意味を理解しよう'),
            _InfoRow('✏️ ライティング', '日本語から英語を選ぼう'),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String type;
  final String desc;
  const _InfoRow(this.type, this.desc);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(type, style: AppTypography.labelMedium)),
          Expanded(child: Text(desc, style: AppTypography.labelMedium.copyWith(color: kTextMuted))),
        ],
      ),
    );
  }
}
