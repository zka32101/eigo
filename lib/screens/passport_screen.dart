import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/passport_model.dart';
import '../providers/passport_provider.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_theme.dart';
import '../theme/spacing.dart';
import '../theme/sizes.dart';
import '../theme/typography.dart';

class PassportScreen extends ConsumerStatefulWidget {
  const PassportScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PassportScreen> createState() => _PassportScreenState();
}

class _PassportScreenState extends ConsumerState<PassportScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(passportProfileProvider);
    final summaryAsync = ref.watch(passportSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🌍 しょうがくコレ！パスポート'),
        elevation: 0,
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return const Center(
              child: Text('プロフィールの読み込みに失敗しました'),
            );
          }

          return Column(
            children: [
              // タブバー
              Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _TabButton(
                        label: 'サマリー',
                        isSelected: _selectedTab == 0,
                        onTap: () => setState(() => _selectedTab = 0),
                      ),
                      _TabButton(
                        label: '教科別',
                        isSelected: _selectedTab == 1,
                        onTap: () => setState(() => _selectedTab = 1),
                      ),
                      _TabButton(
                        label: 'バッジ',
                        isSelected: _selectedTab == 2,
                        onTap: () => setState(() => _selectedTab = 2),
                      ),
                      _TabButton(
                        label: 'チャレンジ',
                        isSelected: _selectedTab == 3,
                        onTap: () => setState(() => _selectedTab = 3),
                      ),
                      _TabButton(
                        label: '設定',
                        isSelected: _selectedTab == 4,
                        onTap: () => setState(() => _selectedTab = 4),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: _buildTabContent(
                  _selectedTab,
                  profile,
                  summaryAsync,
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラー: $err')),
      ),
    );
  }

  Widget _buildTabContent(
    int tab,
    PassportProfile profile,
    AsyncValue<PassportSummary?> summaryAsync,
  ) {
    switch (tab) {
      case 0:
        return _SummaryTab(profile: profile, summaryAsync: summaryAsync);
      case 1:
        return _SubjectsTab(profile: profile);
      case 2:
        return _BadgesTab();
      case 3:
        return _ChallengesTab();
      case 4:
        return _SettingsTab(profile: profile);
      default:
        return const SizedBox();
    }
  }
}

/// タブボタン
class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? kPrimaryColor : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? kPrimaryColor : kTextMuted,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// Tab 0: サマリータブ
class _SummaryTab extends StatelessWidget {
  final PassportProfile profile;
  final AsyncValue<PassportSummary?> summaryAsync;

  const _SummaryTab({
    required this.profile,
    required this.summaryAsync,
  });

  @override
  Widget build(BuildContext context) {
    return summaryAsync.when(
      data: (summary) {
        if (summary == null) {
          return const Center(child: Text('データ読み込み中...'));
        }

        return ListView(
          padding: AppSpacing.allPaddingMd,
          children: [
            // ユーザープロフィール
            _ProfileCard(profile: profile),
            AppSpacing.verticalSpacerLg,

            // グローバルランキング
            _RankingCard(summary: summary),
            AppSpacing.verticalSpacerLg,

            // 総合XP進捗
            _XPProgressCard(summary: summary),
            AppSpacing.verticalSpacerLg,

            // 教科別XP
            _SubjectXPCard(summary: summary),
            AppSpacing.verticalSpacerLg,

            // 学習統計
            _StudyStatsCard(summary: summary),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('エラー: $err')),
    );
  }
}

/// プロフィールカード
class _ProfileCard extends StatelessWidget {
  final PassportProfile profile;

  const _ProfileCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.blue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
        border: Border.all(color: Colors.purple.shade200),
      ),
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                )
              ],
            ),
            child: const Center(
              child: Text('🌍', style: TextStyle(fontSize: 60)),
            ),
          ),
          AppSpacing.verticalSpacerMd,
          Text(
            profile.userName,
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.verticalSpacerXs,
          Text(
            '小学${profile.overallGrade}年生',
            style: AppTypography.bodySmall.copyWith(color: kTextMuted),
          ),
          AppSpacing.verticalSpacerMd,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    '${profile.connectedApps.values.where((v) => v).length}',
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  Text(
                    'アプリ接続',
                    style: AppTypography.bodySmall.copyWith(color: kTextMuted),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    '${profile.overallGrade}',
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    'グレード',
                    style: AppTypography.bodySmall.copyWith(color: kTextMuted),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ランキングカード
class _RankingCard extends StatelessWidget {
  final PassportSummary summary;

  const _RankingCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: Colors.orange.shade200),
      ),
      padding: AppSpacing.allPaddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🏆 ランキング',
            style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          AppSpacing.verticalSpacerMd,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    '全国順位',
                    style: AppTypography.bodySmall.copyWith(color: kTextMuted),
                  ),
                  AppSpacing.verticalSpacerXs,
                  Text(
                    '${summary.globalRank}位',
                    style: AppTypography.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: kAccentOrange,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    '友達内順位',
                    style: AppTypography.bodySmall.copyWith(color: kTextMuted),
                  ),
                  AppSpacing.verticalSpacerXs,
                  Text(
                    '${summary.friendsRank}位',
                    style: AppTypography.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// XP進捗カード
class _XPProgressCard extends StatelessWidget {
  final PassportSummary summary;

  const _XPProgressCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final maxXP = 5000;
    final progress = (summary.totalXP / maxXP).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: Colors.blue.shade200),
      ),
      padding: AppSpacing.allPaddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '総合XP',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${summary.totalXP} / $maxXP',
                style: AppTypography.labelMedium.copyWith(
                  color: kAccentBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpacerMd,
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(kAccentBlue),
            ),
          ),
          AppSpacing.verticalSpacerSm,
          Text(
            '${(progress * 100).toStringAsFixed(0)}% 達成',
            style: AppTypography.bodySmall.copyWith(color: kTextMuted),
          ),
        ],
      ),
    );
  }
}

