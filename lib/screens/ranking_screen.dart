import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/speaking_history_provider.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';
import '../theme/spacing.dart';
import '../theme/sizes.dart';
import '../theme/typography.dart';

class RankingScreen extends ConsumerStatefulWidget {
  const RankingScreen({super.key});

  @override
  ConsumerState<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends ConsumerState<RankingScreen> {
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
      setState(() { _ranking = data; _loading = false; });
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
    final myCount = history.weeklyWordCount + history.weeklyPhraseCount + history.weeklyConversationCount;

    return [
      {'displayName': 'はなちゃん', 'avgScore': 92.0, 'practiceCount': 45, 'uid': 'demo1'},
      {'displayName': 'けんた', 'avgScore': 88.0, 'practiceCount': 38, 'uid': 'demo2'},
      {'displayName': 'さくら', 'avgScore': 85.0, 'practiceCount': 42, 'uid': 'demo3'},
      {'displayName': 'あなた', 'avgScore': myScore, 'practiceCount': myCount, 'uid': 'me'},
      {'displayName': 'ゆうき', 'avgScore': 79.0, 'practiceCount': 28, 'uid': 'demo4'},
      {'displayName': 'みさき', 'avgScore': 75.0, 'practiceCount': 33, 'uid': 'demo5'},
      {'displayName': 'りょう', 'avgScore': 72.0, 'practiceCount': 20, 'uid': 'demo6'},
      {'displayName': 'あやか', 'avgScore': 68.0, 'practiceCount': 25, 'uid': 'demo7'},
    ]..sort((a, b) => (b['avgScore'] as double).compareTo(a['avgScore'] as double));
  }

  @override
  Widget build(BuildContext context) {
    final myUserId = FirebaseService().userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🏅 週次ランキング'),
        backgroundColor: kAccentOrange,
      ),
      body: Column(
        children: [
          // ヘッダー
          Container(
            padding: AppSpacing.allPaddingLg,
            color: kAccentOrange.withAlpha(20),
            child: Column(
              children: [
                Text(
                  _firebaseAvailable ? '今週のスピーキングランキング' : '今週のスピーキングランキング（デモ）',
                  style: AppTypography.labelLarge.copyWith(color: kTextDark),
                ),
                AppSpacing.verticalSpacerXs,
                const Text(
                  '週次の平均スピーキングスコアで順位が決まります',
                  style: AppTypography.bodySmall.copyWith(color: kTextMuted),
                ),
                if (!_firebaseAvailable) ...[
                  AppSpacing.verticalSpacerXs,
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: kAccentOrange.withAlpha(30),
                      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                    ),
                    child: const Text(
                      '⚠️ オフラインモード: Firebase 接続後に実際のランキングが表示されます',
                      style: AppTypography.bodySmall.copyWith(color: kAccentOrange),
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
                ? const Center(child: CircularProgressIndicator(color: kAccentOrange))
                : _ranking.isEmpty
                    ? const Center(child: Text('ランキングデータがありません', style: TextStyle(color: kTextMuted)))
                    : ListView.builder(
                        padding: AppSpacing.allPaddingLg,
                        itemCount: _ranking.length,
                        itemBuilder: (_, i) {
                          final item = _ranking[i];
                          final rank = i + 1;
                          final isMe = item['uid'] == myUserId || item['uid'] == 'me';
                          final score = (item['avgScore'] as num).toDouble();
                          final count = (item['practiceCount'] as num).toInt();
                          final name = item['displayName'] as String;

                          return _RankCard(
                            rank: rank,
                            name: name,
                            score: score,
                            practiceCount: count,
                            isMe: isMe,
                          );
                        },
                      ),
          ),
          // 参加ボタン
          SafeArea(
            child: Padding(
              padding: AppSpacing.allPaddingLg,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.emoji_events),
                  label: const Text('スピーキング練習してランキングに参加！'),
                  onPressed: () => Navigator.of(context).pushNamed('/speaking-practice'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccentOrange,
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

class _RankCard extends StatelessWidget {
  final int rank;
  final String name;
  final double score;
  final int practiceCount;
  final bool isMe;

  const _RankCard({
    required this.rank,
    required this.name,
    required this.score,
    required this.practiceCount,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final rankEmoji = rank == 1 ? '🥇' : rank == 2 ? '🥈' : rank == 3 ? '🥉' : '$rank.';
    final rankColor = rank == 1
        ? const Color(0xFFFFD700)
        : rank == 2
            ? const Color(0xFFC0C0C0)
            : rank == 3
                ? const Color(0xFFCD7F32)
                : kTextMuted;

    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      color: isMe ? kPrimaryColor.withAlpha(15) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
        side: isMe ? const BorderSide(color: kPrimaryColor, width: 2) : BorderSide.none,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
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
            AppSpacing.horizontalSpacerSm,
            // 名前
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: AppTypography.labelLarge.copyWith(
                          color: isMe ? kPrimaryColor : kTextDark,
                        ),
                      ),
                      if (isMe) ...[
                        AppSpacing.horizontalSpacerXs,
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: kPrimaryColor.withAlpha(26),
                            borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                          ),
                          child: Text('あなた', style: AppTypography.bodySmall.copyWith(fontSize: 10, color: kPrimaryColor, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    '練習 $practiceCount回',
                    style: AppTypography.bodySmall.copyWith(color: kTextMuted),
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
                    color: score >= 85 ? kAccentGreen : score >= 70 ? kPrimaryColor : kTextMuted,
                  ),
                ),
                Text('平均', style: AppTypography.bodySmall.copyWith(color: kTextMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
