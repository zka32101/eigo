import '../design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart'
    show globalRankingProvider, GlobalRankingEntry, missionProvider;
import '../providers/speaking_history_provider.dart';
import '../providers/user_profile_provider.dart';
import '../services/firebase_service.dart';

class RankingScreen extends ConsumerStatefulWidget {
  const RankingScreen({super.key});

  @override
  ConsumerState<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends ConsumerState<RankingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // 初期化時に全ランキングを取得
    Future.microtask(() async {
      final globalRanking = ref.read(globalRankingProvider.notifier);

      // グローバルランキング（全7アプリ合計）
      await globalRanking.fetchGlobalRanking();

      // 教科別ランキング（英語）
      await globalRanking.fetchSubjectRanking('english');
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final globalRankingState = ref.watch(globalRankingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ランキング'),
        elevation: 0,
        backgroundColor: AppColors.accentOrange,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'グローバル'),
            Tab(text: '教科別'),
            Tab(text: 'フレンド'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 0: グローバルランキング（全7アプリ合計）
          _GlobalRankingTabView(
            entries: globalRankingState.globalEntries,
            isLoading: globalRankingState.isLoading,
            error: globalRankingState.error,
            onRefresh: () async {
              await ref.read(globalRankingProvider.notifier).fetchGlobalRanking();
            },
          ),
          // Tab 1: 教科別ランキング（英語）
          _SubjectRankingTabView(
            entries: globalRankingState.subjectEntries,
            subject: '英語',
            isLoading: globalRankingState.isLoading,
            error: globalRankingState.error,
            onRefresh: () async {
              await ref
                  .read(globalRankingProvider.notifier)
                  .fetchSubjectRanking('english');
            },
          ),
          // Tab 2: フレンドランキング
          _FriendRankingTabView(),
        ],
      ),
    );
  }
}

/// グローバルランキング表示タブ
class _GlobalRankingTabView extends StatelessWidget {
  final List<GlobalRankingEntry> entries;
  final bool isLoading;
  final String? error;
  final Future<void> Function() onRefresh;

  const _GlobalRankingTabView({
    required this.entries,
    required this.isLoading,
    required this.error,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && entries.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accentOrange),
      );
    }

    if (error != null && entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 64, color: Colors.grey.shade400),
            SizedBox(height: AppSpacing.md),
            Text('エラー: $error'),
            SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: onRefresh,
              child: const Text('再度読み込む'),
            ),
          ],
        ),
      );
    }

    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.leaderboard,
                size: 64, color: Colors.grey.shade400),
            SizedBox(height: AppSpacing.md),
            const Text('ランキングデータがありません'),
            SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: onRefresh,
              child: const Text('読み込む'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: EdgeInsets.all(AppSpacing.md),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return _RankEntryCard(
            rank: index + 1,
            displayName: entry.displayName,
            score: entry.score,
            isMe: entry.isCurrentUser,
            subject: '(全7科合計)',
          );
        },
      ),
    );
  }
}

/// 教科別ランキング表示タブ
class _SubjectRankingTabView extends StatelessWidget {
  final List<GlobalRankingEntry> entries;
  final String subject;
  final bool isLoading;
  final String? error;
  final Future<void> Function() onRefresh;

  const _SubjectRankingTabView({
    required this.entries,
    required this.subject,
    required this.isLoading,
    required this.error,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && entries.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accentOrange),
      );
    }

    if (error != null && entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 64, color: Colors.grey.shade400),
            SizedBox(height: AppSpacing.md),
            Text('エラー: $error'),
            SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: onRefresh,
              child: const Text('再度読み込む'),
            ),
          ],
        ),
      );
    }

    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.leaderboard,
                size: 64, color: Colors.grey.shade400),
            SizedBox(height: AppSpacing.md),
            Text('$subjectのランキングデータがありません'),
            SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: onRefresh,
              child: const Text('読み込む'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: EdgeInsets.all(AppSpacing.md),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return _RankEntryCard(
            rank: index + 1,
            displayName: entry.displayName,
            score: entry.score,
            isMe: entry.isCurrentUser,
            subject: subject,
          );
        },
      ),
    );
  }
}

/// フレンドランキング表示タブ（既存のスピーキングランキング）
class _FriendRankingTabView extends ConsumerStatefulWidget {
  const _FriendRankingTabView();

  @override
  ConsumerState<_FriendRankingTabView> createState() =>
      _FriendRankingTabViewState();
}

