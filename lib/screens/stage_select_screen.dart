import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/stage_data.dart';
import '../models/stage.dart';
import '../providers/progress_provider.dart';
import '../theme/app_theme.dart';

class StageSelectScreen extends ConsumerWidget {
  const StageSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🇬🇧 ステージ選択'),
        backgroundColor: kPrimaryColor,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allStages.length,
        itemBuilder: (context, index) {
          final stage = allStages[index];
          final isCleared = progress.isCleared(stage.id);
          final isLocked = index > 0 && !progress.isCleared(allStages[index - 1].id);
          final bestScore = progress.stageBestScores[stage.id];
          final speakingAvg = progress.stageSpeakingAvg[stage.id];

          return _StageCard(
            stage: stage,
            isCleared: isCleared,
            isLocked: isLocked,
            bestScore: bestScore,
            speakingAvg: speakingAvg,
            onTap: isLocked ? null : () => Navigator.of(context).pushNamed('/stage-intro', arguments: stage),
            onReview: isCleared ? () => Navigator.of(context).pushNamed('/word-review', arguments: stage) : null,
          );
        },
      ),
    );
  }
}

class _StageCard extends StatelessWidget {
  final Stage stage;
  final bool isCleared;
  final bool isLocked;
  final int? bestScore;
  final double? speakingAvg;
  final VoidCallback? onReview;
  final VoidCallback? onTap;

  const _StageCard({
    required this.stage,
    required this.isCleared,
    required this.isLocked,
    this.bestScore,
    this.speakingAvg,
    this.onTap,
    this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: isLocked ? 0 : 2,
        borderRadius: BorderRadius.circular(16),
        color: isLocked ? Colors.grey.shade200 : Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isLocked
                        ? Colors.grey.shade300
                        : isCleared
                            ? kAccentGreen.withAlpha(26)
                            : kPrimaryColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: isLocked
                        ? const Icon(Icons.lock, color: Colors.grey)
                        : Text(stage.emoji, style: const TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Stage ${stage.stageNumber}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isLocked ? Colors.grey : kPrimaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: kBgLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              stageCategoryLabel(stage.category),
                              style: const TextStyle(fontSize: 11, color: kTextMuted),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${stage.titleJa}（${stage.title}）',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isLocked ? Colors.grey : kTextDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _SkillPill('👂 ${stage.listeningCount}', kListeningColor),
                          const SizedBox(width: 4),
                          _SkillPill('🎤 ${stage.speakingCount}', kSpeakingColor),
                          if (speakingAvg != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              'Speaking: ${speakingAvg!.round()}点',
                              style: const TextStyle(fontSize: 11, color: kSpeakingColor),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (isCleared)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, color: kAccentGreen, size: 24),
                      if (onReview != null) ...[
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: onReview,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: kAccentGreen.withAlpha(26),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('復習', style: TextStyle(fontSize: 10, color: kAccentGreen, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ],
                  )
                else if (!isLocked && bestScore != null)
                  Column(
                    children: [
                      Text('$bestScore', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kAccentOrange)),
                      const Text('点', style: TextStyle(fontSize: 11, color: kTextMuted)),
                    ],
                  )
                else if (!isLocked)
                  const Icon(Icons.play_circle_filled, color: kPrimaryColor, size: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SkillPill extends StatelessWidget {
  final String text;
  final Color color;
  const _SkillPill(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
    );
  }
}
