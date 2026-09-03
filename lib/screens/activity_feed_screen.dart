import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/social_model.dart';
import '../providers/social_provider.dart';
import '../design_system/design_system.dart';
import '../widgets/activity_card.dart';

class ActivityFeedScreen extends ConsumerStatefulWidget {
  const ActivityFeedScreen({super.key});

  @override
  ConsumerState<ActivityFeedScreen> createState() => _ActivityFeedScreenState();
}

class _ActivityFeedScreenState extends ConsumerState<ActivityFeedScreen> with SingleTickerProviderStateMixin {
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
    // TODO: Get current user ID from provider
    const currentUserId = 'current-user-id';

    return Scaffold(
      appBar: AppBar(
        title: const Text('アクティビティ'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.textWhite,
          labelColor: AppColors.textWhite,
          unselectedLabelColor: AppColors.textWhite.withOpacity(0.6),
          tabs: const [
            Tab(text: 'フレンドフィード'),
            Tab(text: 'マイアクティビティ'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Friend Feed
          _FriendFeedTab(userId: currentUserId),
          // Tab 2: My Activities
          _MyActivitiesTab(userId: currentUserId),
        ],
      ),
    );
  }
}

class _FriendFeedTab extends ConsumerWidget {
  final String userId;

  const _FriendFeedTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(friendFeedProvider(userId));

    return feedAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('エラーが発生しました', style: AppTypography.labelLarge),
            AppSpacing.verticalSpacerMd,
            ElevatedButton(
              onPressed: () => ref.refresh(friendFeedProvider(userId)),
              child: const Text('再試行'),
            ),
          ],
        ),
      ),
      data: (activities) {
        if (activities.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('📭', style: TextStyle(fontSize: 64)),
                AppSpacing.verticalSpacerMd,
                Text('フレンドのアクティビティはまだありません', style: AppTypography.labelLarge),
                AppSpacing.verticalSpacerMd,
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/friends');
                  },
                  child: const Text('フレンドを追加'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await ref.refresh(friendFeedProvider(userId).future);
          },
          child: ListView.builder(
            itemCount: activities.length,
            itemBuilder: (context, index) {
              return ActivityCard(
                activity: activities[index],
                showUserAvatar: true,
                onTap: () {
                  // Navigate to user profile or activity detail
                  Navigator.pushNamed(
                    context,
                    '/user-profile',
                    arguments: activities[index].userId,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _MyActivitiesTab extends ConsumerWidget {
  final String userId;

  const _MyActivitiesTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(userActivitiesProvider(userId));

    return activitiesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('エラーが発生しました', style: AppTypography.labelLarge),
            AppSpacing.verticalSpacerMd,
            ElevatedButton(
              onPressed: () => ref.refresh(userActivitiesProvider(userId)),
              child: const Text('再試行'),
            ),
          ],
        ),
      ),
      data: (activities) {
        if (activities.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🌱', style: TextStyle(fontSize: 64)),
                AppSpacing.verticalSpacerMd,
                Text('アクティビティはまだありません', style: AppTypography.labelLarge),
                AppSpacing.verticalSpacerMd,
                Text(
                  'ステージをクリアしたり、チャレンジに勝ったりして\nアクティビティを増やしましょう！',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await ref.refresh(userActivitiesProvider(userId).future);
          },
          child: ListView.builder(
            itemCount: activities.length,
            itemBuilder: (context, index) {
              return ActivityCard(
                activity: activities[index],
                showUserAvatar: false,
              );
            },
          ),
        );
      },
    );
  }
}
