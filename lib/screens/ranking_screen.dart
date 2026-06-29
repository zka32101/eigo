import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/speaking_history_provider.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';

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
            padding: const EdgeInsets.all(16),
            color: kAccentOrange.withAlpha(20),
            child: Column(
              children: [
                Text(
                  _firebaseAvailable ? '今週のスピーキングランキング' : '今週のスピーキングランキング（デモ）',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kTextDark),
                ),
                const SizedBox(height: 4),
                const Text(
                  '週次の平均スピーキングスコアで順位が決まります',
                  style: TextStyle(fontSize: 12, color: kTextMuted),
                ),
                if (!_firebaseAvailable) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: kAccentOrange.withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '⚠️ オフラインモード: Firebase 接続後に実際のランキングが表示されます',
                      style: TextStyle(fontSize: 11, color: kAccentOrange),
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
                        padding: const EdgeInsets.all(16),
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
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.emoji_events),
                  label: const Text('スピーキング練習してランキングに参加！'),
                  onPressed: () => Navigator.of(context).pushNamed('/speaking-practice'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccentOrange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
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
      margin: const EdgeInsets.only(bottom: 10),
      color: isMe ? kPrimaryColor.withAlpha(15) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isMe ? const BorderSide(color: kPrimaryColor, width: 2) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            const SizedBox(width: 12),
            // 名前
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isMe ? kPrimaryColor : kTextDark,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: kPrimaryColor.withAlpha(26),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('あなた', style: TextStyle(fontSize: 10, color: kPrimaryColor, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    '練習 $practiceCount回',
                    style: const TextStyle(fontSize: 12, color: kTextMuted),
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
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: score >= 85 ? kAccentGreen : score >= 70 ? kPrimaryColor : kTextMuted,
                  ),
                ),
                const Text('平均', style: TextStyle(fontSize: 11, color: kTextMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
