import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/english_town_sync_provider.dart';
import '../design_system/design_system.dart';

/// Widget that displays cloud sync status
class CloudSyncStatusWidget extends ConsumerWidget {
  final bool showTimestamp;

  const CloudSyncStatusWidget({
    Key? key,
    this.showTimestamp = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(cloudSyncStatusProvider);
    final lastSync = ref.watch(lastSyncTimeProvider);
    final cloudAvailable = ref.watch(cloudSyncAvailableProvider);

    if (!cloudAvailable) {
      return _buildOfflineStatus();
    }

    final statusText = getCloudSyncStatusText(status);
    final statusColor = getCloudSyncStatusColor(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        border: Border.all(color: statusColor, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatusIcon(status),
          SizedBox(width: 4),
          Text(
            statusText,
            style: AppTypography.labelSmall.copyWith(
              color: statusColor,
            ),
          ),
          if (showTimestamp && lastSync != null) ...[
            SizedBox(width: 8),
            Text(
              '(${getTimeSinceLastSync(lastSync)})',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textMuted,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build status icon based on sync status
  Widget _buildStatusIcon(CloudSyncStatus status) {
    switch (status) {
      case CloudSyncStatus.idle:
        return Icon(
          Icons.cloud_done,
          size: 14,
          color: Colors.grey,
        );
      case CloudSyncStatus.syncing:
        return SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        );
      case CloudSyncStatus.success:
        return Icon(
          Icons.check_circle,
          size: 14,
          color: Colors.green,
        );
      case CloudSyncStatus.error:
        return Icon(
          Icons.error,
          size: 14,
          color: Colors.red,
        );
    }
  }

  /// Build offline status widget
  Widget _buildOfflineStatus() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        border: Border.all(color: Colors.orange, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off,
            size: 14,
            color: Colors.orange,
          ),
          SizedBox(width: 4),
          Text(
            'Offline',
            style: AppTypography.labelSmall.copyWith(
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}

/// Mini sync indicator for app bar
class CloudSyncIndicator extends ConsumerWidget {
  const CloudSyncIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(cloudSyncStatusProvider);
    final cloudAvailable = ref.watch(cloudSyncAvailableProvider);

    if (!cloudAvailable) {
      return Tooltip(
        message: 'Cloud sync unavailable',
        child: Icon(Icons.cloud_off, size: 20, color: Colors.orange),
      );
    }

    final color = getCloudSyncStatusColor(status);

    Widget icon;
    switch (status) {
      case CloudSyncStatus.idle:
      case CloudSyncStatus.success:
        icon = Icon(Icons.cloud_done, size: 20, color: color);
      case CloudSyncStatus.syncing:
        icon = SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        );
      case CloudSyncStatus.error:
        icon = Icon(Icons.cloud_off, size: 20, color: color);
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Tooltip(
        message: getCloudSyncStatusText(status),
        child: icon,
      ),
    );
  }
}
