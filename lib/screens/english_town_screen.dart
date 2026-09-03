import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/english_town_model.dart';
import '../providers/english_town_provider.dart';
import '../theme/app_theme.dart';

class EnglishTownScreen extends ConsumerStatefulWidget {
  const EnglishTownScreen({super.key});

  @override
  ConsumerState<EnglishTownScreen> createState() => _EnglishTownScreenState();
}

class _EnglishTownScreenState extends ConsumerState<EnglishTownScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedAreaId;
  String? _selectedNPCId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🕹️ 英語だけの街'),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '町の探索'),
            Tab(text: 'NPC会話'),
            Tab(text: 'プロフィール'),
            Tab(text: '統計'),
            Tab(text: '設定'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExplorationTab(),
          _buildConversationTab(),
          _buildProfileTab(),
          _buildStatisticsTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  Widget _buildExplorationTab() {
    final areas = ref.watch(townAreasProvider);
    final progress = ref.watch(townProgressProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Town Map Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kPrimaryColor.withAlpha(51), kPrimaryColor.withAlpha(26)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '英語だけの街へようこそ！',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '${progress.visitedAreas}/${areas.length}エリアを訪問',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress.visitedAreas / areas.length,
                    minHeight: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Areas Grid
          Text(
            'エリア一覧',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: areas.length,
            itemBuilder: (context, index) {
              final area = areas[index];
              return _buildAreaCard(area);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAreaCard(TownArea area) {
    return GestureDetector(
      onTap: area.isUnlocked
          ? () {
              setState(() => _selectedAreaId = area.areaId);
              _showAreaDetails(area);
            }
          : null,
      child: Card(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: area.isUnlocked ? Colors.white : Colors.grey[200],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      area.backgroundTile,
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      area.japaneseName,
                      style: Theme.of(context).textTheme.titleSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lv ${area.difficultyLevel}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            if (!area.isUnlocked)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.lock,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            if (area.progressPercentage > 0)
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Text(
                  '進捗: ${area.progressPercentage}%',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAreaDetails(TownArea area) {
    final npcs = ref.read(npcsProvider).where((npc) => npc.areaId == area.areaId);

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              area.japaneseName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              area.englishName,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              area.description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Text(
              'このエリアのNPC',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...npcs.map((npc) => ListTile(
              leading: Text(npc.emoji, style: const TextStyle(fontSize: 24)),
              title: Text(npc.name),
              subtitle: Text(npc.profession),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedNPCId = npc.npcId);
                _showNPCConversation(npc);
              },
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationTab() {
    final npcs = ref.watch(npcsProvider);
    final conversations = ref.watch(conversationsProvider);

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: 'NPC (${npcs.length})'),
              Tab(text: '会話履歴 (${conversations.length})'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildNPCList(npcs),
                _buildConversationHistory(conversations),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNPCList(List<NPC> npcs) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: npcs.length,
      itemBuilder: (context, index) {
        final npc = npcs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Text(npc.emoji, style: const TextStyle(fontSize: 32)),
            title: Text(npc.name),
            subtitle: Text(npc.profession),
            trailing: Text(
              '${npc.talkCount}回',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            onTap: () => _showNPCConversation(npc),
          ),
        );
      },
    );
  }

  void _showNPCConversation(NPC npc) {
    if (npc.conversationPhrases.isEmpty) return;

    final phrase = npc.conversationPhrases[0];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(npc.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 8),
            Expanded(child: Text(npc.name)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phrase,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('(タップして音声を再生)'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '『学習テーマ』',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(npc.learningTheme),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(npcsProvider.notifier).recordTalk(npc.npcId);
              ref.read(townProgressProvider.notifier).updateProgress(
                currentAreaId: npc.areaId,
                currentNPCId: npc.npcId,
                coinsEarned: 10,
                learningPoints: 5,
                responseScore: 80,
                isCorrect: true,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('会話を記録しました！+10コイン +5ポイント')),
              );
            },
            child: const Text('応答する'),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationHistory(List<Conversation> conversations) {
    if (conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.message, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('会話履歴がありません', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conv = conversations[conversations.length - 1 - index];
        final npc = ref.read(npcsProvider).firstWhere(
              (n) => n.npcId == conv.npcId,
            );

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Text(npc.emoji, style: const TextStyle(fontSize: 24)),
            title: Text('${npc.name} - ${conv.responseScore}点'),
            subtitle: Text(
              DateFormat('yyyy/MM/dd HH:mm').format(conv.conversationAt),
            ),
            trailing: conv.isResponseCorrect
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.cancel, color: Colors.red),
          ),
        );
      },
    );
  }

  Widget _buildProfileTab() {
    final profile = ref.watch(townPlayerProfileProvider);
    final progress = ref.watch(townProgressProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Player Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    profile.playerCharacter,
                    style: const TextStyle(fontSize: 64),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'レベル ${profile.level}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: profile.experience / 500,
                    minHeight: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '経験値: ${profile.experience}/500',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard('コイン', '${profile.currentCoins}', '💰'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('単語', '${profile.uniqueWordsLearned}', '📚'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('バッジ', '${profile.badgesEarned.length}', '🏆'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('会話数', '${progress.totalConversations}', '💬'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Achievements
          Text(
            '獲得バッジ',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          if (profile.badgesEarned.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'バッジを獲得してください',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: profile.badgesEarned.map((badge) {
                return Chip(label: Text(badge));
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String emoji) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsTab() {
    final stats = ref.watch(townStatsProvider);
    final progress = ref.watch(townProgressProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '全体統計',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),

          // Stats Cards
          _buildStatsRow('総プレイ時間', '${stats.totalPlayTime}分'),
          _buildStatsRow('総会話数', '${stats.totalConversations}'),
          _buildStatsRow('平均スコア', '${(stats.averageScore * 100).toStringAsFixed(1)}%'),
          _buildStatsRow('最高スコア', '${stats.highScore}'),
          const SizedBox(height: 20),

          // Learning Stats
          Text(
            '学習統計',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _buildStatsRow('習得単語数', '${stats.totalWordsLearned}'),
          _buildStatsRow('総獲得コイン', '${stats.totalCoinsEarned}'),
          _buildStatsRow('獲得バッジ', '${stats.badgesCount}'),
          const SizedBox(height: 20),

          // Streaks
          Text(
            'ストリーク',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _buildStatsRow('訪問日数', '${stats.visitDays}日'),
          _buildStatsRow('連続訪問', '${stats.consecutiveVisitDays}日'),
          const SizedBox(height: 20),

          // Top Info
          if (stats.mostVisitedArea != null)
            Text(
              '最も訪問したエリア: ${stats.mostVisitedArea}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          if (stats.mostTalkedNPC != null)
            Text(
              '最も会話したNPC: ${stats.mostTalkedNPC}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text(
          '設定',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 20),
        SwitchListTile(
          title: const Text('背景音楽'),
          subtitle: const Text('町の探索時にBGMを再生します'),
          value: true,
          onChanged: (value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('BGMを${value ? 'ON' : 'OFF'}にしました')),
            );
          },
        ),
        SwitchListTile(
          title: const Text('自動字幕'),
          subtitle: const Text('NPCの会話に日本語字幕を表示'),
          value: true,
          onChanged: (value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('字幕を${value ? 'ON' : 'OFF'}にしました')),
            );
          },
        ),
        SwitchListTile(
          title: const Text('音声フィードバック'),
          subtitle: const Text('会話の成功/失敗で音を再生'),
          value: true,
          onChanged: (value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('音声フィードバックを${value ? 'ON' : 'OFF'}にしました')),
            );
          },
        ),
        const Divider(height: 32),
        SwitchListTile(
          title: const Text('難易度：ハード'),
          subtitle: const Text('より難しい会話が出現します'),
          value: false,
          onChanged: (value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('難易度を${value ? 'ハード' : 'ノーマル'}にしました')),
            );
          },
        ),
        SwitchListTile(
          title: const Text('親への共有'),
          subtitle: const Text('親アカウントと進捗を共有'),
          value: false,
          onChanged: (value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('親への共有を${value ? '有効' : '無効'}にしました')),
            );
          },
        ),
        const Divider(height: 32),
        ListTile(
          title: const Text('データをリセット'),
          subtitle: const Text('すべての進捗データを削除します'),
          trailing: const Icon(Icons.delete_outline),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('確認'),
                content: const Text('本当にリセットしますか？この操作は戻せません。'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('キャンセル'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('データをリセットしました')),
                      );
                    },
                    child: const Text('リセット'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
