# Phase 11: Admin Dashboard & Reporting System

## Overview

Phase 11 implements a comprehensive admin dashboard for system management, user administration, content moderation, and advanced reporting. This provides administrators and moderators with complete visibility and control over the game system.

### Phase 11 Completion Status
- **Part 1**: ✅ Admin Dashboard Infrastructure (services, models, providers)
- **Part 2**: ✅ Admin Dashboard UI Screens (system overview, user management, moderation, reports)
- **Part 3**: ✅ Advanced Admin Features (feature flags, audit logging)

## Architecture

### Core Components

#### 1. **System Health Module**
Monitors system-wide health and performance metrics.

```dart
class SystemHealthStatus {
  final double systemHealth; // 0-100%
  final bool isHealthy; // > 80%
  
  // Component health
  final double firestoreHealth;
  final double authHealth;
  final double analyticsHealth;
  
  // Metrics
  final int activeUsers;
  final double avgEngagement;
  final int eventsPerHour;
  final double avgResponseTime;
  
  // Alerts
  final List<SystemAlert> activeAlerts;
}
```

**Key Metrics:**
- System overall health score (0-100%)
- Component-specific health (Firestore, Auth, Analytics)
- Active user count and engagement
- Event throughput per hour
- Response time tracking
- Active system alerts

#### 2. **System Alerts Module**
Real-time alert system for critical events.

```dart
class SystemAlert {
  final String id;
  final String title;
  final String description;
  final AlertSeverity severity; // critical, warning, info
  final DateTime createdAt;
  final bool isResolved;
  final String? resolvedBy;
}
```

**Alert Types:**
- Critical: System failures, security issues
- Warning: Performance degradation, quota limits
- Info: General notifications

#### 3. **Admin User Management Module**
Role-based access control with granular permissions.

```dart
class AdminUser {
  final String userId;
  final String email;
  final String displayName;
  final AdminRole role; // superAdmin, admin, moderator, analyst, viewer
  final List<AdminPermission> permissions;
}
```

**Admin Roles:**
- **SuperAdmin**: Full access to all features
- **Admin**: Most features except critical settings
- **Moderator**: User moderation and management only
- **Analyst**: Analytics and reporting only
- **Viewer**: Read-only access

**Admin Permissions (8):**
1. `view` - View dashboards
2. `editUsers` - Manage users
3. `editContent` - Modify game content
4. `editSettings` - Change system settings
5. `viewAnalytics` - Access analytics
6. `manageAlerts` - Handle system alerts
7. `exportData` - Export game data
8. `deleteData` - Permanently delete data

#### 4. **User Management Module**
Complete user administration and lifecycle management.

```dart
class UserManagementStats {
  final int totalUsers;
  final int activeUsers;
  final int inactiveUsers;
  final int churned; // 30+ days inactive
  
  // Engagement distribution
  final int highEngagement;
  final int mediumEngagement;
  final int lowEngagement;
  
  // Activity metrics
  final double avgSessionsPerUser;
  final double avgPlayTimePerUser;
  final double conversionRate; // purchase rate
}
```

**User Management Features:**
- View all users with detailed stats
- Identify inactive users (30+ days)
- Export user data
- Hard delete user accounts
- Track engagement distribution
- Monitor conversion rates

#### 5. **Moderation Module**
Content and behavior moderation system.

```dart
class ModerationAction {
  final String userId;
  final String actionType; // warning, mute, ban, unban
  final String reason;
  final DateTime? expiresAt;
  final String? actionBy;
}
```

**Moderation Actions:**
- **Warning**: Inform user of violation
- **Mute**: Disable social features (temporary or permanent)
- **Ban**: Disable account access (temporary or permanent)
- **Unban**: Restore access

#### 6. **Feature Flags Module**
A/B testing and feature rollout control.

```dart
class FeatureFlag {
  final String name;
  final String description;
  final bool isEnabled;
  final double rolloutPercentage; // 0-100%
  final List<String> targetUserIds; // Empty = all
  final Map<String, dynamic> config;
}
```

**Feature Flag Features:**
- Enable/disable features globally
- Gradual rollout (0-100%)
- Target specific users
- Feature-specific configuration
- Track feature usage

#### 7. **Reporting Module**
Advanced reporting and data analysis.

```dart
class AdminReport {
  final String title;
  final ReportType type;
  final DateTime generatedAt;
  final Map<String, dynamic> data;
}
```

**Report Types:**
- Daily Summary
- Weekly Summary
- Monthly Summary
- User Analysis
- Engagement Report
- Retention Analysis
- Revenue Report
- Churn Analysis
- Custom Report

## Services

### AdminDashboardService

Core service managing all admin operations.

**System Health Methods:**
```dart
getSystemHealth() -> SystemHealthStatus
getSystemHealthHistory(days: int) -> List<SystemHealthStatus>
createAlert(title, description, severity)
getActiveAlerts() -> List<SystemAlert>
resolveAlert(alertId, resolvedBy)
```

**Admin User Methods:**
```dart
getAllAdminUsers() -> List<AdminUser>
getAdminUser(userId) -> AdminUser?
createAdminUser(userId, email, displayName, role)
updateAdminRole(userId, newRole)
deactivateAdminUser(userId)
```

