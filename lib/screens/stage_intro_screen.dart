import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../data/stage_intro_data.dart';
import '../models/stage.dart';
import '../theme/app_theme.dart';

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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ヘッダーカード
            _HeaderCard(stage: widget.stage, intro: intro),
            const SizedBox(height: 16),

            if (intro != null) ...[
              // キー単語
              _VocabSection(intro: intro, tts: _tts),
              const SizedBox(height: 16),

              // 文法・使い方ティップス
              _TipCard(intro: intro),
              const SizedBox(height: 16),

              // 例文
              _ExampleCard(intro: intro, tts: _tts),
              const SizedBox(height: 16),
            ] else ...[
              // データなしの場合は問題タイプ説明
              _QuestionTypeInfo(stage: widget.stage),
              const SizedBox(height: 16),
            ],

            // 問題構成
            _ContentBreakdownCard(stage: widget.stage),
            const SizedBox(height: 24),

            // スタートボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow, size: 28),
                label: const Text(
                  'レッスンスタート！',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onPressed: _startLesson,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: kAccentGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
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
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [kPrimaryColor, Color(0xFF5B9BD5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(stage.emoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 8),
            Text(
              stage.titleJa,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              stage.title,
              style: TextStyle(fontSize: 14, color: Colors.white.withAlpha(200)),
            ),
            if (intro != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  intro!.overviewJa,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
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
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            '📝 キーワード',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kTextDark),
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
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(vocab.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              Text(
                vocab.english,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                vocab.japanese,
                style: const TextStyle(fontSize: 11, color: kTextMuted),
                textAlign: TextAlign.center,
              ),
              if (vocab.phonetic.isNotEmpty)
                Text(
                  vocab.phonetic,
                  style: const TextStyle(fontSize: 9, color: kTextMuted),
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
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('💡', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ポイント！',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: kAccentOrange,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    intro.tipJa,
                    style: const TextStyle(fontSize: 13, color: kTextDark, height: 1.5),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🗣️ 例文',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kTextDark),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        intro.exampleEn,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        intro.exampleJa,
                        style: const TextStyle(fontSize: 13, color: kTextMuted),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 このレッスンの内容',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 12),
            Text(
              '合計 ${stage.questions.length} 問',
              style: const TextStyle(
                fontSize: 13,
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
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(
          '$count問',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
        Text(label, style: const TextStyle(fontSize: 10, color: kTextMuted)),
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
    return const Card(
      color: Color(0xFFF0F4FF),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎯 学習内容',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(type, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          Expanded(child: Text(desc, style: const TextStyle(fontSize: 12, color: kTextMuted))),
        ],
      ),
    );
  }
}
