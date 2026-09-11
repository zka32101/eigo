import 'dart:async';

import 'package:cross_promo_kit/cross_promo_kit.dart'
    show CrossPromoService;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart' hide lessonProvider;
import 'package:shared_core/shared_core.dart'
    show badgeProvider, unifiedBadges, BadgeNotifier, rankingProvider, friendProvider, missionProvider, coinProvider, premiumProvider, PremiumNotifier;

import '../design_system/design_system.dart';
import 'models/challenge_model.dart';
import 'models/pet_model.dart';
import 'models/stage.dart';
import 'models/video_model.dart';
import 'providers/character_provider.dart';
import 'providers/coin_provider.dart';
import 'providers/lesson_provider.dart' show LessonNotifier, lessonProvider;
import 'providers/morning_notification_provider.dart';
import 'providers/purchase_provider.dart';
import 'providers/screen_time_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/user_profile_provider.dart';
import 'screens/achievements_screen.dart';
import 'screens/activity_feed_screen.dart';
import 'screens/ad_settings_screen.dart';
import 'screens/ai_freetalk_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/badge_screen.dart';
import 'screens/camera_scan_screen.dart';
import 'screens/challenge_completion_screen.dart';
import 'screens/challenge_detail_screen.dart';
import 'screens/challenge_hub_screen.dart';
import 'screens/character_collection_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/conversation_list_screen.dart';
import 'screens/conversation_screen.dart';
import 'screens/daily_challenge_screen.dart';
import 'screens/english_town_hub_screen.dart';
import 'screens/english_town_screen.dart';
import 'screens/explanation_menu_screen.dart';
import 'screens/friend_challenge_screen.dart';
import 'screens/friends_screen.dart';
import 'screens/home_screen.dart';
import 'screens/invite_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/learning_pace_screen.dart';
import 'screens/lesson_screen.dart';
import 'screens/mission/mission_screen.dart';
import 'screens/multiplayer_leaderboard_screen.dart';
import 'screens/multiplayer_matchmaker_screen.dart';
import 'screens/notification_center_screen.dart';
import 'screens/notification_management_screen.dart';
import 'screens/notification_settings_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/parent_child_battle_screen.dart';
import 'screens/parent_child_challenge_screen.dart';
import 'screens/parent_dashboard_screen.dart';
import 'screens/passport_screen.dart';
import 'screens/pet_adoption_screen.dart';
import 'screens/pet_breeding_screen.dart';
import 'screens/pet_evolution_screen.dart';
import 'screens/pet_interaction_screen.dart';
import 'screens/pet_screen.dart';
import 'screens/pet_status_screen.dart';
import 'screens/plush_toy_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/profile_management_screen.dart';
import 'screens/profile_select_screen.dart';
import 'screens/promotion_screen.dart';
import 'screens/pronunciation_battle_screen.dart';
import 'screens/pronunciation_check_screen.dart';
import 'screens/pronunciation_video_screen.dart';
import 'screens/ranking_screen.dart';
import 'screens/result_screen.dart';
import 'screens/screen_time_settings_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/song_generator_screen.dart';
import 'screens/speaking_practice_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/stage_intro_screen.dart';
import 'screens/stage_select_screen.dart';
import 'screens/study_calendar_screen.dart';
import 'screens/teacher_mode_screen.dart';
import 'screens/test_prep_result_screen.dart';
import 'screens/test_prep_screen.dart';
import 'screens/upgrade_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/video_gallery_screen.dart';
import 'screens/video_player_screen.dart';
import 'screens/vocabulary_screen.dart';
import 'screens/weekly_report_screen.dart';
import 'screens/word_review_screen.dart';
import 'services/ad_service.dart';
import 'services/eigo_matchmaking_service.dart';
import 'services/firebase_service.dart';
import 'services/notification_service.dart';
import 'services/purchase_service.dart';
import 'services/firestore_ranking_service.dart';
import 'services/firestore_friend_service.dart';
import 'services/firestore_mission_service.dart';

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

  // クロスプロモーション初期化
  try {
    await CrossPromoService.init();
  } catch (e) {
    // エラーでも起動は継続
  }

  // AdMob初期化
  await AdService().initialize();

  // RevenueCat初期化（APIキー未設定時はgraceful skipし、フリープランで動作継続）
  final purchaseService = PurchaseService();
  await purchaseService.initializeRevenueCat();
  final fbUserId = FirebaseService().userId;
  if (fbUserId != null) {
    // FirebaseのユーザーIDとRevenueCatユーザーを紐付け（サポート・分析用途）
    await purchaseService.linkRevenueCatUser(fbUserId);
  }

  // 保存済みコイン残高を読み込んでから起動（未読み込みのままだと0のみで
  // 上書きされ、既存残高が消失するため必須）
  final matchmakingService = EigoMatchmakingService();
  final container = ProviderContainer(
    overrides: [
      characterStateProvider.overrideWith(CharacterNotifier.new),
      // 統一バッジシステム（Phase 4.1）: 英語コレ用バッジを主題タグで初期化
      badgeProvider.overrideWith((ref) {
        final notifier = BadgeNotifier();
        notifier.setBadgeDefinitions(unifiedBadges, subject: 'eigo');
        return notifier;
      }),
      screenTimeProvider.overrideWith(ScreenTimeNotifier.new),
      lessonProvider.overrideWith(LessonNotifier.new),
      // Phase 4.7: 統一サブスクリプション管理（PremiumProvider）
      premiumProvider.overrideWith(PremiumNotifier.new),
      // リアルタイム対戦（マルチプレイ）: Firestore実装（eigo_ プレフィックス）を注入
      matchmakingHandlersProvider.overrideWithValue(matchmakingService.matchmakingHandlers),
      matchHandlersProvider.overrideWithValue(matchmakingService.matchHandlers),
    ],
  );
  await container.read(coinProvider.notifier).load();

  // バグ報告・改善要望フォームの送信ハンドラを登録（Firestore `feedback` コレクションへ書き込み）
  container.read(feedbackProvider.notifier).setSubmitHandler(
        (report) => FirebaseService().submitFeedback(report),
      );
  // 未送信キューの再送信を試みる
  await container.read(feedbackProvider.notifier).retryPendingReports();

  // バッジシステム初期化: 統一バッジを主題タグで初期化
  container.read(badgeProvider.notifier).setBadgeDefinitions(unifiedBadges, subject: 'eigo');

  // Firestore ランキング・フレンド・ミッション サービスの初期化
  final rankingService = FirestoreRankingService();
  final friendService = FirestoreFriendService();
  final missionService = FirestoreMissionService();

  // Handler を shared_core provider に注入
  container.read(rankingProvider.notifier).setFetchHandler(rankingService.fetchRankings);
  container.read(globalRankingProvider.notifier).setFetchHandler(rankingService.fetchGlobalRankings);
  container.read(friendProvider.notifier)
    ..setFetchHandler(friendService.fetchFriends)
    ..setAddFriendHandler(friendService.addFriend)
    ..setRemoveFriendHandler(friendService.removeFriend);

  // Phase 4.7: 統一サブスクリプション初期化
  final currentUserId = missionService.getCurrentUserId();
  if (currentUserId != null) {
    container.read(premiumProvider.notifier)
      ..setCheckHandler((userId) => purchaseService.isSubscribed(userId))
      ..setExpiryHandler((userId) => purchaseService.getSubscriptionExpirationDate(userId));
    unawaited(container.read(premiumProvider.notifier).checkSubscription(currentUserId));
  }

  // Phase 4.5: デイリーミッション統一
  // ミッション初期化: 現在のユーザー ID で初期化
  if (currentUserId != null) {
    unawaited(container.read(missionProvider.notifier).initializeMissions(currentUserId));
  }

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
        '/screen-time-settings': (context) => const ScreenTimeSettingsScreen(),
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
        '/notifications-center': (context) => const NotificationCenterScreen(),
        '/profile-select': (context) => const ProfileSelectScreen(),
        '/ai-freetalk': (context) => const AiFreetalkScreen(),
        '/vocabulary': (context) => const VocabularyScreen(),
        '/study-guide': (context) => const ExplanationMenuScreen(),
        '/feedback': (context) => const FeedbackFormPage(appName: 'eigo_kore', appVersion: '3.1.0'),
        '/pet': (context) => const PetScreen(),
        '/pet-breeding': (context) => const PetBreedingScreen(),
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
        '/plush-toy': (context) => const PlushToyScreen(),
        '/passport': (context) => const PassportScreen(),
        '/english-town': (context) => const EnglishTownScreen(),
        '/song-generator': (context) => const SongGeneratorScreen(),
        '/english-town': (context) => const EnglishTownHubScreen(),
        '/challenges': (context) => const ChallengeHubScreen(), // Social challenges
        '/challenge-hub': (context) => const ChallengeHubScreen(),
        '/friend-challenges': (context) => const FriendChallengeScreen(),
        '/mission': (context) => const MissionScreen(),
        '/multiplayer': (context) => const MultiplayerMatchmakerScreen(),
        '/multiplayer-leaderboard': (context) => const MultiplayerLeaderboardScreen(),
        '/video-gallery': (context) => const VideoGalleryScreen(),
        '/pet-adoption': (context) => const PetAdoptionScreen(),
        '/pet-status': (context) => const PetStatusScreen(),
        '/pet-interaction': (context) => const PetInteractionScreen(),
        '/activity-feed': (context) => const ActivityFeedScreen(),
        '/leaderboard': (context) => const LeaderboardScreen(),
        '/conversations': (context) => const ConversationListScreen(),
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
        if (settings.name == '/challenge-detail') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => ChallengeDetailScreen(
              challenge: args['challenge'] as SocialChallenge,
              userId: args['userId'] as String,
            ),
            settings: settings,
          );
        }
        if (settings.name == '/challenge-completion') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => ChallengeCompletionScreen(
              challengeId: args['challengeId'] as String,
              userId: args['userId'] as String,
              challenge: args['challenge'] as SocialChallenge,
            ),
            settings: settings,
          );
        }
        if (settings.name == '/video-player') {
          final video = settings.arguments as PronunciationVideo;
          return MaterialPageRoute(
            builder: (_) => VideoPlayerScreen(video: video),
            settings: settings,
          );
        }
        if (settings.name == '/pet-evolution') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => PetEvolutionScreen(
              currentPet: args['currentPet'] as Pet,
              evolvedPet: args['evolvedPet'] as Pet,
            ),
            settings: settings,
          );
        }
        if (settings.name == '/user-profile') {
          final userId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => UserProfileScreen(userId: userId),
            settings: settings,
          );
        }
        if (settings.name == '/chat') {
          final conversationId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => ChatScreen(conversationId: conversationId),
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
    final notifier = ref.read(screenTimeProvider.notifier);
    final limitReached = ref.watch(
      screenTimeProvider.select((_) => notifier.isLimitReached),
    );
    if (limitReached) {
      return const ScreenTimeLimitReachedWidget(primaryColor: AppColors.primary);
    }

    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) async {
          if (i == 2) {
            final passedGate = await requireParentalGate(context);
            if (!passedGate || !mounted) return;
          }
          setState(() => _tab = i);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        backgroundColor:AppColors.textWhite,
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