**User Management Methods:**
```dart
getUserManagementStats() -> UserManagementStats
getInactiveUsers(daysInactive: int) -> List<User>
exportUserData(userId) -> Map<String, dynamic>
deleteUserAccount(userId)
```

**Moderation Methods:**
```dart
getActiveModerationActions() -> List<ModerationAction>
issueModerationAction(userId, actionType, reason, actionBy, duration)
```

**Feature Flag Methods:**
```dart
getAllFeatureFlags() -> List<FeatureFlag>
createFeatureFlag(name, description, isEnabled, rolloutPercentage)
updateFeatureFlag(flagId, isEnabled, rolloutPercentage)
```

**Report Methods:**
```dart
generateDailyReport(generatedBy) -> AdminReport
getRecentReports(limit: int) -> List<AdminReport>
```

## Providers

All data access is managed through Riverpod providers.

**System Health Providers:**
- `systemHealthProvider` - Current system health
- `systemHealthHistoryProvider(days)` - Historical data
- `activeAlertsProvider` - Active system alerts

**Admin User Providers:**
- `adminUsersProvider` - All admin users
- `adminUserProvider(userId)` - Single admin user
- `currentAdminProvider` - Logged-in admin user
- `isAdminProvider` - Admin auth check
- `hasAdminPermissionProvider(permission)` - Permission check

**User Management Providers:**
- `userManagementStatsProvider` - User statistics
- `inactiveUsersProvider(days)` - Inactive users
- `activeModerationActionsProvider` - Active moderation

**Feature Flags Providers:**
- `featureFlagsProvider` - All feature flags

**Reports Providers:**
- `adminReportsProvider` - Recent reports

## Action Functions

Convenient helper functions for common operations.

```dart
// Alerts
await createSystemAlert(ref, title, description, severity);
await resolveSystemAlert(ref, alertId, resolvedBy);

// Admin Users
await createAdminUserAction(ref, userId, email, displayName, role);
await updateAdminRoleAction(ref, userId, newRole);
await deactivateAdminUserAction(ref, userId);

// User Management
await deleteUserAccountAction(ref, userId);
await exportUserDataAction(ref, userId);

// Moderation
await issueModerationActionAction(
  ref,
  userId: userId,
  actionType: actionType,
  reason: reason,
  actionBy: actionBy,
  duration: duration,
);

// Feature Flags
await createFeatureFlagAction(ref, name, description, isEnabled);
await updateFeatureFlagAction(ref, flagId, isEnabled, rolloutPercentage);

// Reports
await generateDailyReportAction(ref, generatedBy);
```

## Firestore Schema

```
admin/
├── systemHealth
│   ├─ timestamp: Timestamp
│   ├─ systemHealth: double
│   ├─ isHealthy: boolean
│   ├─ firestoreHealth: double
│   ├─ authHealth: double
│   ├─ analyticsHealth: double
│   ├─ activeUsers: int
│   ├─ totalUsers: int
│   ├─ avgEngagement: double
│   ├─ eventsPerHour: int
│   ├─ avgResponseTime: double
│   ├─ activeAlerts: array
│   └─ warnings: array
│
├── alerts/list/{alertId}
│   ├─ title: string
│   ├─ description: string
│   ├─ severity: string (critical|warning|info)
│   ├─ createdAt: Timestamp
│   ├─ isResolved: boolean
│   ├─ resolvedBy: string
│   └─ resolvedAt: Timestamp
│
├── userStats
│   ├─ totalUsers: int
│   ├─ activeUsers: int
│   ├─ inactiveUsers: int
│   ├─ churned: int
│   ├─ newThisWeek: int
│   ├─ newThisMonth: int
│   ├─ highEngagement: int
│   ├─ mediumEngagement: int
│   ├─ lowEngagement: int
│   ├─ usersPerLevel: map
│   ├─ averageLevel: double
│   ├─ avgSessionsPerUser: double
│   ├─ avgPlayTimePerUser: double
│   └─ conversionRate: double
│
├── features/flags/{flagId}
│   ├─ name: string
│   ├─ description: string
│   ├─ isEnabled: boolean
│   ├─ rolloutPercentage: double
│   ├─ targetUserIds: array
│   ├─ createdAt: Timestamp
│   ├─ modifiedAt: Timestamp
│   ├─ createdBy: string
│   └─ config: map
│
└── reports/list/{reportId}
    ├─ title: string
    ├─ type: string
    ├─ generatedAt: Timestamp
    ├─ startDate: Timestamp
    ├─ endDate: Timestamp
    ├─ data: map
    └─ generatedBy: string

adminUsers/{userId}
├─ email: string
├─ displayName: string
├─ role: string (superAdmin|admin|moderator|analyst|viewer)
├─ permissions: array
├─ createdAt: Timestamp
├─ lastLoginAt: Timestamp
└─ isActive: boolean

moderation/actions/list/{actionId}
├─ userId: string
├─ actionType: string (warning|mute|ban|unban)
├─ reason: string
├─ createdAt: Timestamp
├─ expiresAt: Timestamp
├─ actionBy: string
└─ notes: string
```

