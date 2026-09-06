/// アリーナ・トーナメントシステム例

import 'package:flutter/material.dart';
import '../models/arena_tournaments_system.dart';

void main() {
  runApp(const ArenaTournamentsExample());
}

class ArenaTournamentsExample extends StatefulWidget {
  const ArenaTournamentsExample({Key? key}) : super(key: key);

  @override
  State<ArenaTournamentsExample> createState() =>
      _ArenaTournamentsExampleState();
}

class _ArenaTournamentsExampleState extends State<ArenaTournamentsExample> {
  final system = ArenaTournamentsSystem.getInstance();
  int selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    system.initialize();
    _addDemoData();
  }

  void _addDemoData() {
    // Create tournament
    system.createTournament(
      'tournament_001',
      'Spring Arena Championship',
      'season_001',
      16,
      500,
    );

    // Register players
    system.registerForTournament('tournament_001', 'player_001');
    system.registerForTournament('tournament_001', 'player_002');
    system.registerForTournament('tournament_001', 'player_003');
    system.registerForTournament('tournament_001', 'player_004');

    // Start tournament
    system.startTournament('tournament_001');

    // Simulate arena matches
    system.arrangeArenaMatch('match_001', 'player_001', 'player_002');
    system.completeArenaMatch('match_001', 'player_001', 450, 350);

    system.arrangeArenaMatch('match_002', 'player_003', 'player_004');
    system.completeArenaMatch('match_002', 'player_004', 380, 420);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arena & Tournaments',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(title: const Text('アリーナ・トーナメントシステム')),
        body: IndexedStack(
          index: selectedTabIndex,
          children: [
            _buildLeaderboardTab(),
            _buildTournamentsTab(),
            _buildMatchesTab(),
            _buildSeasonsTab(),
            _buildStatsTab(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedTabIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (i) => setState(() => selectedTabIndex = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'ランク'),
            BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'トーナメント'),
            BottomNavigationBarItem(icon: Icon(Icons.sports), label: 'マッチ'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'シーズン'),
            BottomNavigationBarItem(icon: Icon(Icons.analytics), label: '統計'),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    final leaderboard = system.getLeaderboard('season_001');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('アリーナリーダーボード',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('${leaderboard.length}人のプレイヤー',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...leaderboard.map((entry) {
          final tierColor = entry.tier == 'Legendary'
              ? Colors.amber
              : entry.tier == 'Diamond'
                  ? Colors.cyan
                  : entry.tier == 'Platinum'
                      ? Colors.grey
                      : entry.tier == 'Gold'
                          ? Colors.orange
                          : Colors.blue;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('#${entry.rank}',
                                  style: const TextStyle(
                                      fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(entry.playerId,
                                  style: const TextStyle(
                                      fontSize: 14, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${entry.wins}勝 ${entry.losses}敗',
                                style: const TextStyle(fontSize: 12)),
                            Text('勝率: ${entry.winRate}%',
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: tierColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          entry.tier,
                          style: TextStyle(
                            fontSize: 12,
                            color: tierColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('${entry.rating}',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTournamentsTab() {
    final tournaments = system.getActiveTournaments();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('トーナメント',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('${tournaments.length}件進行中',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (tournaments.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text('トーナメントがありません',
                    style: TextStyle(color: Colors.grey[600])),
              ),
            ),
          )
        else
          ...tournaments.map((tournament) {
            final filled = (tournament.participants.length / tournament.maxPlayers * 100)
                .toInt();

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tournament.name,
                                  style: const TextStyle(
                                      fontSize: 14, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('入場料: ${tournament.entryFee}G',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: tournament.status == 'active'
                                ? Colors.green.withOpacity(0.2)
                                : Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tournament.status == 'active' ? '進行中' : '募集中',
                            style: TextStyle(
                              fontSize: 12,
                              color: tournament.status == 'active'
                                  ? Colors.green
                                  : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            '参加者: ${tournament.participants.length}/${tournament.maxPlayers}',
                            style: const TextStyle(fontSize: 12)),
                        Text('報酬プール: ${tournament.rewardPool}G',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: filled / 100,
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildMatchesTab() {
    const matches = [
      {
        'player1': 'player_001',
        'player2': 'player_002',
        'status': 'completed',
        'winner': 'player_001',
        'duration': 120,
      },
      {
        'player1': 'player_003',
        'player2': 'player_004',
        'status': 'completed',
        'winner': 'player_004',
        'duration': 145,
      },
      {
        'player1': 'player_005',
        'player2': 'player_001',
        'status': 'active',
        'winner': null,
        'duration': 0,
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('アリーナマッチ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('${matches.length}件のマッチ',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...matches.map((match) {
          final isCompleted = match['status'] == 'completed';

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                            '${match['player1']} vs ${match['player2']}',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? Colors.green.withOpacity(0.2)
                              : Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isCompleted ? '完了' : '進行中',
                          style: TextStyle(
                            fontSize: 12,
                            color: isCompleted ? Colors.green : Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (isCompleted)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('勝者: ${match['winner']}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
                            Text('持続時間: ${match['duration']}秒',
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    )
                  else
                    const Text('進行中...',
                        style: TextStyle(fontSize: 12, color: Colors.blue)),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSeasonsTab() {
    final season = system.getActiveSeason();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('シーズン情報',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (season != null) ...[
                  Text(season.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('シーズン番号',
                              style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text('${season.number}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('報酬プール',
                              style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text('${season.rewardPool}G',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: season.status == 'active'
                          ? Colors.green.withOpacity(0.2)
                          : Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      season.status == 'active' ? 'アクティブ' : '次期予定',
                      style: TextStyle(
                        fontSize: 12,
                        color: season.status == 'active'
                            ? Colors.green
                            : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('残り時間',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text('${season.getDaysRemaining()}日',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsTab() {
    const playerStats = [
      {
        'player': 'player_001',
        'rating': 1800,
        'tier': 'Diamond',
        'wins': 25,
        'losses': 8,
      },
      {
        'player': 'player_002',
        'rating': 1650,
        'tier': 'Platinum',
        'wins': 20,
        'losses': 12,
      },
      {
        'player': 'player_003',
        'rating': 1500,
        'tier': 'Gold',
        'wins': 18,
        'losses': 15,
      },
      {
        'player': 'player_004',
        'rating': 1400,
        'tier': 'Gold',
        'wins': 15,
        'losses': 18,
      },
      {
        'player': 'player_005',
        'rating': 1300,
        'tier': 'Silver',
        'wins': 12,
        'losses': 20,
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('プレイヤー統計',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('${playerStats.length}人のアリーナ戦士',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...playerStats.map((stat) {
          final winRate = (((stat['wins'] as int) / ((stat['wins'] as int) + (stat['losses'] as int))) * 100)
              .toInt();

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(stat['player'].toString(),
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          stat['tier'].toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('レート: ${stat['rating']}',
                              style: const TextStyle(fontSize: 12)),
                          Text('${stat['wins']}勝 ${stat['losses']}敗',
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      Text('勝率: $winRate%',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: winRate / 100,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