/// 教科別XPカード
class _SubjectXPCard extends StatelessWidget {
  final PassportSummary summary;

  const _SubjectXPCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: Colors.green.shade200),
      ),
      padding: AppSpacing.allPaddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '教科別XP',
            style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          AppSpacing.verticalSpacerMd,
          ...summary.xpByApp.entries.map((e) {
            final appName = e.key == 'eigo-kore'
                ? '📚 英語コレ！'
                : e.key == 'kokugo-kore'
                    ? '📖 国語コレ！'
                    : '🧮 算数コレ！';

            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(appName, style: AppTypography.bodySmall),
                      Text(
                        '${e.value} XP',
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: kAccentGreen,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.verticalSpacerXs,
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppSizes.borderRadiusSmall),
                    child: LinearProgressIndicator(
                      value: (e.value / 2000).clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: Colors.grey[200],
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(kAccentGreen),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

/// 学習統計カード
class _StudyStatsCard extends StatelessWidget {
  final PassportSummary summary;

  const _StudyStatsCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: Colors.pink.shade200),
      ),
      padding: AppSpacing.allPaddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 学習統計',
            style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          AppSpacing.verticalSpacerMd,
          _StatRow(
            label: 'アンロック済みバッジ',
            value: '${summary.totalBadgesUnlocked}個',
          ),
          _StatRow(
            label: '完成度',
            value: '${summary.completionPercentage}%',
          ),
          _StatRow(
            label: '総学習時間',
            value: '${summary.totalStudyMinutes ~/ 60}時間${summary.totalStudyMinutes % 60}分',
          ),
          _StatRow(
            label: '前月比成長',
            value: '+${summary.monthlyXPGrowth} XP',
          ),
        ],
      ),
    );
  }
}

/// 統計行
class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodySmall),
          Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: kAccentOrange,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab 1: 教科別タブ
class _SubjectsTab extends ConsumerWidget {
  final PassportProfile profile;

  const _SubjectsTab({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apps = [
      ('eigo-kore', '📚 英語コレ！', Colors.blue),
      ('kokugo-kore', '📖 国語コレ！', Colors.red),
      ('sansu-kore', '🧮 算数コレ！', Colors.green),
    ];

    return ListView(
      padding: AppSpacing.allPaddingMd,
      children: apps.map((app) {
        final (appId, displayName, color) = app;
        final isConnected = profile.connectedApps[appId] ?? false;
        final statsAsync = ref.watch(appStatisticsProvider(appId));

        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.lg),
          child: statsAsync.when(
            data: (stats) {
              if (stats == null) {
                return const SizedBox();
              }

              return Container(
                decoration: BoxDecoration(
                  color: (color as Color).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  border: Border.all(color: (color as Color).withOpacity(0.3)),
                ),
                padding: AppSpacing.allPaddingMd,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          displayName,
                          style: AppTypography.labelLarge
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: isConnected ? Colors.green : Colors.grey,
                            borderRadius: BorderRadius.circular(
                              AppSizes.borderRadiusSmall,
                            ),
                          ),
                          child: Text(
                            isConnected ? '接続中' : '未接続',
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.verticalSpacerMd,
                    _AppStatItem(
                      label: 'レベル',
                      value: 'Lv ${stats.totalLevel}',
                      color: color as Color,
                    ),
                    AppSpacing.verticalSpacerSm,
                    _AppStatItem(
                      label: '総XP',
                      value: '${stats.totalXP}',
                      color: color as Color,
                    ),
                    AppSpacing.verticalSpacerSm,
                    _AppStatItem(
                      label: 'バッジ',
                      value: '${stats.totalBadges}個',
                      color: color as Color,
                    ),
                    AppSpacing.verticalSpacerSm,
                    _AppStatItem(
                      label: 'スコア',
                      value: '${stats.normalizedScore}/100',
                      color: color as Color,
                    ),
                  ],
                ),
              );
            },
            loading: () => Container(
              padding: AppSpacing.allPaddingMd,
              child: const CircularProgressIndicator(),
            ),
            error: (err, stack) => const SizedBox(),
          ),
        );
      }).toList(),
    );
  }
}

