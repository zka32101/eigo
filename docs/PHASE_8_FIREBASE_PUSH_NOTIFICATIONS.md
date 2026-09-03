# Phase 8: Firebase Cloud Messaging & Push Notifications

## Overview

Phase 8 extends the Phase 7 notification system by integrating Firebase Cloud Messaging (FCM) for real push notifications. This enables the app to send notifications to users even when the app is closed or in the background.

## Architecture

### Core Components

#### 1. **Push Notification Service** (`english_town_push_notification_service.dart`)
Manages push notification payloads and delivery tracking

**Key Classes:**
- `PushNotificationPayload`: Represents a push notification ready for FCM
- `ScheduledPushNotification`: Represents a scheduled notification
- `EnglishTownPushNotificationService`: Manages push notification lifecycle

**Key Methods:**
```dart
queuePushNotification(payload)
createRankChangePushNotification(previousRank, currentRank, playerName)
createAchievementPushNotification(achievementTitle, rewardXp)
createStreakMilestonePushNotification(streakDays)
createTop10PushNotification(rank)
createDailyReminderPushNotification(playerName, conversationsToday)
markNotificationSent(notificationId)
isNotificationSent(notificationId)
getPendingNotifications()
```

#### 2. **Firebase Cloud Messaging Service** (`english_town_fcm_service.dart`)
Handles Firebase Cloud Messaging integration and configuration

**Key Methods:**
```dart
initialize()                           // Initialize FCM
getToken()                            // Get device FCM token
requestNotificationPermission()       // Request iOS/Android permissions
setupMessageHandlers(...)             // Setup foreground/background handlers
subscribeToTopic(topic)               // Subscribe to notification topics
unsubscribeFromTopic(topic)           // Unsubscribe from topics
areNotificationsEnabled()             // Check notification status
displayForegroundNotification(...)    // Display notification while app is open
sendTestNotification(deviceToken, ...) // Send test notification
sendNotificationToTopic(topic, ...)   // Send to all subscribed users
```

**Initialization Flow:**
```dart
final fcmService = ref.read(fcmServiceProvider);
await fcmService.initialize();
await fcmService.requestNotificationPermission();
final token = await fcmService.getToken();
// Store token to Firestore for backend targeting
```

#### 3. **Push Notification Provider** (`english_town_push_notification_provider.dart`)
State management for push notifications and preferences

**Streams:**
- `pushNotificationsStreamProvider`: Stream of all push notifications
- `unreadPushNotificationsProvider`: Unread notifications only
- `unreadPushNotificationCountProvider`: Count of unread

**Preferences:**
- `pushNotificationsEnabledProvider`: Global enable/disable
- `enableRankChangePushProvider`: Rank change notifications
- `enableAchievementPushProvider`: Achievement notifications
- `enableStreakMilestonePushProvider`: Streak milestone notifications
- `enableTop10PushProvider`: Top 10 entry notifications
- `enableDailyReminderPushProvider`: Daily reminders
- `quietHoursStartProvider`: Quiet hours start (default: 22/10 PM)
- `quietHoursEndProvider`: Quiet hours end (default: 8/8 AM)

#### 4. **FCM Provider** (`english_town_fcm_provider.dart`)
Riverpod providers for FCM service integration

**Providers:**
- `fcmServiceProvider`: FCM service singleton
- `fcmInitProvider`: FCM initialization
- `fcmTokenProvider`: Current device token
- `fcmNotificationsEnabledProvider`: Notification permission status
- `fcmInitializedProvider`: Initialization state

**Topic Manager:**
```dart
class FCMTopicManager {
  static const String allUsers = 'announcements';
  static const String topTen = 'top_10_players';
  static const String top50 = 'top_50_players';
  static const String achievements = 'achievements';
  static const String dailyReminders = 'daily_reminders';
  static const String rankUpdates = 'rank_updates';
  static const String events = 'special_events';
}
```

