import '../design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../models/user_profile.dart';
import '../providers/user_profile_provider.dart';

class ProfileManagementScreen extends ConsumerWidget {
  const ProfileManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('👤 プロフィール管理'),
          backgroundColor: AppColors.primary,
        ),
        body: const Center(
          child: Text('プロフィールが見つかりません'),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('👤 プロフィール管理'),
          backgroundColor: AppColors.primary,
          bottom: const TabBar(
            labelColor: AppColors.textWhite,
            unselectedLabelColor: AppColors.textWhite.withOpacity(0.7),
            indicatorColor: AppColors.accentOrange,
            tabs: [
              Tab(text: '統計情報'),
              Tab(text: 'プライバシー'),
              Tab(text: 'データ'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 統計情報
            _StatisticsTab(profile: currentUser),
            // プライバシー設定
            _PrivacyTab(profile: currentUser),
            // データ管理
            _DataManagementTab(profile: currentUser),
          ],
        ),
      ),
    );
  }
}

class _StatisticsTab extends ConsumerWidget {
  final UserProfile profile;

  const _StatisticsTab({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: AppSpacing.allPaddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // プロフィールヘッダー
          Container(
            padding: AppSpacing.allPaddingLg,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary.withAlpha(20), AppColors.primary.withAlpha(5)],
              ),
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
            ),
            child: Row(
              children: [
                Text(profile.avatar, style: const TextStyle(fontSize: 64)),
                AppSpacing.horizontalSpacerMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile.name, style: AppTypography.headlineMedium),
                      AppSpacing.verticalSpacerXs,
                      Text(
                        '${profile.grade}年生 | 作成日: ${profile.createdAt.year}年${profile.createdAt.month}月${profile.createdAt.day}日',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.verticalSpacerLg,

          // 主要統計
          Text('学習統計', style: AppTypography.headlineSmall),
          AppSpacing.verticalSpacerMd,
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _StatCard(
                label: '総勉強時間',
                value: '${profile.totalStudyMinutes}分',
                icon: '⏱️',
                color: AppColors.primary,
              ),
              _StatCard(
                label: '獲得コイン',
                value: '${profile.coinsEarned}🪙',
                icon: '💰',
                color: AppColors.accentOrange,
              ),
              _StatCard(
                label: '最長連続',
                value: '${profile.longestStreak}日',
                icon: '🔥',
                color: AppColors.error,
              ),
              _StatCard(
                label: 'クリア数',
                value: '${profile.stageProgress.length}',
                icon: '✅',
                color: AppColors.accentGreen,
              ),
            ],
          ),
          AppSpacing.verticalSpacerLg,

          // 達成度
          Text('達成度', style: AppTypography.headlineSmall),
          AppSpacing.verticalSpacerMd,
          Container(
            padding: AppSpacing.allPaddingMd,
            decoration: BoxDecoration(
              color: AppColors.bgLight,
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('バッジ獲得', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
                    Text('${profile.unlockedBadges.length}個', style: AppTypography.labelLarge),
                  ],
                ),
                AppSpacing.verticalSpacerMd,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ミッション完了', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
                    Text('${profile.completedMissions.length}個', style: AppTypography.labelLarge),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.verticalSpacerXxl,
        ],
      ),
    );
  }
}

class _PrivacyTab extends ConsumerStatefulWidget {
  final UserProfile profile;

  const _PrivacyTab({required this.profile});

  @override
  ConsumerState<_PrivacyTab> createState() => _PrivacyTabState();
}

class _PrivacyTabState extends ConsumerState<_PrivacyTab> {
  late bool showNameInRanking;