/// アプリ統計アイテム
class _AppStatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _AppStatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySmall),
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Tab 2: バッジタブ
class _BadgesTab extends ConsumerWidget {
  const _BadgesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgesAsync = ref.watch(globalBadgesProvider);
    final achievementsAsync = ref.watch(userBadgeAchievementsProvider);

    return achievementsAsync.when(
      data: (achievements) {
        final unlockedIds = achievements.map((a) => a.badgeId).toSet();

        return ListView(
          padding: AppSpacing.allPaddingMd,
          children: [
            Text(
              'グローバルバッジ',
              style:
                  AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            AppSpacing.verticalSpacerMd,
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: badgesAsync.value?.length ?? 0,
              itemBuilder: (context, index) {
                final badge = badgesAsync.value![index];
                final isUnlocked = unlockedIds.contains(badge.badgeId);

                return _BadgeCard(
                  badge: badge,
                  isUnlocked: isUnlocked,
                );
              },
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('エラー: $err')),
    );
  }
}

/// バッジカード
class _BadgeCard extends StatelessWidget {
  final GlobalBadge badge;
  final bool isUnlocked;

  const _BadgeCard({
    required this.badge,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isUnlocked ? Colors.yellow.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(
          color: isUnlocked ? Colors.yellow.shade300 : Colors.grey.shade300,
        ),
      ),
      padding: AppSpacing.allPaddingMd,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            badge.emoji,
            style: const TextStyle(fontSize: 40),
          ),
          AppSpacing.verticalSpacerSm,
          Text(
            badge.name,
            style: AppTypography.labelSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.verticalSpacerXs,
          if (!isUnlocked)
            Text(
              '${badge.requiredXP} XP',
              style: AppTypography.bodySmall.copyWith(
                color: kTextMuted,
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }
}

/// Tab 3: チャレンジタブ
class _ChallengesTab extends ConsumerWidget {
  const _ChallengesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengesAsync = ref.watch(crossAppChallengesProvider);

    return ListView(
      padding: AppSpacing.allPaddingMd,
      children: challengesAsync.map((challenge) {
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: _ChallengeCard(challenge: challenge),
        );
      }).toList(),
    );
  }
}

/// チャレンジカード
class _ChallengeCard extends StatelessWidget {
  final CrossAppChallenge challenge;

  const _ChallengeCard({required this.challenge});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysLeft =
        challenge.endDate.difference(now).inDays;
    final progress =
        (1 - (daysLeft / challenge.endDate.difference(challenge.startDate).inDays))
            .clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: Colors.purple.shade200),
      ),
      padding: AppSpacing.allPaddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            challenge.name,
            style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          AppSpacing.verticalSpacerXs,
          Text(
            challenge.description,
            style: AppTypography.bodySmall.copyWith(color: kTextMuted),
          ),
          AppSpacing.verticalSpacerMd,
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
            ),
          ),
          AppSpacing.verticalSpacerSm,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'あと $daysLeft 日',
                style: AppTypography.bodySmall.copyWith(
                  color: kTextMuted,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                ),
                child: Text(
                  '+${challenge.totalXPReward} XP',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tab 4: 設定タブ
class _SettingsTab extends ConsumerWidget {
  final PassportProfile profile;

  const _SettingsTab({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apps = [
      ('eigo-kore', '📚 英語コレ！'),
      ('kokugo-kore', '📖 国語コレ！'),
      ('sansu-kore', '🧮 算数コレ！'),
    ];

    return ListView(
      padding: AppSpacing.allPaddingMd,
      children: [
        Text(
          '📱 アプリ連携',
          style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        AppSpacing.verticalSpacerMd,
        ...apps.map((app) {
          final (appId, displayName) = app;
          final isConnected = profile.connectedApps[appId] ?? false;

          return Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                border: Border.all(color: Colors.grey.shade200),
              ),
              padding: AppSpacing.allPaddingMd,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    displayName,
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Switch(
                    value: isConnected,
                    onChanged: (value) {
                      if (value) {
                        ref
                            .read(passportProfileProvider.notifier)
                            .connectApp(appId);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        AppSpacing.verticalSpacerLg,
        Text(
          '📊 プライバシー設定',
          style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        AppSpacing.verticalSpacerMd,
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            border: Border.all(color: Colors.grey.shade200),
          ),
          padding: AppSpacing.allPaddingMd,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ランキングに表示する',
                style: AppTypography.bodySmall,
              ),
              Switch(
                value: true,
                onChanged: (value) {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}
