import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/english_town_model.dart';
import '../providers/english_town_provider.dart';
import '../design_system/design_system.dart';
import 'english_town_conversation_screen.dart';
import 'english_town_analytics_screen.dart';
import 'english_town_settings_screen.dart';

/// English-Only Town Hub Screen
///
/// Main screen for the 2D exploration mini-game.
/// Features:
/// - Town map visualization with locations
/// - Location selection
/// - NPC directory
/// - Progress tracking
/// - Daily challenges display
class EnglishTownHubScreen extends ConsumerStatefulWidget {
  const EnglishTownHubScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EnglishTownHubScreen> createState() =>
      _EnglishTownHubScreenState();
}

class _EnglishTownHubScreenState extends ConsumerState<EnglishTownHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final townMap = ref.watch(townMapProvider);
    final progress = ref.watch(townProgressProvider);
    final progressPercentage = ref.watch(townProgressPercentageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🕹️ English-Only Town'),
        elevation: 0,
        actions: [
          // Analytics button
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Analytics',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EnglishTownAnalyticsScreen(),
                ),
              );
            },
          ),
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EnglishTownSettingsScreen(),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.map), text: 'Town'),
            Tab(icon: Icon(Icons.people), text: 'NPCs'),
            Tab(icon: Icon(Icons.emoji_events), text: 'Challenges'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTownTab(townMap, progress, progressPercentage),
          _buildNPCTab(townMap, progress),
          _buildChallengesTab(),
        ],
      ),
    );
  }

  /// Build town map tab with location grid
  Widget _buildTownTab(
    TownMap townMap,
    TownProgress progress,
    int progressPercentage,
  ) {
    return SingleChildScrollView(
      padding: AppSpacing.allPaddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress header
          _buildProgressHeader(progress, progressPercentage),
          SizedBox(height: AppSpacing.lg),

          // Location grid
          Text(
            'Explore Locations',
            style: AppTypography.headlineSmall,
          ),
          SizedBox(height: AppSpacing.md),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: townMap.locations.length,
            itemBuilder: (context, index) {
              final location = townMap.locations[index];
              final isVisited = progress.visitedLocationIds.contains(location.id);

              return _buildLocationCard(
                location: location,
                isVisited: isVisited,
                onTap: () => _navigateToLocation(location),
              );
            },
          ),

          SizedBox(height: AppSpacing.lg),

          // Stats display
          _buildStatsRow(progress),
        ],
      ),
    );
  }

  /// Build progress header with percentage
  Widget _buildProgressHeader(
    TownProgress progress,
    int progressPercentage,
  ) {
    return Card(
      child: Padding(
        padding: AppSpacing.allPaddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Overall Progress',
                  style: AppTypography.titleMedium,
                ),
                Text(
                  '$progressPercentage%',
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.accentGreen,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.borderRadius / 2),
              child: LinearProgressIndicator(
                value: progressPercentage / 100.0,
                minHeight: 8,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.accentGreen,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              '${progress.visitedLocationIds.length}/8 locations visited • ${progress.totalConversations} conversations',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual location card
  Widget _buildLocationCard({
    required Location location,
    required bool isVisited,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            border: Border.all(
              color: isVisited ? AppColors.accentGreen : AppColors.border,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                location.emoji,
                style: const TextStyle(fontSize: 48),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                location.name,
                style: AppTypography.titleSmall,
                textAlign: TextAlign.center,
              ),
              if (isVisited)
                Padding(
                  padding: EdgeInsets.only(top: AppSpacing.xs),
                  child: Icon(
                    Icons.check_circle,
                    color: AppColors.accentGreen,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build stats row showing XP and coins
  Widget _buildStatsRow(TownProgress progress) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: AppSpacing.allPaddingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total XP',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    progress.totalXpEarned.toString(),
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.accentOrange,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Card(
            child: Padding(
              padding: AppSpacing.allPaddingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Coins Earned',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    progress.totalCoinsEarned.toString(),
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build NPC directory tab
  Widget _buildNPCTab(TownMap townMap, TownProgress progress) {
    return ListView.builder(
      padding: AppSpacing.allPaddingMd,
      itemCount: townMap.npcs.length,
      itemBuilder: (context, index) {
        final npc = townMap.npcs[index];
        final conversationCount =
            progress.npcConversationCounts[npc.id] ?? 0;
        final location = townMap.getLocation(npc.nativeLocation);

        return Card(
          margin: EdgeInsets.only(bottom: AppSpacing.md),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: npc.characterColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(npc.emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
            title: Text(npc.name, style: AppTypography.titleSmall),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${location?.name ?? "Unknown"}',
                  style: AppTypography.labelSmall,
                ),
                Text(
                  'Personality: ${npc.personality}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$conversationCount',
                  style: AppTypography.titleSmall.copyWith(
                    color: npc.characterColor,
                  ),
                ),
                Text(
                  'talks',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build daily challenges tab
  Widget _buildChallengesTab() {
    return Consumer(
      builder: (context, ref, child) {
        final challenges = ref.watch(dailyChallengesProvider);
        final completedCount = ref.watch(completedChallengesCountProvider);

        return SingleChildScrollView(
          padding: AppSpacing.allPaddingMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Challenge progress header
              Card(
                child: Padding(
                  padding: AppSpacing.allPaddingMd,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Daily Challenges',
                            style: AppTypography.titleMedium,
                          ),
                          Text(
                            '$completedCount/${challenges.length}',
                            style: AppTypography.headlineSmall.copyWith(
                              color: AppColors.accentGreen,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.md),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppSizes.borderRadius / 2),
                        child: LinearProgressIndicator(
                          value: challenges.isEmpty
                              ? 0
                              : completedCount / challenges.length,
                          minHeight: 8,
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.accentGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: AppSpacing.lg),

              // Challenge list
              ...challenges.map(
                (challenge) => _buildChallengeCard(challenge),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build individual challenge card
  Widget _buildChallengeCard(DailyChallenge challenge) {
    final progress = (challenge.currentCount / challenge.targetCount).clamp(0.0, 1.0);

    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: AppSpacing.allPaddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: AppTypography.titleSmall,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        challenge.description,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (challenge.isCompleted)
                  Icon(
                    Icons.check_circle,
                    color: AppColors.accentGreen,
                    size: 28,
                  ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.borderRadius / 2),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                  challenge.isCompleted
                      ? AppColors.accentGreen
                      : AppColors.primary,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${challenge.currentCount}/${challenge.targetCount}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.star, color: AppColors.warning, size: 16),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      '+${challenge.xpReward}',
                      style: AppTypography.labelSmall,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Navigate to location and show available scenes
  void _navigateToLocation(Location location) {
    final townMap = ref.read(townMapProvider);

    showModalBottomSheet(
      context: context,
      builder: (context) => _buildLocationModal(location, townMap),
    );
  }

  /// Build modal for location with available scenes
  Widget _buildLocationModal(Location location, TownMap townMap) {
    final scenes = townMap.getLocationScenes(location.id);

    return Container(
      padding: AppSpacing.allPaddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${location.emoji} ${location.name}',
            style: AppTypography.headlineSmall,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            location.description,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            'Available Conversations',
            style: AppTypography.titleSmall,
          ),
          SizedBox(height: AppSpacing.md),
          Expanded(
            child: ListView.builder(
              itemCount: scenes.length,
              itemBuilder: (context, index) {
                final scene = scenes[index];
                final npc = townMap.getNPC(scene.npcId);

                return ListTile(
                  leading: Text(npc?.emoji ?? '😊', style: const TextStyle(fontSize: 24)),
                  title: Text(scene.title),
                  subtitle: Text(
                    npc?.name ?? 'Unknown NPC',
                    style: AppTypography.labelSmall,
                  ),
                  trailing: Text(
                    '+${scene.xpReward} XP',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.accentOrange,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _startConversation(scene, npc!);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Start a conversation with an NPC
  void _startConversation(InteractionScene scene, NPC npc) {
    // Initialize conversation state
    ref.read(currentConversationProvider.notifier).startConversation(
      sceneId: scene.id,
      npcId: npc.id,
      locationId: scene.locationId,
    );

    // Mark location as visited
    ref.read(townProgressProvider.notifier).visitLocation(scene.locationId);

    // Navigate to conversation screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnglishTownConversationScreen(
          npcId: npc.id,
          locationId: scene.locationId,
          sceneId: scene.id,
        ),
      ),
    );
  }
}
