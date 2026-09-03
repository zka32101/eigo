import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../design_system/design_system.dart';
import '../models/english_town_social_model.dart';
import '../providers/english_town_social_provider.dart';

/// Social friends list screen with Phase 9 integration
class SocialFriendsListScreen extends ConsumerWidget {
  const SocialFriendsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsList = ref.watch(friendsListProvider);
    final pendingRequests = ref.watch(pendingFriendRequestsProvider);
    final pendingCount = pendingRequests.whenData((r) {
      return r.where((f) => f.status == FriendshipStatus.pending).length;
    }).value ?? 0;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('👥 フレンド'),
          backgroundColor: AppColors.primary,
          centerTitle: true,
          bottom: TabBar(
            labelColor: AppColors.textWhite,
            unselectedLabelColor: AppColors.textWhite.withOpacity(0.7),
            indicatorColor: AppColors.accentOrange,
            tabs: [
              const Tab(text: 'フレンド一覧'),
              Tab(
                child: Stack(
                  children: [
                    const Text('リクエスト'),
                    if (pendingCount > 0)
                      Positioned(
                        right: -8,
                        top: -8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.accentRed,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$pendingCount',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Tab(text: 'さがす'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Friends list
            friendsList.when(
              data: (friends) => _FriendsListTab(friends: friends),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('エラー: $error')),
            ),
            // Friend requests
            pendingRequests.when(
              data: (requests) => _FriendRequestsTab(requests: requests),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('エラー: $error')),
            ),
            // Search friends
            const _SearchFriendsTab(),
          ],
        ),
      ),
    );
  }
}

class _FriendsListTab extends ConsumerWidget {
  final List<SocialProfile> friends;

  const _FriendsListTab({required this.friends});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (friends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: AppColors.textMuted,
            ),
            AppSpacing.verticalSpacerMd,
            const Text('フレンドがいません'),
            AppSpacing.verticalSpacerLg,
            ElevatedButton.icon(
              onPressed: () {
                DefaultTabController.of(context)?.animateTo(2);
              },
              icon: const Icon(Icons.person_add),
              label: const Text('フレンドを追加'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.lg),
      itemCount: friends.length + 2, // +2 for header and bottom spacer
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'フレンド数',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                AppSpacing.verticalSpacerSm,
                Text(
                  '${friends.length}人',
                  style: AppTypography.headlineMedium,
                ),
              ],
            ),
          );
        }

        if (index == friends.length + 1) {
          return SizedBox(height: AppSpacing.xxl);
        }

        final friend = friends[index - 1];
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: _FriendCard(friend: friend),
        );
      },
    );
  }
}

class _FriendCard extends StatelessWidget {
  final SocialProfile friend;

  const _FriendCard({required this.friend});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          '/social/profile',
          arguments: friend.userId,
        );
      },
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.textWhite,
          border: Border.all(color: AppColors.bgLight),
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
        child: Row(
          children: [
            // Avatar
            if (friend.avatarUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  friend.avatarUrl!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withAlpha(50),
                ),
                child: const Center(
                  child: Icon(Icons.person, size: 28),
                ),
              ),
            AppSpacing.horizontalSpacerMd,

            // Friend info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friend.displayName,
                    style: AppTypography.labelLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.verticalSpacerXs,
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      AppSpacing.horizontalSpacerXs,
                      Text(
                        'Lv.${friend.level} • ${friend.totalXp} XP',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      AppSpacing.horizontalSpacerMd,
                      Icon(
                        Icons.show_chart,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      AppSpacing.horizontalSpacerXs,
                      Text(
                        '🔥 ${friend.currentStreak}',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            PopupMenuButton<String>(
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: const [
                      Icon(Icons.person, size: 18),
                      SizedBox(width: 8),
                      Text('プロフィール'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'compare',
                  child: Row(
                    children: const [
                      Icon(Icons.bar_chart, size: 18),
                      SizedBox(width: 8),
                      Text('比較'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'invite',
                  child: Row(
                    children: const [
                      Icon(Icons.sports_esports, size: 18),
                      SizedBox(width: 8),
                      Text('招待'),
                    ],
                  ),
                ),
                PopupMenuDivider(),
                PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: const [
                      Icon(Icons.delete_outline, size: 18, color: AppColors.accentRed),
                      SizedBox(width: 8),
                      Text('削除', style: TextStyle(color: AppColors.accentRed)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'profile':
                    Navigator.of(context).pushNamed(
                      '/social/profile',
                      arguments: friend.userId,
                    );
                    break;
                  case 'compare':
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('統計比較機能')),
                    );
                    break;
                  case 'invite':
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('チャレンジ招待機能')),
                    );
                    break;
                  case 'remove':
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('フレンドを削除しました')),
                    );
                    break;
                }
              },
              child: const Icon(Icons.more_vert),
            ),
          ],
        ),
      ),
    );
  }
}

