import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/achievement.dart';
import '../providers/achievement_service_provider.dart';
import '../providers/auth_provider.dart';
import '../design_system/design_system.dart';
import '../widgets/achievement_item.dart';

/// Screen for displaying achievements and badges
class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements & Badges'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Achievements'),
            Tab(text: 'Badges'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Achievements tab
          if (currentUser != null)
            _AchievementsTab(userId: currentUser.id)
          else
            const Center(child: Text('Please log in')),
          // Badges tab
          if (currentUser != null)
            _BadgesTab(userId: currentUser.id)
          else
            const Center(child: Text('Please log in')),
        ],
      ),
    );
  }
}

class _AchievementsTab extends ConsumerWidget {
  final String userId;

  const _AchievementsTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAchievements = ref.watch(userAchievementsStreamProvider(userId));
    final selectedCategory = ref.watch(selectedAchievementCategoryProvider);

    return userAchievements.when(
      data: (achievements) {
        // Filter by category
        final filtered = achievements
            .where((a) => a.achievement.category == selectedCategory)
            .toList();

        return Column(
          children: [
            // Category filter
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: AppSpacing.horizontalPaddingMd,
              child: Row(
                children: AchievementCategory.values
                    .map((category) => Padding(
                          padding: AppSpacing.horizontalPaddingSm,
                          child: FilterChip(
                            label: Text(
                              category.toString().split('.').last,
                              style: TextStyle(
                                color: selectedCategory == category
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                            selected: selectedCategory == category,
                            onSelected: (selected) {
                              if (selected) {
                                ref.read(selectedAchievementCategoryProvider.notifier).state =
                                    category;
                              }
                            },
                            backgroundColor: AppColors.surfaceVariant,
                            selectedColor: AppColors.primary,
                          ),
                        ))
                    .toList(),
              ),
            ),
            AppSpacing.verticalSpacerMd,
            // Achievements list
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No achievements in this category',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textMuted,
                            ),
                      ),
                    )
                  : ListView.builder(
                      padding: AppSpacing.allPaddingMd,
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final achievement = filtered[index];
                        return AchievementItem(
                          userAchievement: achievement,
                          isUnlocked: achievement.progress == 100,
                        );
                      },
                    ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }
}

class _BadgesTab extends ConsumerWidget {
  final String userId;

  const _BadgesTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userBadges = ref.watch(userBadgesProvider(userId));
    final selectedRarity = ref.watch(selectedBadgeRarityProvider);

    return userBadges.when(
      data: (badges) {
        // Filter by rarity if selected
        final filtered = selectedRarity != null
            ? badges.where((b) => b.badge.rarity == selectedRarity).toList()
            : badges;

        return Column(
          children: [
            // Rarity filter
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: AppSpacing.horizontalPaddingMd,
              child: Row(
                children: [
                  Padding(
                    padding: AppSpacing.horizontalPaddingSm,
                    child: FilterChip(
                      label: const Text('All'),
                      selected: selectedRarity == null,
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(selectedBadgeRarityProvider.notifier).state = null;
                        }
                      },
                      backgroundColor: AppColors.surfaceVariant,
                      selectedColor: AppColors.primary,
                    ),
                  ),
                  ...BadgeRarity.values
                      .map((rarity) => Padding(
                            padding: AppSpacing.horizontalPaddingSm,
                            child: FilterChip(
                              label: Text(
                                rarity.toString().split('.').last,
                                style: TextStyle(
                                  color: selectedRarity == rarity
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                              selected: selectedRarity == rarity,
                              onSelected: (selected) {
                                if (selected) {
                                  ref.read(selectedBadgeRarityProvider.notifier).state =
                                      rarity;
                                }
                              },
                              backgroundColor: AppColors.surfaceVariant,
                              selectedColor: AppColors.primary,
                            ),
                          ))
                      .toList(),
                ],
              ),
            ),
            AppSpacing.verticalSpacerMd,
            // Badges grid
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No badges earned yet',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textMuted,
                            ),
                      ),
                    )
                  : GridView.builder(
                      padding: AppSpacing.allPaddingMd,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final badge = filtered[index];
                        return BadgeItem(
                          userBadge: badge,
                          canEquip: true,
                          onEquip: () {
                            final params = EquipBadgeParams(
                              userId: userId,
                              badgeId: badge.badgeId,
                            );
                            ref.read(equipBadgeActionProvider.notifier).state = params;
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }
}