class _FriendRankingTabViewState extends ConsumerState<_FriendRankingTabView> {
  List<Map<String, dynamic>> _ranking = [];
  bool _loading = true;
  bool _firebaseAvailable = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final fb = FirebaseService();
    _firebaseAvailable = fb.isAvailable;

    if (_firebaseAvailable) {
      final data = await fb.fetchWeeklyRanking();
      setState(() {
        _ranking = data;
        _loading = false;
      });
    } else {
      // Firebase 未接続 → ローカルデモデータ
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _ranking = _buildDemoRanking();
        _loading = false;
      });
    }
  }

  List<Map<String, dynamic>> _buildDemoRanking() {
    final history = ref.read(speakingHistoryProvider);
    final myScore = history.weeklyAvgScore;
    final myCount = history.weeklyWordCount +
        history.weeklyPhraseCount +
        history.weeklyConversationCount;

    return [
      {
        'displayName': 'はなちゃん',
        'avgScore': 92.0,
        'practiceCount': 45,
        'uid': 'demo1',
        'showName': true
      },
      {
        'displayName': 'けんた',
        'avgScore': 88.0,
        'practiceCount': 38,
        'uid': 'demo2',
        'showName': false
      },
      {
        'displayName': 'さくら',
        'avgScore': 85.0,
        'practiceCount': 42,
        'uid': 'demo3',
        'showName': true
      },
      {
        'displayName': 'あなた',
        'avgScore': myScore,
        'practiceCount': myCount,
        'uid': 'me',
        'showName': false
      },
      {
        'displayName': 'ゆうき',
        'avgScore': 79.0,
        'practiceCount': 28,
        'uid': 'demo4',
        'showName': false
      },
      {
        'displayName': 'みさき',
        'avgScore': 75.0,
        'practiceCount': 33,
        'uid': 'demo5',
        'showName': true
      },
      {
        'displayName': 'りょう',
        'avgScore': 72.0,
        'practiceCount': 20,
        'uid': 'demo6',
        'showName': false
      },
      {
        'displayName': 'あやか',
        'avgScore': 68.0,
        'practiceCount': 25,
        'uid': 'demo7',
        'showName': false
      },
    ]..sort((a, b) =>
        (b['avgScore'] as double).compareTo(a['avgScore'] as double));
  }

  String _getDisplayName(
      String actualName, String uid, bool isMe, bool showName) {
    if (isMe) return actualName;
    if (showName) return actualName;
    return 'ユーザー #${uid.hashCode.abs() % 10000}';
  }

  @override
  Widget build(BuildContext context) {
    final myUserId = FirebaseService().userId;

    return Scaffold(
      body: Column(
        children: [
          // ヘッダー
          Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            color: AppColors.accentOrange.withAlpha(20),
            child: Column(
              children: [
                Text(
                  _firebaseAvailable
                      ? '今週のスピーキングランキング'
                      : '今週のスピーキングランキング（デモ）',
                  style: AppTypography.labelLarge
                      .copyWith(color: AppColors.textPrimary),
                ),
                SizedBox(height: AppSpacing.xs),
                const Text(
                  '週次の平均スピーキングスコアで順位が決まります',
                  style:
                      AppTypography.bodySmall,
                  textAlign: TextAlign.center,
                ),
                if (!_firebaseAvailable) ...[
                  SizedBox(height: AppSpacing.xs),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange.withAlpha(30),
                      borderRadius:
                          BorderRadius.circular(AppSizes.borderRadius),
                    ),
                    child: const Text(
                      '⚠️ オフラインモード: Firebase接続後に実際のランキングが表示されます',
                      style: AppTypography.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // ランキングリスト
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.accentOrange))
                : _ranking.isEmpty
                    ? const Center(
                        child: Text('ランキングデータがありません',
                            style:
                                TextStyle(color: AppColors.textMuted)))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: EdgeInsets.all(AppSpacing.lg),
                          itemCount: _ranking.length,
                          itemBuilder: (_, i) {
                            final item = _ranking[i];
                            final rank = i + 1;
                            final isMe = item['uid'] == myUserId ||
                                item['uid'] == 'me';
                            final score =
                                (item['avgScore'] as num).toDouble();
                            final count =
                                (item['practiceCount'] as num).toInt();
                            final name = item['displayName'] as String;
                            final uid = item['uid'] as String;
                            final showName =
                                item['showName'] as bool? ?? false;
                            final displayName =
                                _getDisplayName(name, uid, isMe, showName);

                            return _FriendRankCard(
                              rank: rank,
                              displayName: displayName,
                              score: score,
                              practiceCount: count,
                              isMe: isMe,
                            );
                          },
                        ),
                      ),
          ),
          // 参加ボタン
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.emoji_events),
                  label: const Text('スピーキング練習してランキングに参加！'),
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/speaking-practice'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentOrange,
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ランキングエントリカード（グローバル/教科別）
class _RankEntryCard extends StatelessWidget {
  final int rank;
  final String displayName;
  final int score;
  final bool isMe;
  final String subject;

  const _RankEntryCard({
    required this.rank,
    required this.displayName,
    required this.score,
    required this.isMe,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    final rankEmoji = rank == 1
        ? '🥇'
        : rank == 2
            ? '🥈'
            : rank == 3
                ? '🥉'
                : '$rank.';
    final rankColor = rank == 1
        ? const Color(0xFFFFD700)
        : rank == 2
            ? const Color(0xFFC0C0C0)
            : rank == 3
                ? const Color(0xFFCD7F32)
                : AppColors.textMuted;

    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      color:
          isMe ? AppColors.accentOrange.withAlpha(15) : AppColors.textWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
        side: isMe
            ? const BorderSide(color: AppColors.accentOrange, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          children: [
            // 順位
            SizedBox(
              width: 40,
              child: Text(
                rankEmoji,
                style: TextStyle(
                  fontSize: rank <= 3 ? 24 : 16,
                  fontWeight: FontWeight.bold,
                  color: rankColor,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            // 名前と科目
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        displayName,
                        style: AppTypography.labelLarge.copyWith(
                          color: isMe
                              ? AppColors.accentOrange
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (isMe) ...[
                        SizedBox(width: AppSpacing.xs),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: AppColors.accentOrange.withAlpha(26),
                            borderRadius: BorderRadius.circular(
                                AppSizes.borderRadiusSmall),
                          ),
                          child: Text('あなた',
                              style: AppTypography.bodySmall.copyWith(
                                  fontSize: 10,
                                  color: AppColors.accentOrange,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    subject,
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            // スコア
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$score点',
                  style: AppTypography.labelLarge.copyWith(
                    fontSize: 20,
                    color: score >= 85
                        ? AppColors.accentGreen
                        : score >= 70
                            ? AppColors.accentOrange
                            : AppColors.textMuted,
                  ),
                ),
                Text(
                  'スコア',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// フレンドランキングカード
class _FriendRankCard extends StatelessWidget {
  final int rank;
  final String displayName;
  final double score;
  final int practiceCount;
  final bool isMe;

  const _FriendRankCard({
    required this.rank,
    required this.displayName,
    required this.score,
    required this.practiceCount,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final rankEmoji = rank == 1
        ? '🥇'
        : rank == 2
            ? '🥈'
            : rank == 3
                ? '🥉'
                : '$rank.';
    final rankColor = rank == 1
        ? const Color(0xFFFFD700)
        : rank == 2
            ? const Color(0xFFC0C0C0)
            : rank == 3
                ? const Color(0xFFCD7F32)
                : AppColors.textMuted;

    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      color:
          isMe ? AppColors.accentOrange.withAlpha(15) : AppColors.textWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
        side: isMe
            ? const BorderSide(color: AppColors.accentOrange, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          children: [
            // 順位
            SizedBox(
              width: 40,
              child: Text(
                rankEmoji,
                style: TextStyle(
                  fontSize: rank <= 3 ? 24 : 16,
                  fontWeight: FontWeight.bold,
                  color: rankColor,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            // 名前
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        displayName,
                        style: AppTypography.labelLarge.copyWith(
                          color: isMe
                              ? AppColors.accentOrange
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (isMe) ...[
                        SizedBox(width: AppSpacing.xs),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: AppColors.accentOrange.withAlpha(26),
                            borderRadius: BorderRadius.circular(
                                AppSizes.borderRadiusSmall),
                          ),
                          child: Text('あなた',
                              style: AppTypography.bodySmall.copyWith(
                                  fontSize: 10,
                                  color: AppColors.accentOrange,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    '練習 $practiceCount回',
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            // スコア
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${score.round()}点',
                  style: AppTypography.labelLarge.copyWith(
                    fontSize: 20,
                    color: score >= 85
                        ? AppColors.accentGreen
                        : score >= 70
                            ? AppColors.accentOrange
                            : AppColors.textMuted,
                  ),
                ),
                Text('平均',
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
