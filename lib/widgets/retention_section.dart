import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart'
    show ReviewTodayCard, onboardingProvider, weeklyChallengeProvider;

import '../design_system/design_system.dart';

/// ホーム画面に出す定着率施策（初回7日間の報酬・今日の復習・週次チャレンジ）。
/// 出すものがなければ何も表示しない。
class RetentionSection extends ConsumerWidget {
  const RetentionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingProvider);
    final weekly = ref.watch(weeklyChallengeProvider);
    final claimable = onboarding.claimable;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Column(
        children: [
          if (claimable.isNotEmpty) ...[
            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        '🎁 はじめての7日間ごほうび（${onboarding.claimedDays.length}/7）',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    for (final r in claimable)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text('${r.day}日目: ${r.title}'),
                        subtitle: Text(r.description),
                        trailing: FilledButton(
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            final got = await ref
                                .read(onboardingProvider.notifier)
                                .claim(r.day);
                            if (got != null) {
                              messenger.showSnackBar(SnackBar(
                                  content:
                                      Text('🪙 ${got.coins} コインをもらったよ！')));
                            }
                          },
                          child: Text('🪙 ${r.coins}'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          // 復習の遷移先は既存の弱点復習（テスト対策）画面
          ReviewTodayCard(
            color: AppColors.primary,
            onStart: () => Navigator.of(context).pushNamed('/test-prep'),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weekly.isComplete
                        ? '🎉 今週のチャレンジ達成！'
                        : '🎯 今週のチャレンジ：あと${weekly.remaining}問正解',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                      value: weekly.progress, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
