import 'package:flutter/material.dart';
import '../models/social_model.dart';
import '../design_system/design_system.dart';

class FriendCard extends StatelessWidget {
  final Friend friend;
  final UserProfile friendProfile;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final VoidCallback? onMessage;
  final bool isCurrentUser;

  const FriendCard({
    super.key,
    required this.friend,
    required this.friendProfile,
    this.onTap,
    this.onRemove,
    this.onMessage,
    this.isCurrentUser = false,
  });

  String get _statusLabel {
    switch (friend.status) {
      case FriendStatus.pending:
        return '保留中';
      case FriendStatus.accepted:
        return 'フレンド';
      case FriendStatus.blocked:
        return 'ブロック済み';
    }
  }

  Color get _statusColor {
    switch (friend.status) {
      case FriendStatus.pending:
        return AppColors.accentOrange;
      case FriendStatus.accepted:
        return AppColors.accentGreen;
      case FriendStatus.blocked:
        return AppColors.accentRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.bgLight,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Center(
                      child: Text(
                        friendProfile.avatar,
                        style: TextStyle(fontSize: AppTypography.displaySmall.fontSize),
                      ),
                    ),
                  ),
                  AppSpacing.horizontalSpacerMd,
                  // Profile info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                friendProfile.name,
                                style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Online status indicator
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: friendProfile.isOnline ? AppColors.accentGreen : AppColors.textMuted,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.verticalSpacerXs,
                        Row(
                          children: [
                            Text(
                              'Lv${friendProfile.level}',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                            ),
                            AppSpacing.horizontalSpacerSm,
                            Text(
                              '🔥 ${friendProfile.streak}',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                            ),
                            AppSpacing.horizontalSpacerSm,
                            Text(
                              '⭐ ${friendProfile.badges.length}',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                        AppSpacing.verticalSpacerXs,
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                          decoration: BoxDecoration(
                            color: _statusColor.withAlpha(30),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _statusLabel,
                            style: AppTypography.bodySmall.copyWith(
                              color: _statusColor,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (friend.status == FriendStatus.accepted && !isCurrentUser)
                Padding(
                  padding: EdgeInsets.only(top: AppSpacing.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.message, size: 18),
                          label: const Text('メッセージ'),
                          onPressed: onMessage,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                        ),
                      ),
                      AppSpacing.horizontalSpacerSm,
                      OutlinedButton.icon(
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text('削除'),
                        onPressed: onRemove,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accentRed,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
