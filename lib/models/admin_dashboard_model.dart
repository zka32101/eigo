import 'package:cloud_firestore/cloud_firestore.dart';

/// System-wide health and status model
class SystemHealthStatus {
  final DateTime timestamp;
  final double systemHealth; // 0-100%
  final bool isHealthy; // > 80%

  // Component health
  final double firestoreHealth;
  final double authHealth;
  final double analyticsHealth;

  // Metrics
  final int activeUsers;
  final int totalUsers;
  final double avgEngagement;
  final int eventsPerHour;
  final double avgResponseTime; // ms

  // Alerts
  final List<SystemAlert> activeAlerts;
  final List<String> warnings;

  SystemHealthStatus({
    required this.timestamp,
    required this.systemHealth,
    required this.isHealthy,
    required this.firestoreHealth,
    required this.authHealth,
    required this.analyticsHealth,
    required this.activeUsers,
    required this.totalUsers,
    required this.avgEngagement,
    required this.eventsPerHour,
    required this.avgResponseTime,
    required this.activeAlerts,
    required this.warnings,
  });

  factory SystemHealthStatus.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SystemHealthStatus(
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      systemHealth: (data['systemHealth'] ?? 0.0).toDouble(),
      isHealthy: data['isHealthy'] ?? false,
      firestoreHealth: (data['firestoreHealth'] ?? 0.0).toDouble(),
      authHealth: (data['authHealth'] ?? 0.0).toDouble(),
      analyticsHealth: (data['analyticsHealth'] ?? 0.0).toDouble(),
      activeUsers: data['activeUsers'] ?? 0,
      totalUsers: data['totalUsers'] ?? 0,
      avgEngagement: (data['avgEngagement'] ?? 0.0).toDouble(),
      eventsPerHour: data['eventsPerHour'] ?? 0,
      avgResponseTime: (data['avgResponseTime'] ?? 0.0).toDouble(),
      activeAlerts: (data['activeAlerts'] as List?)
              ?.map((a) => SystemAlert.fromMap(a))
              .toList() ??
          [],
      warnings: List<String>.from(data['warnings'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'timestamp': Timestamp.fromDate(timestamp),
    'systemHealth': systemHealth,
    'isHealthy': isHealthy,
    'firestoreHealth': firestoreHealth,
    'authHealth': authHealth,
    'analyticsHealth': analyticsHealth,
    'activeUsers': activeUsers,
    'totalUsers': totalUsers,
    'avgEngagement': avgEngagement,
    'eventsPerHour': eventsPerHour,
    'avgResponseTime': avgResponseTime,
    'activeAlerts': activeAlerts.map((a) => a.toMap()).toList(),
    'warnings': warnings,
  };
}

/// System alert model
class SystemAlert {
  final String id;
  final String title;
  final String description;
  final AlertSeverity severity; // critical, warning, info
  final DateTime createdAt;
  final bool isResolved;
  final String? resolvedBy;
  final DateTime? resolvedAt;

  SystemAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.createdAt,
    required this.isResolved,
    this.resolvedBy,
    this.resolvedAt,
  });

