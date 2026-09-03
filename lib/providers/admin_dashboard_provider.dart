import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin_dashboard_model.dart';
import '../services/admin_dashboard_service.dart';

// ===== Service Provider =====

/// Admin dashboard service provider
final adminDashboardServiceProvider =
    Provider<AdminDashboardService>((ref) {
  return AdminDashboardService();
});

// ===== System Health Providers =====

/// Current system health status
final systemHealthProvider = FutureProvider<SystemHealthStatus?>((ref) async {
  final service = ref.watch(adminDashboardServiceProvider);
  return service.getSystemHealth();
});

/// System health history
final systemHealthHistoryProvider =
    FutureProvider.family<List<SystemHealthStatus>, int>((ref, days) async {
  final service = ref.watch(adminDashboardServiceProvider);
  return service.getSystemHealthHistory(days: days);
});

// ===== Alert Providers =====

/// Active system alerts
final activeAlertsProvider = FutureProvider<List<SystemAlert>>((ref) async {
  final service = ref.watch(adminDashboardServiceProvider);
  return service.getActiveAlerts();
});

/// Create alert action
Future<void> createSystemAlert(
  WidgetRef ref, {
  required String title,
  required String description,
  required AlertSeverity severity,
}) async {
  final service = ref.read(adminDashboardServiceProvider);
  await service.createAlert(
    title: title,
    description: description,
    severity: severity,
  );

  // Refresh alerts
  ref.refresh(activeAlertsProvider);
}

/// Resolve alert action
Future<void> resolveSystemAlert(
  WidgetRef ref, {
  required String alertId,
  required String resolvedBy,
}) async {
  final service = ref.read(adminDashboardServiceProvider);
  await service.resolveAlert(
    alertId: alertId,
    resolvedBy: resolvedBy,
  );

  // Refresh alerts
  ref.refresh(activeAlertsProvider);
}

// ===== Admin User Providers =====

/// All admin users
final adminUsersProvider = FutureProvider<List<AdminUser>>((ref) async {
  final service = ref.watch(adminDashboardServiceProvider);
  return service.getAllAdminUsers();
});

/// Single admin user
final adminUserProvider =
    FutureProvider.family<AdminUser?, String>((ref, userId) async {
  final service = ref.watch(adminDashboardServiceProvider);
  return service.getAdminUser(userId);
});

/// Create admin user action
Future<void> createAdminUserAction(
  WidgetRef ref, {
  required String userId,
  required String email,
  required String displayName,
  required AdminRole role,
}) async {
  final service = ref.read(adminDashboardServiceProvider);
  await service.createAdminUser(
    userId: userId,
    email: email,
    displayName: displayName,
    role: role,
  );

  // Refresh admin users list
  ref.refresh(adminUsersProvider);
}

/// Update admin role action
Future<void> updateAdminRoleAction(
  WidgetRef ref, {
  required String userId,
  required AdminRole newRole,
}) async {
  final service = ref.read(adminDashboardServiceProvider);
  await service.updateAdminRole(
    userId: userId,
    newRole: newRole,
  );

  // Refresh
  ref.refresh(adminUsersProvider);
  ref.refresh(adminUserProvider(userId));
}

/// Deactivate admin user action
Future<void> deactivateAdminUserAction(
  WidgetRef ref, {
  required String userId,
}) async {
  final service = ref.read(adminDashboardServiceProvider);
  await service.deactivateAdminUser(userId);

  // Refresh
  ref.refresh(adminUsersProvider);
  ref.refresh(adminUserProvider(userId));
}

// ===== User Management Providers =====

/// User management statistics
final userManagementStatsProvider =
    FutureProvider<UserManagementStats?>((ref) async {
  final service = ref.watch(adminDashboardServiceProvider);
  return service.getUserManagementStats();
});

/// Inactive users (30+ days)
final inactiveUsersProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int>(
        (ref, daysInactive) async {
  final service = ref.watch(adminDashboardServiceProvider);
  return service.getInactiveUsers(daysInactive: daysInactive);
});

/// Export user data action
Future<Map<String, dynamic>?> exportUserDataAction(
  WidgetRef ref, {
  required String userId,
}) async {
  final service = ref.read(adminDashboardServiceProvider);
  return service.exportUserData(userId);
}

/// Delete user account action
Future<void> deleteUserAccountAction(
  WidgetRef ref, {
  required String userId,
}) async {
  final service = ref.read(adminDashboardServiceProvider);
  await service.deleteUserAccount(userId);

  // Refresh user stats
  ref.refresh(userManagementStatsProvider);
  ref.refresh(inactiveUsersProvider(30));
}

// ===== Moderation Providers =====

