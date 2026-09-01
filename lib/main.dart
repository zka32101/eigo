import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/stage.dart';
import 'providers/purchase_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/badge_screen.dart';
import 'screens/home_screen.dart';
import 'screens/lesson_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/parent_dashboard_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/result_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/stage_select_screen.dart';
import 'screens/ranking_screen.dart';
import 'screens/speaking_practice_screen.dart';
import 'screens/study_calendar_screen.dart';
import 'screens/test_prep_result_screen.dart';
import 'screens/test_prep_screen.dart';
import 'screens/upgrade_screen.dart';
import 'screens/weekly_report_screen.dart';
import 'screens/word_review_screen.dart';
import 'screens/daily_challenge_screen.dart';
import 'screens/pronunciation_battle_screen.dart';
import 'screens/conversation_screen.dart';
import 'screens/parent_child_challenge_screen.dart';
import 'screens/invite_screen.dart';
import 'screens/notification_settings_screen.dart';
import 'screens/profile_select_screen.dart';
import 'screens/ai_freetalk_screen.dart';
import 'screens/pronunciation_check_screen.dart';
import 'screens/vocabulary_screen.dart';
import 'screens/stage_intro_screen.dart';
import 'screens/pet_screen.dart';
import 'screens/teacher_mode_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/learning_pace_screen.dart';
import 'screens/character_collection_screen.dart';
import 'screens/ad_settings_screen.dart';
import 'screens/promotion_screen.dart';
import 'screens/profile_management_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/friends_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/notification_management_screen.dart';
import 'screens/achievements_screen.dart';
import 'screens/camera_scan_screen.dart';
import 'screens/parent_child_battle_screen.dart';
import 'screens/pronunciation_video_screen.dart';
import 'screens/passport_screen.dart';
import 'screens/english_town_screen.dart';
import 'services/notification_service.dart';
import 'services/ad_service.dart';
import 'services/firebase_service.dart';
import 'providers/morning_notification_provider.dart';
import 'providers/coin_provider.dart';
import 'theme/app_theme.dart' show buildAppTheme, buildDarkAppTheme, kPrimaryColor, kTextMuted;
import 'providers/user_profile_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // 通知初期化
  await NotificationService().init();

  // Firebase初期化（未設定時はgraceful fallbackでローカルのみ動作）
  await FirebaseService().init();

  // AdMob初期化
  await AdService().initialize();

  // 保存済みコイン残高を読み込んでから起動（未読み込みのままだと0のみで
  // 上書きされ、既存残高が消失するため必須）
  final container = ProviderContainer();
  await container.read(coinProvider.notifier).load();

  runApp(UncontrolledProviderScope(container: container, child: const EigoKoreApp()));
}

class EigoKoreApp extends ConsumerWidget {
  const EigoKoreApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // プロバイダーを事前ウォームアップ
    ref.watch(settingsProvider);
    ref.watch(purchaseProvider);
    ref.watch(morningNotificationStateProvider);

    final profiles = ref.watch(userProfilesProvider);
    final currentUserId = ref.watch(currentUserIdProvider);
    final hasProfiles = profiles.isNotEmpty && currentUserId != null;

    return MaterialApp(
      title: '英語コレ！',
      theme: buildAppTheme(),
      darkTheme: buildDarkAppTheme(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => hasProfiles ? const RootShell() : const ProfileSelectScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const RootShell(),
        '/stages': (context) => const StageSelectScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/badges': (context) => const BadgeScreen(),
        '/parent': (context) => const ParentDashboardScreen(),
        '/privacy': (context) => const PrivacyPolicyScreen(),
        '/upgrade': (context) => const UpgradeScreen(),
        '/test-prep': (context) => const TestPrepScreen(),
        '/speaking-practice': (context) => const SpeakingPracticeScreen(),
        '/ranking': (context) => const RankingScreen(),
        '/calendar': (context) => const StudyCalendarScreen(),
        '/weekly-report': (context) => const WeeklyReportScreen(),
        '/daily-challenge': (context) => const DailyChallengeScreen(),
        '/pronunciation-battle': (context) => const PronunciationBattleScreen(),
        '/conversation': (context) => const ConversationScreen(),
        '/parent-child': (context) => const ParentChildChallengeScreen(),
        '/invite': (context) => const InviteScreen(),
        '/notification-settings': (context) => const NotificationSettingsScreen(),
        '/profile-select': (context) => const ProfileSelectScreen(),
        '/ai-freetalk': (context) => const AiFreetalkScreen(),
        '/vocabulary': (context) => const VocabularyScreen(),
        '/pet': (context) => const PetScreen(),
        '/teacher-mode': (context) => const TeacherModeScreen(),
        '/shop': (context) => const ShopScreen(),
        '/learning-pace': (context) => const LearningPaceScreen(),
        '/character-collection': (context) => const CharacterCollectionScreen(),
        '/ad-settings': (context) => const AdSettingsScreen(),
        '/promotions': (context) => const PromotionScreen(),
        '/profile-management': (context) => const ProfileManagementScreen(),
        '/leaderboard': (context) => const LeaderboardScreen(),
        '/friends': (context) => const FriendsScreen(),
        '/analytics': (context) => const AnalyticsScreen(),
        '/notifications': (context) => const NotificationManagementScreen(),
        '/achievements': (context) => const AchievementsScreen(),
        '/camera-scan': (context) => const CameraScanScreen(),
        '/parent-child-battle': (context) => const ParentChildBattleScreen(),
        '/pronunciation-video': (context) => const PronunciationVideoScreen(),
        '/passport': (context) => const PassportScreen(),
        '/english-town': (context) => const EnglishTownScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/test-prep-result') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => TestPrepResultScreen(args: args),
            settings: settings,
          );
        }
        if (settings.name == '/stage-intro') {
          final stage = settings.arguments as Stage;
          return MaterialPageRoute(
            builder: (_) => StageIntroScreen(stage: stage),
            settings: settings,
          );
        }
        if (settings.name == '/lesson') {
          final stage = settings.arguments as Stage;
          return MaterialPageRoute(
            builder: (_) => LessonScreen(stage: stage),
            settings: settings,
          );
        }
        if (settings.name == '/result') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => ResultScreen(args: args),
            settings: settings,
          );
        }
        if (settings.name == '/word-review') {
          final stage = settings.arguments as Stage;
          return MaterialPageRoute(
            builder: (_) => WordReviewScreen(stage: stage),
            settings: settings,
          );
        }
        if (settings.name == '/pronunciation-check') {
          final stage = settings.arguments as Stage;
          return MaterialPageRoute(
            builder: (_) => PronunciationCheckScreen(stage: stage),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}

class RootShell extends ConsumerStatefulWidget {
  const RootShell({super.key});

  @override
  ConsumerState<RootShell> createState() => _RootShellState();
}

class _RootShellState extends ConsumerState<RootShell> {
  int _tab = 0;

  static const _screens = [
    HomeScreen(),
    StageSelectScreen(),
    ParentDashboardScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: kTextMuted,
        backgroundColor: Colors.white,
        elevation: 8,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'ステージ'),
          BottomNavigationBarItem(icon: Icon(Icons.family_restroom), label: '親'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'せってい'),
        ],
      ),
    );
  }
}
