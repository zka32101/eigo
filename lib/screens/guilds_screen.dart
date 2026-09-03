import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/guild.dart';
import '../providers/guild_service_provider.dart';
import '../providers/auth_provider.dart';
import '../design_system/design_system.dart';
import '../widgets/guild_card.dart';
import '../widgets/guild_member_item.dart';

/// Screen for managing guilds
class GuildsScreen extends ConsumerStatefulWidget {
  const GuildsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<GuildsScreen> createState() => _GuildsScreenState();
}

class _GuildsScreenState extends ConsumerState<GuildsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider).value;
    final viewMode = ref.watch(guildViewModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guilds'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Guilds'),
            Tab(text: 'Browse'),
            Tab(text: 'Details'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // My Guilds Tab
          if (currentUser != null) _MyGuildsTab(userId: currentUser.id),
          // Browse Tab
          const _BrowseGuildsTab(),
          // Guild Details Tab
          const _GuildDetailsTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () => _showCreateGuildDialog(context, currentUser?.id ?? ''),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _showCreateGuildDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Guild'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Guild Name'),
              ),
              AppSpacing.verticalSpacerMd,
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _createGuild(context, userId);
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _createGuild(BuildContext context, String userId) {
    final params = CreateGuildParams(
      name: _nameController.text,
      description: _descriptionController.text,
      icon: '⚔️',
      leaderId: userId,
      settings: GuildSettings(
        isPublic: true,
        maxMembers: 50,
        joinType: GuildJoinType.open,
      ),
    );

    ref.read(createGuildActionProvider.notifier).state = params;
    _nameController.clear();
    _descriptionController.clear();
  }
}

class _MyGuildsTab extends ConsumerWidget {
  final String userId;

  const _MyGuildsTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userGuilds = ref.watch(userGuildsProvider(userId));

    return userGuilds.when(
      data: (guilds) {
        if (guilds.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.groups,
                  size: 64,
                  color: AppColors.textMuted,
                ),
                AppSpacing.verticalSpacerMd,
                Text(
                  'No guilds yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
                Text(
                  'Join or create a guild to get started',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: AppSpacing.allPaddingMd,
          itemCount: guilds.length,
          itemBuilder: (context, index) {
            final guild = guilds[index];
            return GuildCard(
              guild: guild,
              isJoined: true,
              onTap: () => ref.read(selectedGuildProvider.notifier).state = guild.id,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }
}

class _BrowseGuildsTab extends ConsumerWidget {
  const _BrowseGuildsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publicGuilds = ref.watch(publicGuildsProvider);
    final currentUser = ref.watch(authProvider).value;

    return publicGuilds.when(
      data: (guilds) {
        if (guilds.isEmpty) {
          return Center(
            child: Text(
              'No public guilds available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          );
        }

        return ListView.builder(
          padding: AppSpacing.allPaddingMd,
          itemCount: guilds.length,
          itemBuilder: (context, index) {
            final guild = guilds[index];
            final isJoined = guild.memberIds.contains(currentUser?.id);

            return GuildCard(
              guild: guild,
              isJoined: isJoined,
              onJoin: !isJoined
                  ? () {
                      if (currentUser != null) {
                        final params = JoinGuildParams(
                          guildId: guild.id,
                          userId: currentUser.id,
                          userName: currentUser.name,
                          userAvatar: currentUser.avatar,
                        );
                        ref.read(joinGuildActionProvider.notifier).state = params;
                      }
                    }
                  : null,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }
}

class _GuildDetailsTab extends ConsumerWidget {
  const _GuildDetailsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedGuildId = ref.watch(selectedGuildProvider);
    final currentUser = ref.watch(authProvider).value;

    if (selectedGuildId == null) {
      return Center(
        child: Text(
          'Select a guild to view details',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
              ),
        ),
      );
    }

    final guildData = ref.watch(guildProvider(selectedGuildId));
    final guildMembers = ref.watch(guildMembersStreamProvider(selectedGuildId));

    return guildData.when(
      data: (guild) {
        if (guild == null) {
          return Center(
            child: Text(
              'Guild not found',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          );
        }

        final isLeader = currentUser?.id == guild.leaderId;

        return ListView(
          padding: AppSpacing.allPaddingMd,
          children: [
            // Guild header
            Card(
              child: Padding(
                padding: AppSpacing.allPaddingMd,
                child: Column(
                  children: [
                    Text(
                      guild.icon,
                      style: const TextStyle(fontSize: 64),
                    ),
                    AppSpacing.verticalSpacerMd,
                    Text(
                      guild.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    AppSpacing.verticalSpacerXs,
                    Text(
                      guild.description,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            AppSpacing.verticalSpacerMd,
            // Members section
            Text(
              'Members (${guild.memberIds.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            AppSpacing.verticalSpacerMd,
            guildMembers.when(
              data: (members) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return GuildMemberItem(
                      member: member,
                      isLeader: isLeader,
                    );
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
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
