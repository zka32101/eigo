import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/friend_model.dart';
import '../providers/friend_provider.dart';
import '../theme/app_theme.dart';
import '../theme/spacing.dart';
import '../theme/sizes.dart';
import '../theme/typography.dart';

class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingCount = ref.watch(
      friendRequestsProvider.select((requests) =>
          requests.where((r) => r.status == FriendRequestStatus.pending).length),
    );

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('👥 フレンド'),
          backgroundColor: kPrimaryColor,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: kAccentOrange,
            tabs: [
              const Tab(text: 'フレンド一覧'),
              Tab(
                child: Stack(
                  children: [
                    const Text('リクエスト'),
                    if (pendingCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: kAccentRed,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$pendingCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
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
            // フレンド一覧
            _FriendListTab(),
            // フレンドリクエスト
            _FriendRequestsTab(),
            // フレンドを探す
            _SearchFriendsTab(),
          ],
        ),
      ),
    );
  }
}

class _FriendListTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friends = ref.watch(friendListProvider);

    if (friends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 64, color: kTextMuted),
            AppSpacing.verticalSpacerMd,
            const Text('フレンドがいません'),
            AppSpacing.verticalSpacerLg,
            ElevatedButton.icon(
              onPressed: () {
                // フレンド探す画面へ切り替え
                DefaultTabController.of(context).animateTo(2);
              },
              icon: const Icon(Icons.person_add),
              label: const Text('フレンドを追加'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
              ),
            ),
          ],
        ),
      );
    }

    // お気に入りフレンドを取得
    final favoriteFriends =
        ref.watch(friendListProvider.select((f) => f.where((x) => x.isFavorite).toList()));
    final nonFavoriteFriends = friends.where((f) => !f.isFavorite).toList();

    // Index mapping:
    // 0: Header card
    // 1: Spacer
    // 2-N: Favorite friends (if any)
    // N+1: Spacer (if favorites)
    // N+2: "その他のフレンド" header
    // N+3: Spacer
    // N+4 onwards: Non-favorite friends

    int _getItemCount() {
      int count = 2; // Header + spacer
      if (favoriteFriends.isNotEmpty) {
        count += 1 + favoriteFriends.length + 1; // Title + favorites + spacer
      }
      count += 2; // "その他のフレンド" title + spacer
      count += nonFavoriteFriends.length;
      count += 1; // Bottom spacer
      return count;
    }

    Widget _buildItem(int index) {
      int currentIndex = 0;

      // Header card
      if (index == currentIndex) {
        return Container(
          padding: AppSpacing.allPaddingMd,
          decoration: BoxDecoration(
            color: kPrimaryColor.withAlpha(10),
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('フレンド数', style: AppTypography.labelSmall.copyWith(color: kTextMuted)),
                  AppSpacing.verticalSpacerXs,
                  Text('${friends.length}人', style: AppTypography.headlineMedium),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: kAccentGreen,
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                ),
                child: Column(
                  children: [
                    Text(
                      '⭐ ${favoriteFriends.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Text(
                      'お気に入り',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
      currentIndex++;

      // Spacer after header
      if (index == currentIndex) {
        return AppSpacing.verticalSpacerLg;
      }
      currentIndex++;

      // Favorite friends section (if any)
      if (favoriteFriends.isNotEmpty) {
        // Favorite title
        if (index == currentIndex) {
          return Text('お気に入り', style: AppTypography.headlineSmall);
        }
        currentIndex++;

        // Favorite spacer
        if (index == currentIndex) {
          return AppSpacing.verticalSpacerMd;
        }
        currentIndex++;

        // Favorite friend cards
        if (index < currentIndex + favoriteFriends.length) {
          final favoriteIndex = index - currentIndex;
          final friend = favoriteFriends[favoriteIndex];
          return Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
            child: _FriendCard(
              friend: friend,
              onFavoriteToggle: () {
                ref.read(friendListProvider.notifier).toggleFavorite(friend.userId);
              },
              onRemove: () {
                ref.read(friendListProvider.notifier).removeFriend(friend.userId);
              },
            ),
          );
        }
        currentIndex += favoriteFriends.length;

        // Spacer after favorites
        if (index == currentIndex) {
          return AppSpacing.verticalSpacerLg;
        }
        currentIndex++;
      }

      // "その他のフレンド" title
      if (index == currentIndex) {
        return Text('その他のフレンド', style: AppTypography.headlineSmall);
      }
      currentIndex++;

      // Spacer
      if (index == currentIndex) {
        return AppSpacing.verticalSpacerMd;
      }
      currentIndex++;

      // Non-favorite friend cards
      if (index < currentIndex + nonFavoriteFriends.length) {
        final friendIndex = index - currentIndex;
        final friend = nonFavoriteFriends[friendIndex];
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: _FriendCard(
            friend: friend,
            onFavoriteToggle: () {
              ref.read(friendListProvider.notifier).toggleFavorite(friend.userId);
            },
            onRemove: () {
              ref.read(friendListProvider.notifier).removeFriend(friend.userId);
            },
          ),
        );
      }
      currentIndex += nonFavoriteFriends.length;

      // Bottom spacer
      return AppSpacing.verticalSpacerXxl;
    }

    return ListView.builder(
      padding: AppSpacing.allPaddingLg,
      itemCount: _getItemCount(),
      itemBuilder: (context, index) => _buildItem(index),
    );
  }
}

class _FriendRequestsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(friendRequestsProvider);
    final pendingRequests = requests
        .where((r) => r.status == FriendRequestStatus.pending)
        .toList();

    if (pendingRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mail_outline, size: 64, color: kTextMuted),
            AppSpacing.verticalSpacerMd,
            const Text('新しいリクエストはありません'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: AppSpacing.allPaddingLg,
      itemCount: 2 + pendingRequests.length + 1, // Title + spacer + requests + bottom spacer
      itemBuilder: (context, index) {
        // Title
        if (index == 0) {
          return Text(
            '${pendingRequests.length}個のリクエスト',
            style: AppTypography.headlineSmall,
          );
        }

        // Spacer after title
        if (index == 1) {
          return AppSpacing.verticalSpacerMd;
        }

        // Request cards
        if (index < 2 + pendingRequests.length) {
          final requestIndex = index - 2;
          final request = pendingRequests[requestIndex];
          return Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
            child: _FriendRequestCard(
              request: request,
              onAccept: () {
                ref.read(friendRequestsProvider.notifier).acceptRequest(request.requestId);
                // フレンドとして追加
                ref.read(friendListProvider.notifier).addFriend(
                  Friend(
                    userId: request.fromUserId,
                    name: request.fromUserName,
                    avatar: request.fromUserAvatar,
                    level: 1,
                    coinsEarned: 0,
                    totalStudyMinutes: 0,
                    addedAt: DateTime.now(),
                  ),
                );
              },
              onReject: () {
                ref.read(friendRequestsProvider.notifier).rejectRequest(request.requestId);
              },
            ),
          );
        }

        // Bottom spacer
        return AppSpacing.verticalSpacerXxl;
      },
    );
  }
}