## Security Considerations

### Role-Based Access Control
- All operations verify admin role
- Permissions are granular and explicit
- Super Admin required for critical operations

### Audit Logging
- All admin actions logged to `admin/auditLog`
- Track: who, what, when, why
- Retain for 1 year minimum

### Data Protection
- User data exports are logged
- Hard deletes require confirmation
- Sensitive fields are masked

## Performance Characteristics

### Query Performance
- System health: < 100ms
- Admin users list: < 200ms
- User stats: < 500ms
- Moderation actions: < 300ms
- Feature flags: < 100ms

### Batch Operations
- User deletion: < 5s per user (includes cleanup)
- Bulk moderation: < 100ms per action
- Report generation: < 2s for daily

## Testing Checklist

- [ ] System health calculation
- [ ] Alert creation and resolution
- [ ] Admin user CRUD operations
- [ ] Role-based access control
- [ ] User statistics aggregation
- [ ] Inactive user identification
- [ ] User data export
- [ ] User account deletion
- [ ] Moderation action lifecycle
- [ ] Feature flag creation/updates
- [ ] Report generation
- [ ] Permission verification
- [ ] Audit logging
- [ ] Data retention policies

## Future Enhancements

1. **Advanced Analytics**
   - User cohort analysis
   - LTV prediction
   - Churn prediction models

2. **Automation**
   - Automatic churn detection
   - Scheduled reports
   - Batch moderation actions

3. **Integration**
   - Slack notifications
   - Email alerts
   - Third-party analytics

4. **Analytics Deep-Dive**
   - Custom report builder
   - Data export formats
   - Visualization tools

5. **Advanced Moderation**
   - AI content detection
   - Automatic action triggers
   - Appeal system

## Configuration

### Default Settings
- System health check interval: 5 minutes
- Alert retention: 90 days
- Moderation action default duration: 7 days
- Report retention: 1 year
- Audit log retention: 1 year

### Thresholds
- Inactive threshold: 30 days
- System health warning: < 80%
- High alert: < 70%
- Critical alert: < 50%

## Part 3: Advanced Admin Features

### Feature Flags Management Screen
Complete UI for managing A/B testing and feature rollout.

**Components:**
- Feature flags list view
- Create new flag dialog
- Edit flag dialog  
- Rollout percentage slider (0-100%)
- Target user management
- Flag status indicators (enabled/disabled)

**Features:**
- Visual rollout progress indicators
- Quick enable/disable toggles
- Granular control over rollout percentage
- Delete flags with confirmation

### Audit Logging System
Comprehensive tracking of all admin actions for compliance and security.

**Audit Log Features:**
- Track all admin actions with metadata
- Log action type, description, target, timestamp
- Filter by admin user or action type
- View historical logs (30, 60, 90 days)
- Export audit logs
- Audit statistics dashboard

**Tracked Actions:**
- User management (create, delete, export)
- Settings modifications
- Moderation actions
- Feature flag changes
- Content edits
- Admin role updates

**Audit Log Fields:**
- `adminId` - Who performed the action
- `action` - Action type (createUser, deleteUser, editSettings, etc.)
- `description` - Human-readable description
- `targetId` - Affected user/resource ID
- `details` - Additional metadata as JSON
- `timestamp` - When the action occurred
- `ipAddress` - Source IP (for future use)

### Main Admin Dashboard
Central navigation hub for all admin features.

**Screens:**
1. System Overview - Dashboard with health metrics
2. User Management - User stats and inactive user management
3. Moderation Panel - Manage user moderation actions
4. Reports Dashboard - Generate and view reports
5. Feature Flags - A/B testing and rollout management
6. Audit Log - Track all admin actions

**Navigation:**
- Sidebar navigation for desktop/tablet
- Drawer navigation support for mobile
- TabBar integration for related features

## Audit Logging Service Methods

```dart
// Log an admin action
await logAdminAction(
  adminId: 'admin_1',
  action: 'deleteUser',
  description: 'User account deleted',
  targetId: 'user_123',
  details: {'reason': 'policy violation'},
);

// Get audit log entries
final entries = await getAuditLogEntries(
  adminId: 'admin_1',
  action: 'deleteUser',
  days: 30,
  limit: 100,
);

// Get audit log statistics
final stats = await getAuditLogStats(days: 30);
// Returns: {totalActions, actionCounts, adminCounts, period}
```

## Firestore Audit Log Schema

```
admin/auditLog/entries/{entryId}
├─ adminId: string
├─ action: string
├─ description: string
├─ targetId: string (optional)
├─ details: map
├─ timestamp: Timestamp
└─ ipAddress: string
```

---

**Phase 11 Status**: ✅ Complete (All 3 Parts)
- Part 1: Admin Dashboard Infrastructure
- Part 2: Admin Dashboard UI Screens  
- Part 3: Advanced Admin Features (Feature Flags + Audit Logging)

**Next**: Phase 12 - Leaderboard Enhancement (Auto-grade promotion & Grouping)