  factory SystemAlert.fromMap(Map<String, dynamic> data) {
    return SystemAlert(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      severity: AlertSeverity.values.firstWhere(
        (e) => e.toString().split('.').last == data['severity'],
        orElse: () => AlertSeverity.info,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isResolved: data['isResolved'] ?? false,
      resolvedBy: data['resolvedBy'],
      resolvedAt: (data['resolvedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'severity': severity.toString().split('.').last,
    'createdAt': Timestamp.fromDate(createdAt),
    'isResolved': isResolved,
    'resolvedBy': resolvedBy,
    'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
  };
}

enum AlertSeverity { critical, warning, info }

/// Admin user model
class AdminUser {
  final String userId;
  final String email;
  final String displayName;
  final AdminRole role;
  final List<AdminPermission> permissions;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;

  AdminUser({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.role,
    required this.permissions,
    required this.createdAt,
    this.lastLoginAt,
    required this.isActive,
  });

  factory AdminUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminUser(
      userId: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      role: AdminRole.values.firstWhere(
        (e) => e.toString().split('.').last == data['role'],
        orElse: () => AdminRole.viewer,
      ),
      permissions: (data['permissions'] as List?)
              ?.map((p) => AdminPermission.values.firstWhere(
                    (e) => e.toString().split('.').last == p,
                    orElse: () => AdminPermission.view,
                  ))
              .toList() ??
          [],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'email': email,
    'displayName': displayName,
    'role': role.toString().split('.').last,
    'permissions': permissions.map((p) => p.toString().split('.').last).toList(),
    'createdAt': Timestamp.fromDate(createdAt),
    'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
    'isActive': isActive,
  };
}

enum AdminRole {
  superAdmin, // Full access
  admin, // Most features
  moderator, // Moderation only
  analyst, // Analytics only
  viewer, // Read-only
}

enum AdminPermission {
  view, // View dashboards
  editUsers, // Manage users
  editContent, // Modify game content
  editSettings, // Change system settings
  viewAnalytics, // Access analytics
  manageAlerts, // Handle system alerts
  exportData, // Export game data
  deleteData, // Permanently delete data
  viewLogs, // Access system logs
}

/// Report generation model
class AdminReport {
  final String id;
  final String title;
  final ReportType type;
  final DateTime generatedAt;
  final DateTime? startDate;
  final DateTime? endDate;
  final Map<String, dynamic> data;
  final String? generatedBy;

  AdminReport({
    required this.id,
    required this.title,
    required this.type,
    required this.generatedAt,
    this.startDate,
    this.endDate,
    required this.data,
    this.generatedBy,
  });

  factory AdminReport.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminReport(
      id: doc.id,
      title: data['title'] ?? '',
      type: ReportType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => ReportType.dailySummary,
      ),
      generatedAt: (data['generatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startDate: (data['startDate'] as Timestamp?)?.toDate(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      data: data['data'] ?? {},
      generatedBy: data['generatedBy'],
    );
  }

  Map<String, dynamic> toFirestore() => {
    'title': title,
    'type': type.toString().split('.').last,
    'generatedAt': Timestamp.fromDate(generatedAt),
    'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
    'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
    'data': data,
    'generatedBy': generatedBy,
  };
}

enum ReportType {
  dailySummary,
  weeklySummary,
  monthlySummary,
  userAnalysis,
  engagementReport,
  retentionAnalysis,
  revenueReport,
  churnAnalysis,
  customReport,
}

/// User management stats model
class UserManagementStats {
  final int totalUsers;
  final int activeUsers;
  final int inactiveUsers;
  final int churned; // 30+ days inactive
  final int newThisWeek;
  final int newThisMonth;

  // Engagement distribution
  final int highEngagement;
  final int mediumEngagement;
  final int lowEngagement;

  // Level distribution
  final Map<int, int> usersPerLevel; // level -> count
  final double averageLevel;

  // Activity metrics
  final double avgSessionsPerUser;
  final double avgPlayTimePerUser; // minutes
  final double conversionRate; // % of users making purchase

  UserManagementStats({
    required this.totalUsers,
    required this.activeUsers,
    required this.inactiveUsers,
    required this.churned,
    required this.newThisWeek,
    required this.newThisMonth,
    required this.highEngagement,
    required this.mediumEngagement,
    required this.lowEngagement,
    required this.usersPerLevel,
    required this.averageLevel,
    required this.avgSessionsPerUser,
    required this.avgPlayTimePerUser,
    required this.conversionRate,
  });

  factory UserManagementStats.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserManagementStats(
      totalUsers: data['totalUsers'] ?? 0,
      activeUsers: data['activeUsers'] ?? 0,
      inactiveUsers: data['inactiveUsers'] ?? 0,
      churned: data['churned'] ?? 0,
      newThisWeek: data['newThisWeek'] ?? 0,
      newThisMonth: data['newThisMonth'] ?? 0,
      highEngagement: data['highEngagement'] ?? 0,
      mediumEngagement: data['mediumEngagement'] ?? 0,
      lowEngagement: data['lowEngagement'] ?? 0,
      usersPerLevel: Map<int, int>.from(data['usersPerLevel'] ?? {}),
      averageLevel: (data['averageLevel'] ?? 0.0).toDouble(),
      avgSessionsPerUser: (data['avgSessionsPerUser'] ?? 0.0).toDouble(),
      avgPlayTimePerUser: (data['avgPlayTimePerUser'] ?? 0.0).toDouble(),
      conversionRate: (data['conversionRate'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'totalUsers': totalUsers,
    'activeUsers': activeUsers,
    'inactiveUsers': inactiveUsers,
    'churned': churned,
    'newThisWeek': newThisWeek,
    'newThisMonth': newThisMonth,
    'highEngagement': highEngagement,
    'mediumEngagement': mediumEngagement,
    'lowEngagement': lowEngagement,
    'usersPerLevel': usersPerLevel,
    'averageLevel': averageLevel,
    'avgSessionsPerUser': avgSessionsPerUser,
    'avgPlayTimePerUser': avgPlayTimePerUser,
    'conversionRate': conversionRate,
  };
}

/// Content moderation model
class ModerationAction {
  final String id;
  final String userId;
  final String actionType; // warning, mute, ban, unban
  final String reason;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String? actionBy;
  final String? notes;

  ModerationAction({
    required this.id,
    required this.userId,
    required this.actionType,
    required this.reason,
    required this.createdAt,
    this.expiresAt,
    this.actionBy,
    this.notes,
  });

  factory ModerationAction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ModerationAction(
      id: doc.id,
      userId: data['userId'] ?? '',
      actionType: data['actionType'] ?? '',
      reason: data['reason'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
      actionBy: data['actionBy'],
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'actionType': actionType,
    'reason': reason,
    'createdAt': Timestamp.fromDate(createdAt),
    'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
    'actionBy': actionBy,
    'notes': notes,
  };
}

/// Feature flag model for A/B testing and feature control
class FeatureFlag {
  final String id;
  final String name;
  final String description;
  final bool isEnabled;
  final double rolloutPercentage; // 0-100%
  final List<String> targetUserIds; // Empty = all users
  final DateTime createdAt;
  final DateTime? modifiedAt;
  final String? createdBy;
  final Map<String, dynamic> config; // Feature-specific config

  FeatureFlag({
    required this.id,
    required this.name,
    required this.description,
    required this.isEnabled,
    required this.rolloutPercentage,
    required this.targetUserIds,
    required this.createdAt,
    this.modifiedAt,
    this.createdBy,
    required this.config,
  });

  factory FeatureFlag.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FeatureFlag(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      isEnabled: data['isEnabled'] ?? false,
      rolloutPercentage: (data['rolloutPercentage'] ?? 0.0).toDouble(),
      targetUserIds: List<String>.from(data['targetUserIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      modifiedAt: (data['modifiedAt'] as Timestamp?)?.toDate(),
      createdBy: data['createdBy'],
      config: data['config'] ?? {},
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'description': description,
    'isEnabled': isEnabled,
    'rolloutPercentage': rolloutPercentage,
    'targetUserIds': targetUserIds,
    'createdAt': Timestamp.fromDate(createdAt),
    'modifiedAt': modifiedAt != null ? Timestamp.fromDate(modifiedAt!) : null,
    'createdBy': createdBy,
    'config': config,
  };
}