class _SearchFriendsTab extends StatefulWidget {
  @override
  State<_SearchFriendsTab> createState() => _SearchFriendsTabState();
}

class _SearchFriendsTabState extends State<_SearchFriendsTab> {
  final _searchController = TextEditingController();
  late List<Friend> _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    // サンプルフレンドデータ
    final allUsers = [
      Friend(
        userId: 'search_001',
        name: '太郎',
        avatar: '👨',
        level: 25,
        coinsEarned: 15000,
        totalStudyMinutes: 5400,
        addedAt: DateTime.now(),
      ),
      Friend(
        userId: 'search_002',
        name: '花子',
        avatar: '👩',
        level: 24,
        coinsEarned: 14500,
        totalStudyMinutes: 5200,
        addedAt: DateTime.now(),
      ),
      Friend(
        userId: 'search_003',
        name: 'John',
        avatar: '🧑',
        level: 23,
        coinsEarned: 14000,
        totalStudyMinutes: 5000,
        addedAt: DateTime.now(),
      ),
    ];

    setState(() {
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = allUsers
            .where((user) => user.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.allPaddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 検索ボックス
          TextField(
            controller: _searchController,
            onChanged: _performSearch,
            decoration: InputDecoration(
              hintText: 'フレンドを検索...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              ),
              contentPadding: EdgeInsets.all(AppSpacing.md),
            ),
          ),
          AppSpacing.verticalSpacerLg,

          if (_searchController.text.isEmpty)
            Center(
              child: Column(
                children: [
                  const Icon(Icons.search, size: 64, color: kTextMuted),
                  AppSpacing.verticalSpacerMd,
                  const Text('ユーザー名で検索'),
                ],
              ),
            )
          else if (_searchResults.isEmpty)
            Center(
              child: Column(
                children: [
                  const Icon(Icons.person_off, size: 64, color: kTextMuted),
                  AppSpacing.verticalSpacerMd,
                  const Text('ユーザーが見つかりません'),
                ],
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_searchResults.length}件の検索結果',
                  style: AppTypography.labelSmall.copyWith(color: kTextMuted),
                ),
                AppSpacing.verticalSpacerMd,
                ..._searchResults.asMap().entries.map((entry) {
                  final friend = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                    child: _SearchResultCard(
                      friend: friend,
                      onAdd: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${friend.name}さんにフレンドリクエストを送信しました'),
                            backgroundColor: kAccentGreen,
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
          AppSpacing.verticalSpacerXxl,
        ],
      ),
    );
  }
}

class _FriendCard extends StatelessWidget {
  final Friend friend;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onRemove;

  const _FriendCard({
    required this.friend,
    required this.onFavoriteToggle,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Row(
        children: [
          Text(friend.avatar, style: const TextStyle(fontSize: 32)),
          AppSpacing.horizontalSpacerMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(friend.name, style: AppTypography.labelLarge),
                AppSpacing.verticalSpacerXs,
                Text(
                  'Lv.1 • ${friend.totalStudyMinutes}分学習',
                  style: AppTypography.bodySmall.copyWith(color: kTextMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(friend.isFavorite ? Icons.star : Icons.star_outline, size: 18),
                    AppSpacing.horizontalSpacerSm,
                    Text(friend.isFavorite ? 'お気に入り解除' : 'お気に入り'),
                  ],
                ),
                onTap: onFavoriteToggle,
              ),
              PopupMenuItem(
                child: Row(
                  children: const [
                    Icon(Icons.delete_outline, size: 18, color: kAccentRed),
                    AppSpacing.horizontalSpacerSm,
                    Text('削除'),
                  ],
                ),
                onTap: onRemove,
              ),
            ],
            child: const Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }
}

class _FriendRequestCard extends StatelessWidget {
  final FriendRequest request;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _FriendRequestCard({
    required this.request,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        color: kAccentGreen.withAlpha(10),
        border: Border.all(color: kAccentGreen.withAlpha(50)),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Row(
        children: [
          Text(request.fromUserAvatar, style: const TextStyle(fontSize: 32)),
          AppSpacing.horizontalSpacerMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request.fromUserName, style: AppTypography.labelLarge),
                AppSpacing.verticalSpacerXs,
                Text(
                  'リクエスト受信',
                  style: AppTypography.bodySmall.copyWith(color: kTextMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 32,
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccentGreen,
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  ),
                  child: const Text('承認', style: TextStyle(fontSize: 12)),
                ),
                AppSpacing.horizontalSpacerSm,
                OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  ),
                  child: const Text('拒否', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final Friend friend;
  final VoidCallback onAdd;

  const _SearchResultCard({
    required this.friend,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Row(
        children: [
          Text(friend.avatar, style: const TextStyle(fontSize: 32)),
          AppSpacing.horizontalSpacerMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(friend.name, style: AppTypography.labelLarge),
                AppSpacing.verticalSpacerXs,
                Text(
                  'Lv.${friend.level} • ${friend.totalStudyMinutes}分学習',
                  style: AppTypography.bodySmall.copyWith(color: kTextMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.person_add, size: 16),
            label: const Text('追加'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
