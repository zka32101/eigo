import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leaderboard.dart';
import '../providers/leaderboard_service_provider.dart';
import '../providers/auth_provider.dart';
import '../design_system/design_system.dart';
import '../widgets/leaderboard_entry_item.dart';

/// Screen for displaying various leaderboards
class LeaderboardsScreen extends ConsumerStatefulWidget {
  const LeaderboardsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LeaderboardsScreen> createState() => _LeaderboardsScreenState();
}

class _LeaderboardsScreenState extends ConsumerState<LeaderboardsScreen> {
  @override
  Widget build(BuildContext context) {
    final selectedType = ref.watch(selectedLeaderboardTypeProvider);
    final selectedLevel = ref.watch(selectedLevelProvider);
    final currentUser = ref.watch(authProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboards'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Type selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: AppSpacing.horizontalPaddingMd,
            child: Row(
              children: [
                _LeaderboardTypeButton(
                  label: 'Global',
                  type: LeaderboardType.global,
                  isSelected: selectedType == LeaderboardType.global,
                  onTap: () => ref.read(selectedLeaderboardTypeProvider.notifier).state = LeaderboardType.global,
                ),
                AppSpacing.horizontalSpacerMd,
                _LeaderboardTypeButton(
                  label: 'Weekly',
                  type: LeaderboardType.weekly,
                  isSelected: selectedType == LeaderboardType.weekly,
                  onTap: () => ref.read(selectedLeaderboardTypeProvider.notifier).state = LeaderboardType.weekly,
                ),
                AppSpacing.horizontalSpacerMd,
                _LeaderboardTypeButton(
                  label: 'Friends',
                  type: LeaderboardType.friends,
                  isSelected: selectedType == LeaderboardType.friends,
                  onTap: () => ref.read(selectedLeaderboardTypeProvider.notifier).state = LeaderboardType.friends,
                ),
                AppSpacing.horizontalSpacerMd,
                _LeaderboardTypeButton(
                  label: 'Level',
                  type: LeaderboardType.level,
                  isSelected: selectedType == LeaderboardType.level,
                  onTap: () => ref.read(selectedLeaderboardTypeProvider.notifier).state = LeaderboardType.level,
                ),
              ],
            ),
          ),
          AppSpacing.verticalSpacerMd,
          // Level selector (only for level leaderboard)
          if (selectedType == LeaderboardType.level)
            Padding(
              padding: AppSpacing.horizontalPaddingMd,
              child: DropdownButton<int>(
                value: selectedLevel,
                isExpanded: true,
                items: List.generate(20, (i) => i + 1)
                    .map((level) => DropdownMenuItem(
                          value: level,
                          child: Text('Level $level'),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    ref.read(selectedLevelProvider.notifier).state = value;
                  }
                },
              ),
            ),
          AppSpacing.verticalSpacerMd,
          // Current user rank card
          if (currentUser != null)
            Padding(
              padding: AppSpacing.horizontalPaddingMd,
              child: _CurrentUserCard(userId: currentUser.id),
            ),
          AppSpacing.verticalSpacerMd,
          // Leaderboard list
          Expanded(
            child: _LeaderboardContent(
              type: selectedType,
              level: selectedLevel,
              currentUserId: currentUser?.id ?? '',
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardTypeButton extends StatelessWidget {
  final String label;
  final LeaderboardType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _LeaderboardTypeButton({
    required this.label,
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.primary : AppColors.surfaceVariant,
        foregroundColor: isSelected ? Colors.white : AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(label),
    );
  }
}

class _CurrentUserCard extends ConsumerWidget {
  final String userId;

  const _CurrentUserCard({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRank = ref.watch(userRankProvider(userId));

    return userRank.when(
      data: (rank) {
        if (rank == null) {
          return const SizedBox.shrink();
        }
        return Card(
          color: AppColors.primary.withOpacity(0.1),
          child: Padding(
            padding: AppSpacing.allPaddingMd,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Position',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                    AppSpacing.verticalSpacerXs,
                    Text(
                      '#${rank.rank}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${rank.score} points',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '${rank.streakCount} day streak',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}

class _LeaderboardContent extends ConsumerWidget {
  final LeaderboardType type;
  final int level;
  final String currentUserId;

  const _LeaderboardContent({
    required this.type,
    required this.level,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<LeaderboardEntry>> leaderboardData;

    switch (type) {
      case LeaderboardType.global:
        leaderboardData = ref.watch(globalLeaderboardProvider);
        break;
      case LeaderboardType.weekly:
        leaderboardData = ref.watch(weeklyLeaderboardProvider);
        break;
      case LeaderboardType.friends:
        leaderboardData = ref.watch(friendsLeaderboardProvider(currentUserId));
        break;
      case LeaderboardType.level:
        leaderboardData = ref.watch(levelLeaderboardProvider(level));
        break;
    }

    return leaderboardData.when(
      data: (entries) {
        if (entries.isEmpty) {
          return Center(
            child: Text(
              'No leaderboard data available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          );
        }

        return ListView.builder(
          padding: AppSpacing.allPaddingMd,
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return LeaderboardEntryItem(
              entry: entry,
              isCurrentUser: entry.userId == currentUserId,
              onTap: () {
                // Navigate to user profile
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('View profile for ${entry.userName}')),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text(
          'Error loading leaderboard: $error',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.red,
              ),
        ),
      ),
    );
  }
}
