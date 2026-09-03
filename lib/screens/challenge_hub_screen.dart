import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/challenge_model.dart';
import '../providers/challenge_provider.dart';
import '../design_system/design_system.dart';
import '../widgets/challenge_card.dart';

class ChallengeHubScreen extends ConsumerStatefulWidget {
  const ChallengeHubScreen({super.key});

  @override
  ConsumerState<ChallengeHubScreen> createState() => _ChallengeHubScreenState();
}

class _ChallengeHubScreenState extends ConsumerState<ChallengeHubScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Get current user ID from provider
    const currentUserId = 'current-user-id';
    
    final activeChallenges = ref.watch(activeChallengesProvider);
    final searchQuery = ref.watch(challengeSearchQueryProvider);
    final typeFilter = ref.watch(challengeTypeFilterProvider);
    final searchResults = searchQuery.isEmpty
        ? activeChallenges
        : ref.watch(searchChallengesProvider(searchQuery));

    return Scaffold(
      appBar: AppBar(
        title: const Text('チャレンジハブ'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to create challenge screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('チャレンジ作成機能は近日公開予定です')),
              );
            },
            tooltip: 'チャレンジを作成',
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: TextField(
                controller: _searchController,
                onChanged: (query) {
                  ref.read(challengeSearchQueryProvider.notifier).state = query;
                },
                decoration: InputDecoration(
                  hintText: 'チャレンジを検索...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  ),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(challengeSearchQueryProvider.notifier).state = '';
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),
          // Filter chips
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'すべて',
                      isSelected: typeFilter == null,
                      onTap: () {
                        ref.read(challengeTypeFilterProvider.notifier).state = null;
                      },
                    ),
                    ...ChallengeType.values.map((type) {
                      return _FilterChip(
                        label: _getChallengeTypeLabel(type),
                        isSelected: typeFilter == type,
                        onTap: () {
                          ref.read(challengeTypeFilterProvider.notifier).state = type;
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
          AppSpacing.verticalSpacerMd,
          // Challenges list
          activeChallenges.when(
            loading: () => SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            error: (error, stack) => SliverToBoxAdapter(
              child: Center(
                child: Column(
                  children: [
                    Text('エラーが発生しました', style: AppTypography.labelLarge),
                    AppSpacing.verticalSpacerMd,
                    ElevatedButton(
                      onPressed: () => ref.refresh(activeChallengesProvider),
                      child: const Text('再試行'),
                    ),
                  ],
                ),
              ),
            ),
            data: (challenges) {
              if (challenges.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Column(
                      children: [
                        Text('🏆', style: TextStyle(fontSize: 64)),
                        AppSpacing.verticalSpacerMd,
                        Text('チャレンジがありません', style: AppTypography.labelLarge),
                      ],
                    ),
                  ),
                );
              }

              final filtered = typeFilter == null
                  ? challenges
                  : challenges.where((c) => c.type == typeFilter).toList();

              if (filtered.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: Text('このタイプのチャレンジはありません', style: AppTypography.labelMedium),
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final challenge = filtered[index];
                    return ChallengeCard(
                      challenge: challenge,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/challenge-detail',
                          arguments: {
                            'challenge': challenge,
                            'userId': currentUserId,
                          },
                        );
                      },
                      onJoin: () {
                        _showJoinConfirmation(context, challenge, currentUserId);
                      },
                    );
                  },
                  childCount: filtered.length,
                ),
              );
            },
          ),
          SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
        ],
      ),
    );
  }

  void _showJoinConfirmation(
    BuildContext context,
    SocialChallenge challenge,
    String userId,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('チャレンジに参加'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('「${challenge.title}」に参加しますか？'),
            AppSpacing.verticalSpacerMd,
            Text(
              '開始: ${challenge.startDate.month}月${challenge.startDate.day}日',
              style: AppTypography.bodySmall,
            ),
            Text(
              '終了: ${challenge.endDate.month}月${challenge.endDate.day}日',
              style: AppTypography.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Call join challenge action
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('チャレンジに参加しました！')),
              );
            },
            child: const Text('参加'),
          ),
        ],
      ),
    );
  }

  String _getChallengeTypeLabel(ChallengeType type) {
    switch (type) {
      case ChallengeType.individual:
        return '個人';
      case ChallengeType.team:
        return 'チーム';
      case ChallengeType.tournament:
        return 'トーナメント';
      case ChallengeType.timed:
        return 'タイム';
      case ChallengeType.streakBased:
        return 'ストリーク';
      case ChallengeType.skillFocused:
        return 'スキル';
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: AppSpacing.sm),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: AppColors.bgLight,
        selectedColor: AppColors.primary.withAlpha(50),
        labelStyle: AppTypography.bodySmall.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textMuted,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
