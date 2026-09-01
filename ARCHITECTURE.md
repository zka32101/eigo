# Architecture Documentation

## Project Structure

```
lib/
├── main.dart                          # App entry point and routing
├── models/                            # Data models
│   ├── user_profile.dart
│   ├── friend_model.dart             # Phase 4-2
│   ├── leaderboard_model.dart        # Phase 4-2
│   ├── analytics_model.dart          # Phase 4-3
│   ├── notification_model.dart       # Phase 4-4
│   ├── badge_model.dart              # Phase 4-5
│   └── [other models]
├── providers/                         # Riverpod state management
│   ├── user_profile_provider.dart
│   ├── friend_provider.dart          # Phase 4-2
│   ├── leaderboard_provider.dart     # Phase 4-2
│   ├── analytics_provider.dart       # Phase 4-3
│   ├── notification_settings_provider.dart  # Phase 4-4
│   ├── badge_provider.dart           # Phase 4-5
│   └── [other providers]
├── screens/                           # UI screens
│   ├── home_screen.dart
│   ├── profile_management_screen.dart       # Phase 4-1
│   ├── leaderboard_screen.dart             # Phase 4-2
│   ├── friends_screen.dart                 # Phase 4-2
│   ├── analytics_screen.dart               # Phase 4-3
│   ├── notification_management_screen.dart # Phase 4-4
│   ├── achievements_screen.dart            # Phase 4-5
│   └── [other screens]
├── theme/                             # Design system
│   ├── app_theme.dart
│   ├── spacing.dart
│   ├── sizes.dart
│   └── typography.dart
├── services/                          # Business logic services
│   ├── notification_service.dart
│   ├── ad_service.dart
│   ├── firebase_service.dart
│   └── [other services]
└── [other directories]
```

---

## State Management Architecture

### Riverpod Pattern
The application uses Flutter Riverpod for reactive state management following these patterns:

#### 1. StateNotifierProvider (Mutable State)
Used for features that require persistent state with mutations:

```dart
final friendListProvider = StateNotifierProvider<FriendListNotifier, List<Friend>>((ref) {
  return FriendListNotifier();
});

class FriendListNotifier extends StateNotifier<List<Friend>> {
  FriendListNotifier() : super([]) {
    _loadFriends(); // Load from storage
  }
  
  Future<void> addFriend(Friend friend) async {
    state = [...state, friend];
    await _saveFriends(); // Persist to storage
  }
}
```

**Usage**:
```dart
// Watch state for reactivity
final friends = ref.watch(friendListProvider);

// Access notifier for mutations
ref.read(friendListProvider.notifier).addFriend(friend);
```

#### 2. FutureProvider (Async Data)
Used for features that fetch data asynchronously:

```dart
final globalLeaderboardProvider = FutureProvider.autoDispose<LeaderboardData>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  // Fetch or compute leaderboard data
  return leaderboardData;
});
```

**Usage**:
```dart
final leaderboardAsync = ref.watch(globalLeaderboardProvider);
leaderboardAsync.when(
  data: (data) => LeaderboardView(data),
  loading: () => LoadingIndicator(),
  error: (err, st) => ErrorView(err),
);
```

#### 3. Provider.family (Parameterized)
Used for features that need different instances based on parameters:

```dart
final userComparisonProvider = 
    FutureProvider.family<UserComparison?, (String, String)>((ref, userIds) async {
  final (userId1, userId2) = userIds;
  // Compute comparison
});
```

**Usage**:
```dart
final comparison = ref.watch(userComparisonProvider((user1Id, user2Id)));
```

#### 4. Select (Selective Watching)
Used to watch only specific parts of state:

```dart
final unreadCount = ref.watch(
  notificationHistoryProvider.select((n) => n.where((x) => !x.isRead).length)
);
```

---

## Data Persistence Layer

### SharedPreferences Strategy
All mutable state is persisted to SharedPreferences following this pattern:

```dart
class MyNotifier extends StateNotifier<List<MyData>> {
  static const String _storageKey = 'eigo_kore_my_data';
  
  MyNotifier() : super([]) {
    _loadData();
  }
  
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString);
        state = decoded.map((json) => MyData.fromJson(json)).toList();
      } catch (e) {
        print('Error loading data: $e');
      }
    }
  }
  
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(state.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }
  
  Future<void> updateItem(MyData item) async {
    // Update state
    state = [...state]; // Trigger update
    await _saveData();
  }
}
```

### JSON Serialization
All models implement JSON serialization for persistence:

```dart
class MyModel {
  final String id;
  final String name;
  final DateTime createdAt;
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
  };
  
  factory MyModel.fromJson(Map<String, dynamic> json) => MyModel(
    id: json['id'] as String,
    name: json['name'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
```

---

## Feature Architecture

### Phase 4-1: Profile Management
**State Flow**:
```
UserProfile (Model)
    ↓
currentUserProvider (Watch)
    ↓
ProfileManagementScreen (ConsumerWidget)
    ↓
_StatisticsTab / _PrivacyTab / _DataManagementTab
    ↓
userProfilesProvider.notifier.updateProfile()
```

**Data Flow**:
1. Load current user via `currentUserProvider`
2. Display stats in read-only mode on Statistics tab
3. On Privacy tab toggle, call notifier to update profile
4. Notifier saves to SharedPreferences
5. State updates reactively in UI

---

### Phase 4-2: Social/Leaderboard
**State Flow**:
```
Friend / FriendRequest (Models)
    ↓
friendListProvider / friendRequestsProvider (Watch)
    ↓
FriendsScreen (ConsumerWidget)
    ↓
FriendListNotifier / FriendRequestsNotifier (Mutations)
    ↓
SharedPreferences (Persistence)
```

**Leaderboard State Flow**:
```
LeaderboardEntry / LeaderboardData (Models)
    ↓
globalLeaderboardProvider / friendLeaderboardProvider (FutureProvider.autoDispose)
    ↓
LeaderboardScreen (ConsumerWidget)
    ↓
_LeaderboardEntryCard (Stateless display)
```

**Key Design Decisions**:
- Use autoDispose to free memory when not actively viewing
- FutureProvider provides clean async handling
- Friend mutations are immediate (optimistic updates)
- Leaderboard data is computed from friends + current user

---

### Phase 4-3: Analytics/Reports
**State Flow**:
```
DailyStats / MonthlyStats / WeeklyReport (Models)
    ↓
analyticsProvider (StateNotifierProvider)
    ↓
AnalyticsScreen (ConsumerWidget)
    ↓
_ProgressTab / _WeeklyTab / _MonthlyTab (Stateless)
```

**Data Flow**:
1. Daily stats recorded via `analyticsProvider.notifier.recordDailyStats()`
2. Monthly stats calculated on-demand from daily stats
3. Charts and progress bars computed from stats
4. UI updates reactively when stats change

**Calculation Methods**:
- Monthly stats: Aggregate all daily stats for month
- Weekly stats: Filter daily stats for week
- Accuracy: Correct answers / total answers
- Progress: Current value / target value

---

### Phase 4-4: Notifications/Reminders
**State Flow**:
```
NotificationSettings / NotificationRecord (Models)
    ↓
notificationSettingsProvider / notificationHistoryProvider (StateNotifierProvider)
    ↓
NotificationManagementScreen (ConsumerWidget)
    ↓
_NotificationSettingsTab / _NotificationHistoryTab
    ↓
NotificationSettingsNotifier / NotificationHistoryNotifier (Mutations)
    ↓
SharedPreferences (Persistence)
```

**Settings Management**:
- Individual toggle methods for each setting type
- Hour-based time picker for reminder scheduling
- Auto-persist all changes to SharedPreferences
- Real-time UI update on toggle

**History Management**:
- Record notifications with metadata
- Track read/unread status
- Support deletion of individual notifications
- Mark all as read functionality

---

### Phase 4-5: Achievements/Badges
**State Flow**:
```
Badge / UnlockedBadge / BadgeProgress (Models)
    ↓
badgeProvider / badgeProgressProvider (StateNotifierProvider)
    ↓
AchievementsScreen (ConsumerWidget)
    ↓
_UnlockedBadgesTab / _ProgressTab / _AllBadgesTab
    ↓
BadgeProgressNotifier (Mutations with auto-unlock)
    ↓
SharedPreferences (Persistence)
```

**Badge Unlocking Logic**:
```dart
Future<void> updateProgress(String badgeId, int newValue) async {
  final progress = state[index];
  final isNowUnlocked = newValue >= progress.targetValue;
  
  if (isNowUnlocked && !progress.isUnlocked) {
    // Auto-unlock when target reached
    state = [...state, progress.copyWith(
      isUnlocked: true,
      unlockedAt: DateTime.now(),
    )];
  }
}
```

---

## Theme and Design System

### Color Palette
Located in `lib/theme/app_theme.dart`:

```dart
const Color kPrimaryColor = Color(0xFF2196F3);      // Blue
const Color kAccentOrange = Color(0xFFFF9800);      // Orange
const Color kAccentGreen = Color(0xFF4CAF50);       // Green
const Color kAccentRed = Color(0xFFF44336);         // Red
const Color kTextMuted = Color(0xFF757575);         // Grey
```

### Spacing System
Located in `lib/theme/spacing.dart`:

```dart
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  
  // Pre-made spacers
  static final verticalSpacerSm = SizedBox(height: sm);
  static final horizontalSpacerMd = SizedBox(width: md);
  // etc.
}
```

### Typography System
Located in `lib/theme/typography.dart`:

Consistent text styles across the app:
- `headlineSmall`: Section headers
- `labelLarge`: Card titles
- `bodySmall`: Descriptive text
- Custom text styles for specific use cases

### Size Constants
Located in `lib/theme/sizes.dart`:

```dart
class AppSizes {
  static const double borderRadius = 12;
  static const double borderRadiusSmall = 8;
  static const double borderRadiusLarge = 16;
}
```

---

## Error Handling Strategy

### Load Errors
All data loading is wrapped in try-catch:

```dart
Future<void> _loadData() async {
  try {
    final json = jsonDecode(jsonString);
    state = Model.fromJson(json);
  } catch (e) {
    print('Error loading data: $e');
    // Fallback to default/empty state
  }
}
```

### UI Error States
FutureProvider error handling:

```dart
leaderboardAsync.when(
  data: (data) => LeaderboardView(data),
  loading: () => const Center(child: CircularProgressIndicator()),
  error: (error, stack) => Center(
    child: Text('エラーが発生しました: $error'),
  ),
);
```

### Persistence Errors
File operations include error logging:

```dart
Future<void> _saveData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonString);
  } catch (e) {
    print('Error saving data: $e');
    // Log to error tracking service
  }
}
```

---

## Performance Optimizations

### Memory Management
- **autoDispose**: FutureProviders clean up when not watched
- **SelectiveWatching**: ref.watch().select() to watch specific fields
- **Lazy Loading**: Load data only when screen is visible

### Build Optimization
- **ConsumerWidget**: Only rebuild when watched providers change
- **StatelessWidget**: For components that don't need state
- **GridView.builder**: Build items on-demand, not all at once

### Storage Optimization
- **Incremental saves**: Only save when data changes
- **Efficient serialization**: JSON over other formats
- **Cleanup old data**: Archive or delete old analytics

---

## Testing Architecture

### Unit Testing Approach
Test notifiers in isolation:

```dart
test('addFriend adds friend to list', () async {
  final notifier = FriendListNotifier();
  await notifier.addFriend(testFriend);
  expect(notifier.state, contains(testFriend));
});
```

### Widget Testing Approach
Test screens with mock providers:

```dart
testWidgets('FriendsScreen displays friends', (tester) async {
  await tester.pumpWidget(
    ProviderContainer(
      overrides: [
        friendListProvider.overrideWithValue([testFriend]),
      ],
      child: const FriendsScreen(),
    ).toWidget(),
  );
  
  expect(find.text(testFriend.name), findsWidgets);
});
```

---

## Deployment Considerations

### Platform-Specific
- Android: SharedPreferences stores in app's private directory
- iOS: NSUserDefaults equivalent
- Both: Automatic encryption of sensitive data

### Scaling Concerns
- Current implementation optimized for 1000s of records
- For millions: Consider SQLite or Hive database
- Real-time features: Implement backend synchronization

### Monitoring
- Error tracking with Sentry/Firebase Crashlytics
- Analytics with Firebase Analytics
- Performance monitoring with Firebase Performance Monitoring

---

## Future Architectural Changes

### Backend Integration
When connecting to backend:

```dart
final friendListProvider = FutureProvider<List<Friend>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getFriends(); // Network request
});
```

### Caching Strategy
Implement multi-layer caching:

```dart
// Cache with invalidation
final friendListProvider = FutureProvider<List<Friend>>((ref) async {
  final cache = ref.watch(cacheProvider);
  final cached = cache.get('friends');
  if (cached != null && !cache.isExpired('friends')) {
    return cached;
  }
  return api.getFriends();
});
```

### Real-time Updates
Add WebSocket/Firebase Realtime support:

```dart
final realtimeLeaderboardProvider = StreamProvider<LeaderboardData>((ref) {
  return firebase.leaderboard().snapshots();
});
```