class _FriendRequestsTab extends ConsumerWidget {
  final List<Friendship> requests;

  const _FriendRequestsTab({required this.requests});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingRequests = requests
        .where((r) => r.status == FriendshipStatus.pending)
        .toList();

    if (pendingRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mail_outline,
              size: 64,
              color: AppColors.textMuted,
            ),
            AppSpacing.verticalSpacerMd,
            const Text('新しいリクエストはありません'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.lg),
      itemCount: pendingRequests.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.lg),
            child: Text(
              '${pendingRequests.length}個のリクエスト',
              style: AppTypography.headlineSmall,
            ),
          );
        }

        if (index == pendingRequests.length + 1) {
          return SizedBox(height: AppSpacing.xxl);
        }

        final request = pendingRequests[index - 1];
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: _FriendRequestCard(request: request),
        );
      },
    );
  }
}

class _FriendRequestCard extends ConsumerWidget {
  final Friendship request;

  const _FriendRequestCard({required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.accentGreen.withAlpha(10),
        border: Border.all(
          color: AppColors.accentGreen.withAlpha(50),
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withAlpha(50),
            ),
            child: const Center(
              child: Icon(Icons.person, size: 28),
            ),
          ),
          AppSpacing.horizontalSpacerMd,

          // Request info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.userId2 == request.initiatedBy
                      ? 'フレンドリクエスト受信'
                      : 'フレンドリクエスト送信',
                  style: AppTypography.labelLarge,
                ),
                AppSpacing.verticalSpacerXs,
                Text(
                  '${request.connectedAt.year}年${request.connectedAt.month}月${request.connectedAt.day}日',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          SizedBox(
            height: 32,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    acceptFriendRequest(ref, request.friendshipId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('フレンドリクエストを承認しました')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  ),
                  child: Text(
                    '承認',
                    style: AppTypography.labelSmall,
                  ),
                ),
                AppSpacing.horizontalSpacerSm,
                OutlinedButton(
                  onPressed: () {
                    declineFriendRequest(ref, request.friendshipId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('リクエストを拒否しました')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  ),
                  child: Text(
                    '拒否',
                    style: AppTypography.labelSmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchFriendsTab extends ConsumerStatefulWidget {
  const _SearchFriendsTab();

  @override
  ConsumerState<_SearchFriendsTab> createState() => _SearchFriendsTabState();
}

class _SearchFriendsTabState extends ConsumerState<_SearchFriendsTab> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = _searchController.text.isEmpty
        ? const AsyncValue.data([])
        : ref.watch(userSearchProvider(_searchController.text));

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search box
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'ユーザー名で検索...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              ),
              contentPadding: EdgeInsets.all(AppSpacing.md),
            ),
          ),
          AppSpacing.verticalSpacerLg,

          // Results
          if (_searchController.text.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.search,
                    size: 64,
                    color: AppColors.textMuted,
                  ),
                  AppSpacing.verticalSpacerMd,
                  const Text('ユーザー名で検索'),
                ],
              ),
            )
          else
            searchResults.when(
              data: (results) {
                if (results.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.person_off,
                          size: 64,
                          color: AppColors.textMuted,
                        ),
                        AppSpacing.verticalSpacerMd,
                        const Text('ユーザーが見つかりません'),
                      ],
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${results.length}件の検索結果',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    AppSpacing.verticalSpacerMd,
                    ...results.map((user) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.md),
                        child: _SearchResultCard(user: user),
                      );
                    }).toList(),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('エラー: $error'),
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchResultCard extends ConsumerWidget {
  final SocialProfile user;

  const _SearchResultCard({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        border: Border.all(color: AppColors.bgLight),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Row(
        children: [
          // Avatar
          if (user.avatarUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                user.avatarUrl!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withAlpha(50),
              ),
              child: const Center(
                child: Icon(Icons.person, size: 28),
              ),
            ),
          AppSpacing.horizontalSpacerMd,

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: AppTypography.labelLarge,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.verticalSpacerXs,
                Text(
                  'Lv.${user.level} • ${user.totalXp} XP',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Add button
          ElevatedButton.icon(
            onPressed: () {
              sendFriendRequest(ref, user.userId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${user.displayName}さんにフレンドリクエストを送信しました'),
                  backgroundColor: AppColors.accentGreen,
                ),
              );
            },
            icon: const Icon(Icons.person_add, size: AppSizes.iconSizeSmall),
            label: const Text('追加'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
