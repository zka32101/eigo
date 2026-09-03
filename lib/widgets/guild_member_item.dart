import 'package:flutter/material.dart';
import '../models/guild.dart';
import '../design_system/design_system.dart';

/// Widget for displaying a guild member
class GuildMemberItem extends StatelessWidget {
  final GuildMember member;
  final bool isLeader;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final VoidCallback? onPromote;

  const GuildMemberItem({
    Key? key,
    required this.member,
    required this.isLeader,
    this.onTap,
    this.onRemove,
    this.onPromote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: AppSpacing.allPaddingSm,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.allPaddingMd,
          child: Row(
            children: [
              // Avatar
              Text(
                member.userAvatar,
                style: const TextStyle(fontSize: 32),
              ),
              AppSpacing.horizontalSpacerMd,
              // Member info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          member.userName,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        AppSpacing.horizontalSpacerSm,
                        _RoleBadge(role: member.role),
                      ],
                    ),
                    AppSpacing.verticalSpacerXs,
                    Text(
                      'Score: ${member.contributionScore}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
              if (isLeader && member.role != GuildRole.leader)
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('Promote'),
                      onTap: onPromote,
                    ),
                    PopupMenuItem(
                      child: const Text('Remove'),
                      onTap: onRemove,
                    ),
                  ],
                )
              else
                Icon(
                  member.isActive ? Icons.check_circle : Icons.offline_bolt,
                  color: member.isActive ? Colors.green : AppColors.textMuted,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final GuildRole role;

  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (role) {
      GuildRole.leader => ('Leader', const Color(0xFFFFD700)),
      GuildRole.officer => ('Officer', AppColors.primary),
      GuildRole.member => ('Member', AppColors.surfaceVariant),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: role == GuildRole.leader ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
