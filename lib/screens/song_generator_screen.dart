import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/song_generator_model.dart';
import '../providers/song_generator_provider.dart';
import '../theme/app_theme.dart';

class SongGeneratorScreen extends ConsumerStatefulWidget {
  const SongGeneratorScreen({super.key});

  @override
  ConsumerState<SongGeneratorScreen> createState() =>
      _SongGeneratorScreenState();
}

class _SongGeneratorScreenState extends ConsumerState<SongGeneratorScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _vocabularyController = TextEditingController();
  String _selectedMelody = 'twinkleTwinkleLittleStar';
  String _selectedTheme = 'animals';
  String _selectedLevel = 'beginner';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _vocabularyController.dispose();
    super.dispose();
  }

  void _generateSong() {
    final vocabularyInput = _vocabularyController.text.trim();
    if (vocabularyInput.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('語彙を入力してください')),
      );
      return;
    }

    final vocabularyWords =
        vocabularyInput.split(',').map((w) => w.trim()).toList();

    final request = SongGenerationRequest(
      requestId: 'req_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user_001',
      vocabularyWords: vocabularyWords,
      melodyType: _selectedMelody,
      theme: _selectedTheme,
      learningLevel: _selectedLevel,
      lyricLanguage: 'en',
      createdAt: DateTime.now(),
    );

    ref
        .read(songGenerationRequestProvider.notifier)
        .addRequest(request)
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('曲を生成しました！')),
      );
      _vocabularyController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎵 AI替え歌ジェネレーター'),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '生成'),
            Tab(text: '作品'),
            Tab(text: 'ライブラリ'),
            Tab(text: '統計'),
            Tab(text: '設定'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGenerationTab(),
          _buildWorksTab(),
          _buildLibraryTab(),
          _buildStatisticsTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  Widget _buildGenerationTab() {
    final melodies = ref.watch(melodyTemplatesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '新しい曲を作成',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),

          // Vocabulary Input
          Text(
            '学習語彙（カンマ区切り）',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _vocabularyController,
            decoration: InputDecoration(
              hintText: '例: apple, cat, run',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.library_books),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 20),

          // Melody Selection
          Text(
            'メロディ選択',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: kPrimaryColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<String>(
              value: _selectedMelody,
              isExpanded: true,
              underline: const SizedBox(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              items: melodies.map((melody) {
                return DropdownMenuItem(
                  value: melody.name,
                  child: Text(
                    '${melody.displayName} - ${melody.englishName}',
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedMelody = value ?? _selectedMelody);
              },
            ),
          ),
          const SizedBox(height: 20),

          // Theme Selection
          Text(
            'テーマ選択',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: kPrimaryColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<String>(
              value: _selectedTheme,
              isExpanded: true,
              underline: const SizedBox(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              items: const [
                DropdownMenuItem(
                  value: 'animals',
                  child: Text('🐱 動物 (Animals)'),
                ),
                DropdownMenuItem(
                  value: 'food',
                  child: Text('🍎 食べ物 (Food)'),
                ),
                DropdownMenuItem(
                  value: 'colors',
                  child: Text('🎨 色 (Colors)'),
                ),
                DropdownMenuItem(
                  value: 'daily_life',
                  child: Text('🏠 日常生活 (Daily Life)'),
                ),
                DropdownMenuItem(
                  value: 'nature',
                  child: Text('🌳 自然 (Nature)'),
                ),
              ],
              onChanged: (value) {
                setState(() => _selectedTheme = value ?? _selectedTheme);
              },
            ),
          ),
          const SizedBox(height: 20),

          // Learning Level Selection
          Text(
            '学習レベル',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: kPrimaryColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<String>(
              value: _selectedLevel,
              isExpanded: true,
              underline: const SizedBox(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              items: const [
                DropdownMenuItem(
                  value: 'beginner',
                  child: Text('初級 (Beginner)'),
                ),
                DropdownMenuItem(
                  value: 'intermediate',
                  child: Text('中級 (Intermediate)'),
                ),
                DropdownMenuItem(
                  value: 'advanced',
                  child: Text('上級 (Advanced)'),
                ),
              ],
              onChanged: (value) {
                setState(() => _selectedLevel = value ?? _selectedLevel);
              },
            ),
          ),
          const SizedBox(height: 30),

          // Generate Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _generateSong,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '🎵 曲を生成する',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildWorksTab() {
    final generatedSongs = ref.watch(generatedSongsProvider);

    if (generatedSongs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_note,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              '作品がまだありません',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '「生成」タブで曲を作成してください',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: generatedSongs.length,
      itemBuilder: (context, index) {
        final song = generatedSongs[generatedSongs.length - 1 - index];
        return _buildSongCard(song);
      },
    );
  }

  Widget _buildSongCard(GeneratedSong song) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                    song.melodyType,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Chip(
                  label: Text('${song.ageGroup}才向け'),
                  backgroundColor: kPrimaryColor.withAlpha(51),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '英語歌詞',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 4),
            Text(
              song.englishLyrics,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Text(
              '日本語訳',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 4),
            Text(
              song.japaneseTranslation,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '再生: ${song.playCount}回',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'BPM: ${song.bpm}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (song.audioUrl != null) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      ref
                          .read(generatedSongsProvider.notifier)
                          .recordPlay(song.songId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('再生を記録しました')),
                      );
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('再生'),
                  ),
                  const SizedBox(width: 8),
                ],
                ElevatedButton.icon(
                  onPressed: () {
                    ref
                        .read(generatedSongsProvider.notifier)
                        .rateSong(song.songId, 5);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('⭐⭐⭐⭐⭐ 評価しました')),
                    );
                  },
                  icon: const Icon(Icons.star),
                  label: const Text('評価'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    ref
                        .read(generatedSongsProvider.notifier)
                        .toggleShare(song.songId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('共有しました')),
                    );
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('共有'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLibraryTab() {
    final library = ref.watch(songLibraryProvider);
    final allSongs = ref.watch(generatedSongsProvider);

    final savedSongs =
        allSongs.where((s) => library.savedSongIds.contains(s.songId)).toList();
    final favoriteSongs = allSongs
        .where((s) => library.favoriteSongIds.contains(s.songId))
        .toList();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: '保存済み (${savedSongs.length})'),
              Tab(text: 'お気に入り (${favoriteSongs.length})'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildLibraryList(savedSongs),
                _buildLibraryList(favoriteSongs),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryList(List<GeneratedSong> songs) {
    if (songs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              '曲がありません',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return ListTile(
          leading: const Icon(Icons.music_note),
          title: Text(song.melodyType),
          subtitle: Text('${song.playCount}回再生'),
          trailing: IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              ref
                  .read(songLibraryProvider.notifier)
                  .toggleFavorite(song.songId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('お気に入りを更新しました')),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatisticsTab() {
    final stats = ref.watch(songGenerationStatsProvider);
    final allSongs = ref.watch(generatedSongsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '統計情報',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),

          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '🎵 生成曲数',
                  '${stats.totalSongsGenerated}',
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '⭐ 平均品質',
                  '${(stats.averageQualityScore * 100).toStringAsFixed(0)}%',
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '📚 習得語数',
                  '${stats.totalVocabularyLearned}',
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '🎤 練習時間',
                  '${(stats.totalSingPracticeTime ~/ 60)}分',
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Most Used Melody
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '最も使用されたメロディ',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  stats.mostUsedMelody,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Most Used Theme
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '最も使用されたテーマ',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  stats.mostUsedTheme,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Recent Songs
          Text(
            '最近生成した曲',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          if (allSongs.isEmpty)
            Center(
              child: Text(
                'まだ曲がありません',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: (allSongs.length > 5 ? 5 : allSongs.length),
              itemBuilder: (context, index) {
                final song = allSongs[allSongs.length - 1 - index];
                return ListTile(
                  leading: const Icon(Icons.music_note),
                  title: Text(song.melodyType),
                  subtitle: Text(
                    DateFormat('yyyy/MM/dd HH:mm')
                        .format(song.generatedAt),
                  ),
                  trailing: Text('${song.playCount}回'),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
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
          title: const Text('自動再生'),
          subtitle: const Text('曲生成後、自動的に再生します'),
          value: true,
          onChanged: (value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('自動再生を${value ? 'ON' : 'OFF'}にしました')),
            );
          },
        ),
        SwitchListTile(
          title: const Text('ループ再生'),
          subtitle: const Text('曲を繰り返し再生します'),
          value: false,
          onChanged: (value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('ループ再生を${value ? 'ON' : 'OFF'}にしました')),
            );
          },
        ),
        SwitchListTile(
          title: const Text('スロー再生対応'),
          subtitle: const Text('0.5倍速での再生が可能になります'),
          value: true,
          onChanged: (value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('スロー再生を${value ? 'ON' : 'OFF'}にしました')),
            );
          },
        ),
        const Divider(height: 32),
        SwitchListTile(
          title: const Text('SNS共有'),
          subtitle: const Text('曲をSNSで共有できるようにします'),
          value: true,
          onChanged: (value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('SNS共有を${value ? '許可' : '拒否'}にしました')),
            );
          },
        ),
        SwitchListTile(
          title: const Text('家族との共有'),
          subtitle: const Text('親アカウントと曲を共有します'),
          value: false,
          onChanged: (value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('家族共有を${value ? '有効' : '無効'}にしました')),
            );
          },
        ),
        const Divider(height: 32),
        ListTile(
          title: const Text('データをリセット'),
          subtitle: const Text('すべての生成された曲を削除します'),
          trailing: const Icon(Icons.delete_outline),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('確認'),
                content: const Text('本当にリセットしますか？'),
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