/// Active moderation actions
final activeModerationActionsProvider =
    FutureProvider<List<ModerationAction>>((ref) async {
  final service = ref.watch(adminDashboardServiceProvider);
  return service.getActiveModerationActions();
});

/// Issue moderation action
Future<void> issueModerationActionAction(
  WidgetRef ref, {
  required String userId,
  required String actionType,
  required String reason,
  required String actionBy,
  Duration? duration,
  String? notes,
}) async {
  final service = ref.read(adminDashboardServiceProvider);
  await service.issueModerationAction(
    userId: userId,
    actionType: actionType,
    reason: reason,
    actionBy: actionBy,
    duration: duration,
    notes: notes,
  );

  // Refresh moderation actions
  ref.refresh(activeModerationActionsProvider);
}

// ===== Feature Flag Providers =====

/// All feature flags
final featureFlagsProvider = FutureProvider<List<FeatureFlag>>((ref) async {
  final service = ref.watch(adminDashboardServiceProvider);
  return service.getAllFeatureFlags();
});

/// Create feature flag action
Future<void> createFeatureFlagAction(
  WidgetRef ref, {
  required String name,
  required String description,
  required bool isEnabled,
  double rolloutPercentage = 100.0,
  String? createdBy,
  Map<String, dynamic>? config,
}) async {
  final service = ref.read(adminDashboardServiceProvider);
  await service.createFeatureFlag(
    name: name,
    description: description,
    isEnabled: isEnabled,
    rolloutPercentage: rolloutPercentage,
    createdBy: createdBy,
    config: config,
  );

  // Refresh feature flags
  ref.refresh(featureFlagsProvider);
}

/// Update feature flag action
Future<void> updateFeatureFlagAction(
  WidgetRef ref, {
  required String flagId,
  required bool isEnabled,
  required double rolloutPercentage,
}) async {
  final service = ref.read(adminDashboardServiceProvider);
  await service.updateFeatureFlag(
    flagId: flagId,
    isEnabled: isEnabled,
    rolloutPercentage: rolloutPercentage,
  );

  // Refresh feature flags
  ref.refresh(featureFlagsProvider);
}

// ===== Report Providers =====

/// Recent admin reports
final adminReportsProvider = FutureProvider<List<AdminReport>>((ref) async {
  final service = ref.watch(adminDashboardServiceProvider);
  return service.getRecentReports(limit: 10);
});

/// Generate daily report action
Future<AdminReport?> generateDailyReportAction(
  WidgetRef ref, {
  required String generatedBy,
}) async {
  final service = ref.read(adminDashboardServiceProvider);
  final report = await service.generateDailyReport(
    generatedBy: generatedBy,
  );

  // Refresh reports
  ref.refresh(adminReportsProvider);

  return report;
}

// ===== Audit Log Providers =====

/// Get audit log entries
final auditLogEntriesProvider = FutureProvider.family<List<Map<String, dynamic>>, Map<String, dynamic>>(
  (ref, params) async {
    final service = ref.watch(adminDashboardServiceProvider);
    return service.getAuditLogEntries(
      adminId: params['adminId'],
      action: params['action'],
      days: params['days'] ?? 30,
      limit: params['limit'] ?? 100,
    );
  },
);

/// Get audit log stats
final auditLogStatsProvider = FutureProvider.family<Map<String, dynamic>, int>(
  (ref, days) async {
    final service = ref.watch(adminDashboardServiceProvider);
    return service.getAuditLogStats(days: days);
  },
);

/// Log admin action
Future<void> logAdminActionAction(
  WidgetRef ref, {
  required String adminId,
  required String action,
  required String description,
  String? targetId,
  Map<String, dynamic>? details,
}) async {
  final service = ref.read(adminDashboardServiceProvider);
  await service.logAdminAction(
    adminId: adminId,
    action: action,
    description: description,
    targetId: targetId,
    details: details,
  );

  // Refresh audit logs
  ref.refresh(auditLogStatsProvider(30));
}

// ===== Admin Auth Providers (Placeholder) =====

/// Current admin user (from auth)
final currentAdminProvider = FutureProvider<AdminUser?>((ref) async {
  // TODO: Get from Firebase Auth
  return null;
});

/// Admin auth check
final isAdminProvider = FutureProvider<bool>((ref) async {
  final admin = await ref.watch(currentAdminProvider.future);
  return admin != null;
});

/// Check if admin has permission
final hasAdminPermissionProvider = FutureProvider.family<bool, AdminPermission>(
  (ref, permission) async {
    final admin = await ref.watch(currentAdminProvider.future);
    return admin?.permissions.contains(permission) ?? false;
  },
);