## Firebase Setup

### Prerequisites

1. **Firebase Project**
   - Create a Firebase project at [firebase.google.com](https://firebase.google.com)
   - Enable Firestore Database
   - Enable Cloud Messaging

2. **Google Services Files**
   - Download `google-services.json` (Android)
   - Download `GoogleService-Info.plist` (iOS)

3. **iOS Specific**
   - Enable Push Notifications capability in Xcode
   - Add APNs certificate to Firebase Console
   - Configure sound and alert permissions

### Flutter Setup

**pubspec.yaml additions:**
```yaml
dependencies:
  firebase_messaging: ^14.0.0
  flutter_local_notifications: ^15.0.0
  timezone: ^0.9.0
```

**Initialize in main.dart:**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize FCM
  final fcmService = EnglishTownFCMService();
  await fcmService.initialize();
  
  runApp(const MyApp());
}
```

## Message Handling

### Foreground Messages (App in Focus)

When a notification arrives while the app is open:

```dart
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  print('Notification received while app is in focus');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  
  // Show local notification
  // Navigate based on message data
  // Update UI state
});
```

### Background Messages (App Minimized)

Notification is displayed automatically by the system.

### Notification Tap (App Closed)

When user taps notification to open app:

```dart
FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  print('Notification tapped');
  // Navigate to appropriate screen
  // Handle deep linking
});
```

## Firestore Schema

### Notification Storage

```
notifications/
├── {userId}/
│   ├── inbox/
│   │   └── {notificationId}: {
│   │       "id": "string",
│   │       "type": "rankChanged|achievement|streak|challenge|top10",
│   │       "title": "string",
│   │       "body": "string",
│   │       "imageUrl": "string?",
│   │       "data": {key: value},
│   │       "createdAt": timestamp,
│   │       "sentAt": timestamp?,
│   │       "read": boolean,
│   │       "clicked": boolean,
│   │       "dismissed": boolean,
│   │       "actionUrl": "string?",
│   │       "priority": integer (0-10),
│   │       "ttl": timestamp (expires after 30 days)
│   │     }
│   │
│   ├── scheduled/
│   │   └── {notificationId}: {
│   │       "id": "string",
│   │       "title": "string",
│   │       "body": "string",
│   │       "scheduledFor": timestamp,
│   │       "repeating": boolean,
│   │       "recurrencePattern": "string?",
│   │       "sent": boolean,
│   │       "sentAt": timestamp?,
│   │       "createdAt": timestamp
│   │     }
│   │
│   └── settings/
│       └── preferences: {
│           "pushEnabled": boolean,
│           "rankChangeEnabled": boolean,
│           "achievementEnabled": boolean,
│           "streakMilestoneEnabled": boolean,
│           "top10Enabled": boolean,
│           "dailyReminderEnabled": boolean,
│           "quietHoursStart": integer,
│           "quietHoursEnd": integer,
│           "fcmToken": "string",
│           "lastTokenUpdate": timestamp,
│           "updatedAt": timestamp
│         }
```

### Device Registration

```
devices/
├── {deviceId}: {
    "userId": "string",
    "fcmToken": "string",
    "deviceName": "string",
    "platform": "iOS|Android|Web",
    "osVersion": "string",
    "appVersion": "string",
    "lastSeen": timestamp,
    "createdAt": timestamp
  }
```

## Topic Subscriptions

### Automatic Topic Management

```dart
// All new users subscribed to these topics
await FCMTopicManager.subscribeToDefaultTopics(ref);
// → 'announcements', 'daily_reminders'

// When rank changes, update topics
await FCMTopicManager.updateTopicsForRank(
  ref,
  currentRank: userRank,
);
// If rank ≤ 10: subscribe to 'top_10_players'
// If rank ≤ 50: subscribe to 'top_50_players'

