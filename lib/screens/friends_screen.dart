import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/social_model.dart';
import '../providers/social_provider.dart';
import '../design_system/design_system.dart';
import '../widgets/friend_card.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Get current user ID from provider
    const currentUserId = 'current-user-id';

    return Scaffold(
      appBar: AppBar(
        title: const Text('フレンド'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.textWhite,
          labelColor: AppColors.textWhite,
          unselectedLabelColor: AppColors.textWhite.withOpacity(0.6),
          tabs: const [
            Tab(text: 'フレンド'),
            Tab(text: 'リクエスト'),
            Tab(text: '追加'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Friends List
          _FriendsListTab(userId: currentUserId),
          // Tab 2: Pending Requests
          _PendingRequestsTab(userId: currentUserId),
          // Tab 3: Add Friends
          _AddFriendsTab(userId: currentUserId),
        ],
      ),
    );
  }
}

class _FriendsListTab extends ConsumerWidget {
  final String userId;

  const _FriendsListTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsAsync = ref.watch(userFriendsProvider(userId));

    return friendsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('エラーが発生しました', style: AppTypography.labelLarge),
            AppSpacing.verticalSpacerMd,
            ElevatedButton(
              onPressed: () => ref.refresh(userFriendsProvider(userId)),
              child: const Text('再試行'),
            ),
          ],
        ),
      ),
      data: (friends) {
        if (friends.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('👥', style: TextStyle(fontSize: 64)),
                AppSpacing.verticalSpacerMd,
                Text('フレンドがまだいません', style: AppTypography.labelLarge),
                AppSpacing.verticalSpacerMd,
                ElevatedButton(
                  onPressed: () {
                    // Switch to add friends tab
                  },
                  child: const Text('フレンドを追加'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: friends.length,
          itemBuilder: (context, index) {
            final friend = friends[index];
            if (friend.friendProfile == null) return const SizedBox.shrink();

            return FriendCard(
              friend: friend,
              friendProfile: friend.friendProfile!,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/user-profile',
                  arguments: friend.friendId,
                );
              },
              onRemove: () {
                _showRemoveConfirmation(context, ref, friend, userId);
              },
              onMessage: () {
                // TODO: Navigate to chat screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('チャット機能は近日公開予定です')),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showRemoveConfirmation(BuildContext context, WidgetRef ref, Friend friend, String userId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('フレンドを削除'),
        content: Text('${friend.friendProfile?.name}をフレンドから削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              ref.read(removeFriendActionProvider(
                RemoveFriendParams(
                  userId: userId,
                  friendId: friend.friendId,
                ),
              ));
              Navigator.pop(ctx);
            },
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _PendingRequestsTab extends ConsumerWidget {
  final String userId;

  const _PendingRequestsTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(pendingFriendRequestsProvider(userId));

    return requestsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('エラーが発生しました', style: AppTypography.labelLarge),
          ],
        ),
      ),
      data: (requests) {
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('💌', style: TextStyle(fontSize: 64)),
                AppSpacing.verticalSpacerMd,
                Text('フレンドリクエストはありません', style: AppTypography.labelLarge),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            if (request.friendProfile == null) return const SizedBox.shrink();

            return Card(
              margin: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.bgLight,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Center(
                            child: Text(
                              request.friendProfile!.avatar,
                              style: TextStyle(fontSize: AppTypography.displaySmall.fontSize),
                            ),
                          ),
                        ),
                        AppSpacing.horizontalSpacerMd,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                request.friendProfile!.name,
                                style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Lv${request.friendProfile!.level}',
                                style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.verticalSpacerMd,
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              ref.read(declineFriendRequestActionProvider(
                                AcceptFriendRequestParams(
                                  userId: userId,
                                  friendId: request.friendId,
                                ),
                              ));
                            },
                            child: const Text('辞退'),
                          ),
                        ),
                        AppSpacing.horizontalSpacerMd,
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              ref.read(acceptFriendRequestActionProvider(
                                AcceptFriendRequestParams(
                                  userId: userId,
                                  friendId: request.friendId,
                                ),
                              ));
                            },
                            child: const Text('承認'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _AddFriendsTab extends ConsumerStatefulWidget {
  final String userId;

  const _AddFriendsTab({required this.userId});

  @override
  ConsumerState<_AddFriendsTab> createState() => _AddFriendTabState();
}

class _AddFriendTabState extends ConsumerState<_AddFriendsTab> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResultsAsync = _searchQuery.isEmpty
        ? AsyncValue.data(<UserProfile>[])
        : ref.watch(searchUsersProvider(_searchQuery));

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: TextField(
            controller: _searchController,
            onChanged: (query) {
              setState(() => _searchQuery = query);
            },
            decoration: InputDecoration(
              hintText: 'ユーザー名で検索...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
            ),
          ),
        ),
        Expanded(
          child: searchResultsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('エラー: $error'),
            ),
            data: (results) {
              if (_searchQuery.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🔍', style: TextStyle(fontSize: 64)),
                      AppSpacing.verticalSpacerMd,
                      Text('ユーザーを検索してフレンドを追加', style: AppTypography.labelLarge),
                    ],
                  ),
                );
              }

              if (results.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('ユーザーが見つかりません', style: AppTypography.labelLarge),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final user = results[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.bgLight,
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Center(
                              child: Text(
                                user.avatar,
                                style: TextStyle(fontSize: AppTypography.displaySmall.fontSize),
                              ),
                            ),
                          ),
                          AppSpacing.horizontalSpacerMd,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Lv${user.level}',
                                  style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              ref.read(sendFriendRequestActionProvider(
                                SendFriendRequestParams(
                                  userId: widget.userId,
                                  friendId: user.id,
                                ),
                              ));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${user.name}にリクエストを送信しました')),
                              );
                            },
                            child: const Text('リクエスト'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
