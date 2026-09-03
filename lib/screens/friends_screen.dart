import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/friend_request.dart';
import '../models/user_profile.dart';
import '../providers/friend_service_provider.dart';
import '../providers/user_profile_service_provider.dart';
import '../widgets/friend_request_card.dart';
import '../widgets/friend_list_item.dart';
import '../design_system/design_system.dart';

/// Friends management screen with tabs for requests, friends, suggestions, blocked
/// Phase 14 Part 2: Friend System
class FriendsScreen extends ConsumerStatefulWidget {
  final String currentUserId;

  const FriendsScreen({
    Key? key,
    required this.currentUserId,
  }) : super(key: key);

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Requests'),
            Tab(text: 'Friends'),
            Tab(text: 'Suggestions'),
            Tab(text: 'Blocked'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequestsTab(),
          _buildFriendsTab(),
          _buildSuggestionsTab(),
          _buildBlockedTab(),
        ],
      ),
    );
  }

  Widget _buildRequestsTab() {
    final requestsAsync = ref.watch(receivedFriendRequestsProvider(widget.currentUserId));
    final currentUserAsync = ref.watch(userProfileProvider(widget.currentUserId));

    return requestsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => _buildErrorWidget(() => ref.refresh(receivedFriendRequestsProvider(widget.currentUserId))),
      data: (requests) {
        if (requests.isEmpty) {
          return Center(
            child: Text(
              'No friend requests',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          );
        }

        return currentUserAsync.when(
          data: (currentUser) {
            if (currentUser == null) return const SizedBox();

            return ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return FriendRequestCard(
                  request: request,
                  onAccept: () => _handleAcceptRequest(request, currentUser),
                  onDecline: () => _handleDeclineRequest(request),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => _buildErrorWidget(() => ref.refresh(userProfileProvider(widget.currentUserId))),
        );
      },
    );
  }

  Widget _buildFriendsTab() {
    final friendsAsync = ref.watch(friendListProvider(widget.currentUserId));

    return friendsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => _buildErrorWidget(() => ref.refresh(friendListProvider(widget.currentUserId))),
      data: (friends) {
        if (friends.isEmpty) {
          return Center(
            child: Text(
              'No friends yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          );
        }

        return ListView.builder(
          itemCount: friends.length,
          itemBuilder: (context, index) {
            final friend = friends[index];
            return FriendListItem(
              friend: friend,
              onRemove: () => _handleRemoveFriend(friend),
              onBlock: () => _handleBlockUser(friend),
            );
          },
        );
      },
    );
  }

  Widget _buildSuggestionsTab() {
    final suggestionsAsync = ref.watch(friendSuggestionsProvider(widget.currentUserId));

    return suggestionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => _buildErrorWidget(() => ref.refresh(friendSuggestionsProvider(widget.currentUserId))),
      data: (suggestions) {
        if (suggestions.isEmpty) {
          return Center(
            child: Text(
              'No suggestions available',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          );
        }

        return ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final profile = suggestions[index];
            return Card(
              margin: AppSpacing.allPaddingSm,
              child: Padding(
                padding: AppSpacing.allPaddingMd,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              profile.avatar,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        ),
                        AppSpacing.horizontalSpacerMd,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.name,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              AppSpacing.verticalSpacerXs,
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Lv. ${profile.level}',
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                    ),
                                  ),
                                  AppSpacing.horizontalSpacerSm,
                                  Text(
                                    'Grade ${profile.grade}',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: AppColors.textMuted,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.verticalSpacerMd,
                    ElevatedButton(
                      onPressed: () => _handleSendFriendRequest(profile),
                      child: const Text('Add Friend'),
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

  Widget _buildBlockedTab() {
    final blockedAsync = ref.watch(blockedUsersProvider(widget.currentUserId));

    return blockedAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => _buildErrorWidget(() => ref.refresh(blockedUsersProvider(widget.currentUserId))),
      data: (blockedIds) {
        if (blockedIds.isEmpty) {
          return Center(
            child: Text(
              'No blocked users',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          );
        }

        return ListView.builder(
          itemCount: blockedIds.length,
          itemBuilder: (context, index) {
            final blockedId = blockedIds[index];
            final profileAsync = ref.watch(userProfileProvider(blockedId));

            return profileAsync.when(
              data: (profile) {
                if (profile == null) return const SizedBox();

                return Card(
                  margin: AppSpacing.allPaddingSm,
                  child: Padding(
                    padding: AppSpacing.allPaddingMd,
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              profile.avatar,
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                        AppSpacing.horizontalSpacerMd,
                        Expanded(
                          child: Text(
                            profile.name,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _handleUnblockUser(profile.id),
                          child: const Text('Unblock'),
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const Center(child: SizedBox(height: 50, child: CircularProgressIndicator())),
              error: (err, stack) => const SizedBox(),
            );
          },
        );
      },
    );
  }

  Widget _buildErrorWidget(VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Error loading data',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          AppSpacing.verticalSpacerMd,
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _handleAcceptRequest(FriendRequest request, UserProfile currentUser) async {
    final senderProfile = await ref.read(userProfileProvider(request.senderId).future);
    if (senderProfile == null) return;

    ref.read(acceptFriendRequestActionProvider.notifier).state = AcceptFriendRequestParams(
      requestId: request.id,
      userId1: request.senderId,
      userId1Name: request.senderName,
      userId1Avatar: request.senderAvatar,
      userId1Grade: senderProfile.grade,
      userId1Level: senderProfile.level,
      userId2: currentUser.id,
      userId2Name: currentUser.name,
      userId2Avatar: currentUser.avatar,
      userId2Grade: currentUser.grade,
      userId2Level: currentUser.level,
    );

    final result = await ref.read(acceptFriendRequestProvider.future);
    if (result && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend request accepted!')),
      );
    }
  }

  void _handleDeclineRequest(FriendRequest request) async {
    ref.read(declineFriendRequestActionProvider.notifier).state = request.id;
    final result = await ref.read(declineFriendRequestProvider.future);
    if (result && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend request declined')),
      );
    }
  }

  void _handleRemoveFriend(Friend friend) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Friend'),
        content: Text('Remove ${friend.name} from your friends?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    ref.read(removeFriendActionProvider.notifier).state = (
      user1: widget.currentUserId,
      user2: friend.userId,
    );

    final result = await ref.read(removeFriendProvider.future);
    if (result && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend removed')),
      );
    }
  }

  void _handleBlockUser(Friend friend) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: Text('Block ${friend.name}? They won\'t be able to send you friend requests.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Block'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    ref.read(blockUserActionProvider.notifier).state = BlockUserParams(
      blockingUserId: widget.currentUserId,
      blockedUserId: friend.userId,
    );

    final result = await ref.read(blockUserProvider.future);
    if (result && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User blocked')),
      );
    }
  }

  void _handleSendFriendRequest(UserProfile profile) async {
    final currentUser = await ref.read(userProfileProvider(widget.currentUserId).future);
    if (currentUser == null) return;

    ref.read(sendFriendRequestActionProvider.notifier).state = SendFriendRequestParams(
      senderId: widget.currentUserId,
      senderName: currentUser.name,
      senderAvatar: currentUser.avatar,
      receiverId: profile.id,
    );

    final result = await ref.read(sendFriendRequestProvider.future);
    if (result && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend request sent to ${profile.name}!')),
      );
    }
  }

  void _handleUnblockUser(String userId) async {
    ref.read(unblockUserActionProvider.notifier).state = (
      blockingUserId: widget.currentUserId,
      unblockedUserId: userId,
    );

    final result = await ref.read(unblockUserProvider.future);
    if (result && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User unblocked')),
      );
    }
  }
}