// When achievements unlock
await FCMTopicManager.updateTopicsForAchievements(
  ref,
  unlockedAchievements: achievements,
);
// → subscribe to 'achievements'
```

### Backend Topic Distribution

**Global Announcements**
- Topic: `announcements`
- Audience: All users
- Frequency: As needed
- Example: "New feature available!"

**Daily Reminders**
- Topic: `daily_reminders`
- Audience: Users with reminders enabled
- Frequency: Once per day at optimal time
- Example: "Time to practice English!"

**Top Player Notifications**
- Topic: `top_10_players`
- Audience: Top 10 ranked players
- Frequency: When rank changes
- Example: "You've been overtaken!"

**Achievement Notifications**
- Topic: `achievements`
- Audience: Users who've unlocked achievements
- Frequency: On unlock
- Example: "Congratulations on First Achievement!"

**Rank Update Notifications**
- Topic: `rank_updates`
- Audience: Opt-in users
- Frequency: On significant rank change
- Example: "You climbed 5 positions!"

**Special Events**
- Topic: `special_events`
- Audience: All users
- Frequency: During events
- Example: "Double XP Weekend starts now!"

## Quiet Hours

Notifications respect user-configured quiet hours:

```dart
// Default: 10 PM - 8 AM (no notifications)
final startHour = ref.read(quietHoursStartProvider);      // 22
final endHour = ref.read(quietHoursEndProvider);          // 8

// Check if in quiet hours
bool inQuietHours = isInQuietHours(ref);

// Send only if outside quiet hours
if (!inQuietHours && shouldSendNotification(ref, type: 'achievement')) {
  await queuePushNotification(ref, payload);
}
```

## Integration Points

### On Achievement Unlock

```dart
// In reward screen or achievement detection
if (achievementUnlocked) {
  // 1. Create notification payload
  final pushPayload = ref.read(pushNotificationServiceProvider)
    .createAchievementPushNotification(
      achievementTitle: achievement.title,
      rewardXp: achievement.rewardXp,
    );
  
  // 2. Queue for sending
  await queuePushNotification(ref, pushPayload);
  
  // 3. Store to Firestore (if enabled)
  // await storeNotificationToFirestore(userId, pushPayload);
}
```

### On Rank Change

```dart
// In leaderboard monitoring
if (rankChanged) {
  final pushPayload = ref.read(pushNotificationServiceProvider)
    .createRankChangePushNotification(
      previousRank: oldRank,
      currentRank: newRank,
      playerName: playerName,
    );
  
  if (shouldSendNotification(ref, notificationType: 'rankChanged')) {
    await queuePushNotification(ref, pushPayload);
  }
}
```

### On Streak Milestone

```dart
// In streak tracking
if (streakReachedMilestone(streakDays)) {
  final pushPayload = ref.read(pushNotificationServiceProvider)
    .createStreakMilestonePushNotification(
      streakDays: streakDays,
    );
  
  if (shouldSendNotification(ref, notificationType: 'streak')) {
    await queuePushNotification(ref, pushPayload);
  }
}
```

## Backend API Endpoints

### Send Notification to Device

```http
POST /api/notifications/send
Content-Type: application/json

{
  "deviceToken": "string",
  "title": "string",
  "body": "string",
  "data": {
    "notificationId": "string",
    "type": "string",
    "actionUrl": "string?"
  },
  "priority": "high|normal|low"
}
```

### Send Notification to Topic

```http
POST /api/notifications/send-to-topic
Content-Type: application/json

{
  "topic": "announcements|top_10_players|...",
  "title": "string",
  "body": "string",
  "data": {object},
  "priority": "high|normal|low"
}
```

### Schedule Notification

```http
POST /api/notifications/schedule
Content-Type: application/json

{
  "userId": "string",
  "title": "string",
  "body": "string",
  "scheduledFor": "2026-09-15T18:00:00Z",
  "repeating": false,
  "recurrencePattern": "cron expression?"
}
```

### Update User Notification Settings

```http
PUT /api/users/{userId}/notification-settings
Content-Type: application/json

