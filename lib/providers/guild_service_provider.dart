import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/guild.dart';
import '../services/guild_service.dart';

/// Singleton provider for GuildService
final guildServiceProvider = Provider<GuildService>((ref) {
  return GuildService();
});

/// Parameter classes for actions
class CreateGuildParams {
  final String name;
  final String description;
  final String icon;
  final String leaderId;
  final GuildSettings settings;

  CreateGuildParams({
    required this.name,
    required this.description,
    required this.icon,
    required this.leaderId,
    required this.settings,
  });
}

class JoinGuildParams {
  final String guildId;
  final String userId;
  final String userName;
  final String userAvatar;

  JoinGuildParams({
    required this.guildId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
  });
}

class UpdateGuildParams {
  final String guildId;
  final String name;
  final String description;
  final String icon;

  UpdateGuildParams({
    required this.guildId,
    required this.name,
    required this.description,
    required this.icon,
  });
}

class UpdateMemberRoleParams {
  final String guildId;
  final String userId;
  final GuildRole role;

  UpdateMemberRoleParams({
    required this.guildId,
    required this.userId,
    required this.role,
  });
}

/// ==================== GUILD QUERY PROVIDERS ====================

/// Get user's guilds
final userGuildsProvider = FutureProvider.family<List<Guild>, String>((ref, userId) async {
  final service = ref.watch(guildServiceProvider);
  return service.getUserGuilds(userId);
});

/// Get specific guild
final guildProvider = FutureProvider.family<Guild?, String>((ref, guildId) async {
  final service = ref.watch(guildServiceProvider);
  return service.getGuild(guildId);
});

/// Get guild members
final guildMembersProvider = FutureProvider.family<List<GuildMember>, String>((ref, guildId) async {
  final service = ref.watch(guildServiceProvider);
  return service.getGuildMembers(guildId);
});

/// Stream guild members for real-time updates
final guildMembersStreamProvider = StreamProvider.family<List<GuildMember>, String>((ref, guildId) {
  final service = ref.watch(guildServiceProvider);
  return service.streamGuildMembers(guildId);
});

/// Get public guilds
final publicGuildsProvider = FutureProvider<List<Guild>>((ref) async {
  final service = ref.watch(guildServiceProvider);
  return service.getPublicGuilds(limit: 50);
});

/// Search guilds
final searchGuildsProvider = FutureProvider.family<List<Guild>, String>((ref, query) async {
  final service = ref.watch(guildServiceProvider);
  return service.searchGuilds(query);
});

/// ==================== ACTION PROVIDERS ====================

/// Create guild action
final createGuildActionProvider = StateProvider<CreateGuildParams?>((ref) => null);

final createGuildProvider = FutureProvider<String?>((ref) async {
  final params = ref.watch(createGuildActionProvider);
  if (params == null) return null;

  final service = ref.watch(guildServiceProvider);
  final guildId = await service.createGuild(
    params.name,
    params.description,
    params.icon,
    params.leaderId,
    params.settings,
  );

  // Invalidate related providers
  if (guildId != null) {
    ref.invalidate(userGuildsProvider(params.leaderId));
    ref.invalidate(publicGuildsProvider);
  }

  return guildId;
});

/// Join guild action
final joinGuildActionProvider = StateProvider<JoinGuildParams?>((ref) => null);

final joinGuildProvider = FutureProvider<bool>((ref) async {
  final params = ref.watch(joinGuildActionProvider);
  if (params == null) return false;

  final service = ref.watch(guildServiceProvider);
  final result = await service.joinGuild(
    params.guildId,
    params.userId,
    params.userName,
    params.userAvatar,
  );

  // Invalidate related providers
  if (result) {
    ref.invalidate(userGuildsProvider(params.userId));
    ref.invalidate(guildMembersProvider(params.guildId));
    ref.invalidate(guildMembersStreamProvider(params.guildId));
  }

  return result;
});

/// Leave guild action
final leaveGuildActionProvider = StateProvider<({String guildId, String userId})?>((ref) => null);

final leaveGuildProvider = FutureProvider<bool>((ref) async {
  final params = ref.watch(leaveGuildActionProvider);
  if (params == null) return false;

  final service = ref.watch(guildServiceProvider);
  final result = await service.leaveGuild(params.guildId, params.userId);

  // Invalidate related providers
  if (result) {
    ref.invalidate(userGuildsProvider(params.userId));
    ref.invalidate(guildMembersProvider(params.guildId));
    ref.invalidate(guildMembersStreamProvider(params.guildId));
  }

  return result;
});

/// Update guild action
final updateGuildActionProvider = StateProvider<UpdateGuildParams?>((ref) => null);

final updateGuildProvider = FutureProvider<bool>((ref) async {
  final params = ref.watch(updateGuildActionProvider);
  if (params == null) return false;

  final service = ref.watch(guildServiceProvider);
  final result = await service.updateGuild(
    params.guildId,
    params.name,
    params.description,
    params.icon,
  );

  // Invalidate related providers
  if (result) {
    ref.invalidate(guildProvider(params.guildId));
  }

  return result;
});

/// Change member role action
final changeMemberRoleActionProvider = StateProvider<UpdateMemberRoleParams?>((ref) => null);

final changeMemberRoleProvider = FutureProvider<bool>((ref) async {
  final params = ref.watch(changeMemberRoleActionProvider);
  if (params == null) return false;

  final service = ref.watch(guildServiceProvider);
  final result = await service.changeMemberRole(
    params.guildId,
    params.userId,
    params.role,
  );

  // Invalidate related providers
  if (result) {
    ref.invalidate(guildMembersProvider(params.guildId));
    ref.invalidate(guildMembersStreamProvider(params.guildId));
  }

  return result;
});

/// Remove member action
final removeMemberActionProvider = StateProvider<({String guildId, String userId})?>((ref) => null);

final removeMemberProvider = FutureProvider<bool>((ref) async {
  final params = ref.watch(removeMemberActionProvider);
  if (params == null) return false;

  final service = ref.watch(guildServiceProvider);
  final result = await service.removeMember(params.guildId, params.userId);

  // Invalidate related providers
  if (result) {
    ref.invalidate(guildMembersProvider(params.guildId));
    ref.invalidate(guildMembersStreamProvider(params.guildId));
  }

  return result;
});

/// ==================== UI STATE PROVIDERS ====================

/// Selected guild
final selectedGuildProvider = StateProvider<String?>((ref) => null);

/// Guild search query
final guildSearchQueryProvider = StateProvider<String>((ref) => '');

/// Guild list view mode
final guildViewModeProvider = StateProvider<GuildViewMode>((ref) => GuildViewMode.myGuilds);

enum GuildViewMode {
  myGuilds,
  browse,
  search,
}
