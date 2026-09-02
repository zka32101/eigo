import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_dashboard_model.dart';

/// Service for admin dashboard operations and system management
class AdminDashboardService {
  static final AdminDashboardService _instance =
      AdminDashboardService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory AdminDashboardService() {
    return _instance;
  }

  AdminDashboardService._internal();

  // ===== System Health Methods =====

  /// Get current system health status
  Future<SystemHealthStatus?> getSystemHealth() async {
    try {
      final doc = await _firestore
          .collection('admin')
          .doc('systemHealth')
          .get();

      if (!doc.exists) return null;
      return SystemHealthStatus.fromFirestore(doc);
    } catch (e) {
      print('[AdminService] Error getting system health: $e');
      return null;
    }
  }

  /// Get system health history
  Future<List<SystemHealthStatus>> getSystemHealthHistory({
    required int days,
  }) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));
      final snapshot = await _firestore
          .collection('admin')
          .doc('systemHealth')
          .collection('history')
          .where('timestamp', isGreaterThanOrEqualTo: startDate)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => SystemHealthStatus.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('[AdminService] Error getting health history: $e');
      return [];
    }
  }

  /// Record system alert
  Future<void> createAlert({
    required String title,
    required String description,
    required AlertSeverity severity,
  }) async {
    try {
      final alertId = _firestore.collection('admin').doc().id;
      final alert = SystemAlert(
        id: alertId,
        title: title,
        description: description,
        severity: severity,
        createdAt: DateTime.now(),
        isResolved: false,
      );

      await _firestore
          .collection('admin')
          .doc('alerts')
          .collection('list')
          .doc(alertId)
          .set(alert.toMap());

      print('[AdminService] Alert created: $title');
    } catch (e) {
      print('[AdminService] Error creating alert: $e');
    }
  }

  /// Get active alerts
  Future<List<SystemAlert>> getActiveAlerts() async {
    try {
      final snapshot = await _firestore
          .collection('admin')
          .doc('alerts')
          .collection('list')
          .where('isResolved', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => SystemAlert.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('[AdminService] Error getting alerts: $e');
      return [];
    }
  }

  /// Resolve alert
  Future<void> resolveAlert({
    required String alertId,
    required String resolvedBy,
  }) async {
    try {
      await _firestore
          .collection('admin')
          .doc('alerts')
          .collection('list')
          .doc(alertId)
          .update({
            'isResolved': true,
            'resolvedBy': resolvedBy,
            'resolvedAt': Timestamp.now(),
          });

      print('[AdminService] Alert resolved: $alertId');
    } catch (e) {
      print('[AdminService] Error resolving alert: $e');
    }
  }

  // ===== Admin User Management =====

  /// Get all admin users
  Future<List<AdminUser>> getAllAdminUsers() async {
    try {
      final snapshot = await _firestore
          .collection('adminUsers')
          .get();

      return snapshot.docs
          .map((doc) => AdminUser.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('[AdminService] Error getting admin users: $e');
      return [];
    }
  }

  /// Get admin user by ID
  Future<AdminUser?> getAdminUser(String userId) async {
    try {
      final doc = await _firestore
          .collection('adminUsers')
          .doc(userId)
          .get();

      if (!doc.exists) return null;
      return AdminUser.fromFirestore(doc);
    } catch (e) {
      print('[AdminService] Error getting admin user: $e');
      return null;
    }
  }

  /// Create new admin user
  Future<void> createAdminUser({
    required String userId,
    required String email,
    required String displayName,
    required AdminRole role,
  }) async {
    try {
      final permissions = _getPermissionsForRole(role);
      final adminUser = AdminUser(
        userId: userId,
        email: email,
        displayName: displayName,
        role: role,
        permissions: permissions,
        createdAt: DateTime.now(),
        isActive: true,
      );

      await _firestore
          .collection('adminUsers')
          .doc(userId)
          .set(adminUser.toFirestore());

      print('[AdminService] Admin user created: $userId - $role');
    } catch (e) {
      print('[AdminService] Error creating admin user: $e');
    }
  }

  /// Update admin role
  Future<void> updateAdminRole({
    required String userId,
    required AdminRole newRole,
  }) async {
    try {
      final permissions = _getPermissionsForRole(newRole);
      await _firestore
          .collection('adminUsers')
          .doc(userId)
          .update({
            'role': newRole.toString().split('.').last,
            'permissions': permissions
                .map((p) => p.toString().split('.').last)
                .toList(),
          });

      print('[AdminService] Admin role updated: $userId -> $newRole');
    } catch (e) {
      print('[AdminService] Error updating admin role: $e');
    }
  }

  /// Deactivate admin user
  Future<void> deactivateAdminUser(String userId) async {
    try {
      await _firestore
          .collection('adminUsers')
          .doc(userId)
          .update({'isActive': false});

      print('[AdminService] Admin user deactivated: $userId');
    } catch (e) {
      print('[AdminService] Error deactivating admin user: $e');
    }
  }

  /// Helper: Get permissions for role
  List<AdminPermission> _getPermissionsForRole(AdminRole role) {
    switch (role) {
      case AdminRole.superAdmin:
        return AdminPermission.values;
      case AdminRole.admin:
        return [
          AdminPermission.view,
          AdminPermission.editUsers,
          AdminPermission.editContent,
          AdminPermission.viewAnalytics,
          AdminPermission.manageAlerts,
          AdminPermission.exportData,
          AdminPermission.viewLogs,
        ];
      case AdminRole.moderator:
        return [
          AdminPermission.view,
          AdminPermission.editUsers,
          AdminPermission.manageAlerts,
        ];
      case AdminRole.analyst:
        return [
          AdminPermission.view,
          AdminPermission.viewAnalytics,
          AdminPermission.exportData,
        ];
      case AdminRole.viewer:
        return [AdminPermission.view];
    }
  }

  // ===== User Management =====

  /// Get user management statistics
  Future<UserManagementStats?> getUserManagementStats() async {
    try {
      final doc = await _firestore
          .collection('admin')
          .doc('userStats')
          .get();

      if (!doc.exists) return null;
      return UserManagementStats.fromFirestore(doc);
    } catch (e) {
      print('[AdminService] Error getting user stats: $e');
      return null;
    }
  }

  /// Get inactive users (30+ days)
  Future<List<Map<String, dynamic>>> getInactiveUsers({
    int daysInactive = 30,
  }) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysInactive));
      final snapshot = await _firestore
          .collection('users')
          .where('lastActiveAt', isLessThan: cutoffDate)
          .limit(100)
          .get();

      return snapshot.docs
          .map((doc) => {'userId': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print('[AdminService] Error getting inactive users: $e');
      return [];
    }
  }

  /// Export user data
  Future<Map<String, dynamic>?> exportUserData(String userId) async {
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) return null;

      final userData = userDoc.data() as Map<String, dynamic>;
      return {...userData, 'exportedAt': DateTime.now().toIso8601String()};
    } catch (e) {
      print('[AdminService] Error exporting user data: $e');
      return null;
    }
  }

  /// Delete user account (hard delete)
  Future<void> deleteUserAccount(String userId) async {
    try {
      // Delete user document
      await _firestore
          .collection('users')
          .doc(userId)
          .delete();

      // TODO: Delete user data from other collections
      // - achievements/{userId}
      // - leaderboard entries
      // - analytics events
      // - social data
      // - etc.

      print('[AdminService] User account deleted: $userId');
    } catch (e) {
      print('[AdminService] Error deleting user account: $e');
    }
  }

  // ===== Moderation =====

  /// Get active moderation actions
  Future<List<ModerationAction>> getActiveModerationActions() async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection('moderation')
          .doc('actions')
          .collection('list')
          .where('expiresAt', isGreaterThan: now)
          .orderBy('expiresAt')
          .get();

      return snapshot.docs
          .map((doc) => ModerationAction.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('[AdminService] Error getting moderation actions: $e');
      return [];
    }
  }

  /// Issue moderation action
  Future<void> issueModerationAction({
    required String userId,
    required String actionType,
    required String reason,
    required String actionBy,
    Duration? duration,
    String? notes,
  }) async {
    try {
      final actionId = _firestore.collection('moderation').doc().id;
      final action = ModerationAction(
        id: actionId,
        userId: userId,
        actionType: actionType,
        reason: reason,
        createdAt: DateTime.now(),
        expiresAt: duration != null
            ? DateTime.now().add(duration)
            : null,
        actionBy: actionBy,
        notes: notes,
      );

      await _firestore
          .collection('moderation')
          .doc('actions')
          .collection('list')
          .doc(actionId)
          .set(action.toFirestore());

      print('[AdminService] Moderation action issued: $userId - $actionType');
    } catch (e) {
      print('[AdminService] Error issuing moderation action: $e');
    }
  }

  // ===== Feature Flags =====

  /// Get all feature flags
  Future<List<FeatureFlag>> getAllFeatureFlags() async {
    try {
      final snapshot = await _firestore
          .collection('admin')
          .doc('features')
          .collection('flags')
          .get();

      return snapshot.docs
          .map((doc) => FeatureFlag.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('[AdminService] Error getting feature flags: $e');
      return [];
    }
  }

  /// Create feature flag
  Future<void> createFeatureFlag({
    required String name,
    required String description,
    required bool isEnabled,
    double rolloutPercentage = 100.0,
    String? createdBy,
    Map<String, dynamic>? config,
  }) async {
    try {
      final flagId = _firestore
          .collection('admin')
          .doc('features')
          .collection('flags')
          .doc()
          .id;

      final flag = FeatureFlag(
        id: flagId,
        name: name,
        description: description,
        isEnabled: isEnabled,
        rolloutPercentage: rolloutPercentage,
        targetUserIds: [],
        createdAt: DateTime.now(),
        createdBy: createdBy,
        config: config ?? {},
      );

      await _firestore
          .collection('admin')
          .doc('features')
          .collection('flags')
          .doc(flagId)
          .set(flag.toFirestore());

      print('[AdminService] Feature flag created: $name');
    } catch (e) {
      print('[AdminService] Error creating feature flag: $e');
    }
  }

  /// Update feature flag
  Future<void> updateFeatureFlag({
    required String flagId,
    required bool isEnabled,
    required double rolloutPercentage,
  }) async {
    try {
      await _firestore
          .collection('admin')
          .doc('features')
          .collection('flags')
          .doc(flagId)
          .update({
            'isEnabled': isEnabled,
            'rolloutPercentage': rolloutPercentage,
            'modifiedAt': Timestamp.now(),
          });

      print('[AdminService] Feature flag updated: $flagId');
    } catch (e) {
      print('[AdminService] Error updating feature flag: $e');
    }
  }

  // ===== Reports =====

  /// Generate daily report
  Future<AdminReport?> generateDailyReport({
    required String generatedBy,
  }) async {
    try {
      // TODO: Aggregate daily metrics
      final report = AdminReport(
        id: _firestore.collection('admin').doc().id,
        title: 'Daily Report - ${DateTime.now().toDateString()}',
        type: ReportType.dailySummary,
        generatedAt: DateTime.now(),
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now(),
        data: {}, // Populated by aggregation
        generatedBy: generatedBy,
      );

      await _firestore
          .collection('admin')
          .doc('reports')
          .collection('list')
          .doc(report.id)
          .set(report.toFirestore());

      print('[AdminService] Daily report generated');
      return report;
    } catch (e) {
      print('[AdminService] Error generating daily report: $e');
      return null;
    }
  }

  /// Get recent reports
  Future<List<AdminReport>> getRecentReports({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('admin')
          .doc('reports')
          .collection('list')
          .orderBy('generatedAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => AdminReport.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('[AdminService] Error getting reports: $e');
      return [];
    }
  }

  // ===== Audit Logging =====

  /// Log admin action for audit trail
  Future<void> logAdminAction({
    required String adminId,
    required String action,
    required String description,
    String? targetId,
    Map<String, dynamic>? details,
  }) async {
    try {
      final logEntry = {
        'adminId': adminId,
        'action': action,
        'description': description,
        'targetId': targetId,
        'details': details ?? {},
        'timestamp': Timestamp.now(),
        'ipAddress': 'unknown', // TODO: Get from request
      };

      await _firestore
          .collection('admin')
          .doc('auditLog')
          .collection('entries')
          .add(logEntry);

      print('[AdminService] Audit log entry created: $action by $adminId');
    } catch (e) {
      print('[AdminService] Error logging admin action: $e');
    }
  }

  /// Get audit log entries
  Future<List<Map<String, dynamic>>> getAuditLogEntries({
    String? adminId,
    String? action,
    int days = 30,
    int limit = 100,
  }) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));
      var query = _firestore
          .collection('admin')
          .doc('auditLog')
          .collection('entries')
          .where('timestamp', isGreaterThanOrEqualTo: startDate) as Query;

      if (adminId != null) {
        query = query.where('adminId', isEqualTo: adminId);
      }

      if (action != null) {
        query = query.where('action', isEqualTo: action);
      }

      final snapshot = await query
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('[AdminService] Error getting audit log: $e');
      return [];
    }
  }

  /// Get audit log stats
  Future<Map<String, dynamic>> getAuditLogStats({int days = 30}) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));
      final snapshot = await _firestore
          .collection('admin')
          .doc('auditLog')
          .collection('entries')
          .where('timestamp', isGreaterThanOrEqualTo: startDate)
          .get();

      final entries = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      // Count actions by type
      final actionCounts = <String, int>{};
      final adminCounts = <String, int>{};

      for (final entry in entries) {
        final action = entry['action'] as String?;
        final adminId = entry['adminId'] as String?;

        if (action != null) {
          actionCounts[action] = (actionCounts[action] ?? 0) + 1;
        }
        if (adminId != null) {
          adminCounts[adminId] = (adminCounts[adminId] ?? 0) + 1;
        }
      }

      return {
        'totalActions': entries.length,
        'actionCounts': actionCounts,
        'adminCounts': adminCounts,
        'period': 'last_$days days',
      };
    } catch (e) {
      print('[AdminService] Error getting audit log stats: $e');
      return {};
    }
  }
}

extension on DateTime {
  String toDateString() => '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}

/// Provider for admin dashboard service
final adminDashboardServiceProvider =
    Provider<AdminDashboardService>((ref) {
  return AdminDashboardService();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