  @override
  void initState() {
    super.initState();
    showNameInRanking = widget.profile.showNameInRanking;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.allPaddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('プライバシー設定', style: AppTypography.headlineSmall),
          AppSpacing.verticalSpacerLg,

          // ランキング表示設定
          Container(
            padding: AppSpacing.allPaddingMd,
            decoration: BoxDecoration(
              color: showNameInRanking ? AppColors.accentGreen.withAlpha(20) : Colors.grey[50],
              border: Border.all(
                color: showNameInRanking ? AppColors.accentGreen :AppColors.bgLight,
              ),
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ランキングに名前を表示', style: AppTypography.labelLarge),
                      AppSpacing.verticalSpacerXs,
                      Text(
                        showNameInRanking
                            ? '他のユーザーはあなたの名前と成績が見えます'
                            : '他のユーザーにはあなたの名前は見えません',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: showNameInRanking,
                  onChanged: (value) async {
                    setState(() => showNameInRanking = value);
                    final updatedProfile = widget.profile.copyWith(
                      showNameInRanking: value,
                    );
                    await ref
                        .read(userProfilesProvider.notifier)
                        .updateProfile(updatedProfile);
                  },
                  activeColor: AppColors.accentGreen,
                ),
              ],
            ),
          ),
          AppSpacing.verticalSpacerLg,

          // その他の設定
          Text('その他のプライバシー設定', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
          AppSpacing.verticalSpacerMd,

          Container(
            padding: AppSpacing.allPaddingMd,
            decoration: BoxDecoration(
              color: AppColors.bgLight,
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PrivacyItem(
                  title: '個人情報',
                  description: 'プロフィール情報は暗号化して保存されます',
                ),
                AppSpacing.verticalSpacerMd,
                _PrivacyItem(
                  title: 'データ使用',
                  description: 'あなたのデータは学習改善にのみ使用されます',
                ),
                AppSpacing.verticalSpacerMd,
                _PrivacyItem(
                  title: 'クッキー',
                  description: '必須機能のみクッキーが使用されます',
                ),
              ],
            ),
          ),
          AppSpacing.verticalSpacerXxl,
        ],
      ),
    );
  }
}

class _DataManagementTab extends ConsumerWidget {
  final UserProfile profile;

  const _DataManagementTab({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: AppSpacing.allPaddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('データ管理', style: AppTypography.headlineSmall),
          AppSpacing.verticalSpacerLg,

          // バックアップ情報
          Container(
            padding: AppSpacing.allPaddingMd,
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withAlpha(20),
              border: Border.all(color: AppColors.accentGreen.withAlpha(50)),
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.cloud_done, color: AppColors.accentGreen, size: 24),
                    AppSpacing.horizontalSpacerMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('自動バックアップ', style: AppTypography.labelLarge),
                          AppSpacing.verticalSpacerXs,
                          Text(
                            '最後の更新: ${profile.lastAccessedAt.year}年${profile.lastAccessedAt.month}月${profile.lastAccessedAt.day}日',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.verticalSpacerLg,

          // データエクスポート
          Text('データエクスポート', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
          AppSpacing.verticalSpacerMd,
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _exportData(context, profile),
              icon: const Icon(Icons.download),
              label: const Text('プロフィールデータをエクスポート'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                ),
              ),
            ),
          ),
          AppSpacing.verticalSpacerSm,
          Text(
            'あなたのプロフィール、成績、統計情報をJSON形式でダウンロードできます',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
          ),
          AppSpacing.verticalSpacerLg,

          // データインポート
          Text('データインポート', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
          AppSpacing.verticalSpacerMd,
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _importData(context),
              icon: const Icon(Icons.upload),
              label: const Text('データをインポート'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                ),
              ),
            ),
          ),
          AppSpacing.verticalSpacerSm,
          Text(
            '以前エクスポートしたデータをインポートできます',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
          ),
          AppSpacing.verticalSpacerXxl,
        ],
      ),
    );
  }

  void _exportData(BuildContext context, UserProfile profile) {
    final jsonData = jsonEncode(profile.toJson());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('データをコピーしました'),
        backgroundColor: AppColors.accentGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _importData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('インポート機能は準備中です'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
              AppSpacing.verticalSpacerXs,
              Text(value, style: AppTypography.headlineSmall.copyWith(color: color)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrivacyItem extends StatelessWidget {
  final String title;
  final String description;

  const _PrivacyItem({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.labelSmall),
        AppSpacing.verticalSpacerXs,
        Text(
          description,
          style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}