{
  "pushEnabled": boolean,
  "rankChangeEnabled": boolean,
  "achievementEnabled": boolean,
  "streakMilestoneEnabled": boolean,
  "top10Enabled": boolean,
  "dailyReminderEnabled": boolean,
  "quietHoursStart": integer,
  "quietHoursEnd": integer,
  "fcmToken": "string"
}
```

## Performance Considerations

1. **Token Management**
   - Tokens can expire/refresh; always sync latest
   - Store token with device info in Firestore
   - Invalidate old tokens after 30 days without use

2. **Rate Limiting**
   - Max 1 push per minute per user
   - Max 5 pushes per hour per user
   - Aggregated notifications for frequent events

3. **Payload Size**
   - Keep body under 240 characters
   - Keep title under 65 characters
   - Keep total payload under 4KB

4. **Battery & Network**
   - Use `priority: normal` for non-urgent
   - Use `priority: high` for time-sensitive
   - Avoid multiple notifications in quick succession

## Testing

### Send Test Notification

```dart
final fcmService = ref.read(fcmServiceProvider);
final token = await fcmService.getToken();

await fcmService.sendTestNotification(
  deviceToken: token!,
  title: 'Test Notification',
  body: 'This is a test',
);
```

### Firebase Console Testing

1. Go to Firebase Console → Cloud Messaging
2. Click "Send your first message"
3. Enter notification title and body
4. Select target topic or device
5. Schedule for now or later

### Firestore Emulator Testing

```dart
// Use local Firestore emulator during development
await Firebase.initializeApp();
FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
```

## Debugging

### Enable Debug Logging

```dart
firebase_core:
  FirebaseCore.instance.setLevel(Level.debug);

firebase_messaging:
  FirebaseMessaging.instance.setAutoInitEnabled(true);
```

### Check Device Token

```dart
final fcmService = ref.read(fcmServiceProvider);
final token = await fcmService.getToken();
print('Device Token: $token');
```

### Monitor Messages

```dart
FirebaseMessaging.onMessage.listen((message) {
  print('=== FOREGROUND MESSAGE ===');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');
});

FirebaseMessaging.onMessageOpenedApp.listen((message) {
  print('=== NOTIFICATION TAPPED ===');
  print('Data: ${message.data}');
});
```

## Future Enhancements

1. **Smart Scheduling**
   - ML-powered optimal send time
   - User activity pattern analysis
   - A/B testing notification timing

2. **Rich Notifications**
   - Action buttons (Open, Dismiss, Snooze)
   - Large images and custom layouts
   - Sound and vibration patterns

3. **User Segmentation**
   - Behavior-based targeting
   - Geographic targeting
   - Device-based personalization

4. **Advanced Analytics**
   - Delivery rate tracking
   - Open rate by notification type
   - User engagement metrics
   - Cohort analysis

5. **Multi-language Support**
   - Notifications in user's language
   - Localized content based on region
   - Cultural sensitivity

6. **Notification Threads**
   - Group related notifications
   - Conversation-like experience
   - Summary notifications

## Configuration Checklist

- [ ] Firebase project created and configured
- [ ] google-services.json added (Android)
- [ ] GoogleService-Info.plist added (iOS)
- [ ] APNs certificate uploaded (iOS)
- [ ] Push Notifications capability enabled (iOS)
- [ ] firebase_messaging and flutter_local_notifications added
- [ ] FCM initialized in main.dart
- [ ] Message handlers configured
- [ ] Firestore collections created
- [ ] Backend APIs implemented
- [ ] Topic subscriptions configured
- [ ] Notification preferences UI added
- [ ] Deep linking configured
- [ ] Analytics event tracking added

---

**Phase 8 Status**: ✅ Complete (Firebase Push Notifications)
**Next Phase**: Phase 9 - Social Features (Friends, Multiplayer, Challenges)
