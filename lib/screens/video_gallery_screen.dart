import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/video_model.dart';
import '../providers/video_provider.dart';
import '../providers/user_profile_provider.dart';
import '../design_system/design_system.dart';
import 'video_player_screen.dart';

/// 発音動画ギャラリー画面
class VideoGalleryScreen extends ConsumerStatefulWidget {
  const VideoGalleryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<VideoGalleryScreen> createState() => _VideoGalleryScreenState();
}

class _VideoGalleryScreenState extends ConsumerState<VideoGalleryScreen> {
  String? _selectedCategory;
  int? _maxDifficulty;
  String _searchQuery = '';
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = null;
      _maxDifficulty = null;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserProvider)?.id ?? '';
    final continueWatchingAsync = ref.watch(continueWatchingProvider(userId));

    final filterParams = VideoFilterParams(
      category: _selectedCategory,
      maxDifficulty: _maxDifficulty,
      searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
    );

    final videosAsync = ref.watch(filteredVideosProvider(filterParams));

    return Scaffold(
      appBar: AppBar(
        title: const Text('📹 発音動画'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: AppSpacing.allPaddingMd,
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: '動画を検索...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 続きから見る
            continueWatchingAsync.when(
              data: (videos) {
                if (videos.isNotEmpty) {
                  return Padding(
                    padding: AppSpacing.allPaddingMd,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '続きから見る',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        AppSpacing.verticalSpacerMd,
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: videos.length,
                            itemBuilder: (context, index) {
                              final video = videos[index];
                              return _VideoThumbnail(
                                video: video,
                                userId: userId,
                                onTap: () => _navigateToPlayer(video),
                              );
                            },
                          ),
                        ),
                        AppSpacing.verticalSpacerLg,
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // フィルター
            Padding(
              padding: AppSpacing.allPaddingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // カテゴリフィルター
                  Text(
                    'カテゴリ',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  AppSpacing.verticalSpacerSm,
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _CategoryChip(
                          label: 'すべて',
                          selected: _selectedCategory == null,
                          onTap: () => setState(() => _selectedCategory = null),
                        ),
                        AppSpacing.horizontalSpacerSm,
                        _CategoryChip(
                          label: '音素学習',
                          selected: _selectedCategory == 'phonetics',
                          onTap: () => setState(() => _selectedCategory = 'phonetics'),
                        ),
                        AppSpacing.horizontalSpacerSm,
                        _CategoryChip(
                          label: '単語発音',
                          selected: _selectedCategory == 'words',
                          onTap: () => setState(() => _selectedCategory = 'words'),
                        ),
                        AppSpacing.horizontalSpacerSm,
                        _CategoryChip(
                          label: '文の強調',
                          selected: _selectedCategory == 'sentences',
                          onTap: () => setState(() => _selectedCategory = 'sentences'),
                        ),
                        AppSpacing.horizontalSpacerSm,
                        _CategoryChip(
                          label: '話し方技法',
                          selected: _selectedCategory == 'stress',
                          onTap: () => setState(() => _selectedCategory = 'stress'),
                        ),
                        AppSpacing.horizontalSpacerSm,
                        _CategoryChip(
                          label: 'ネイティブ集',
                          selected: _selectedCategory == 'natives',
                          onTap: () => setState(() => _selectedCategory = 'natives'),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.verticalSpacerMd,

                  // 難易度フィルター
                  Text(
                    '難易度',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  AppSpacing.verticalSpacerSm,
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _DifficultyChip(
                          label: 'すべて',
                          emoji: '⭐',
                          selected: _maxDifficulty == null,
                          onTap: () => setState(() => _maxDifficulty = null),
                        ),
                        AppSpacing.horizontalSpacerSm,
                        _DifficultyChip(
                          label: '初級',
                          emoji: '🟢',
                          selected: _maxDifficulty == 1,
                          onTap: () => setState(() => _maxDifficulty = 1),
                        ),
                        AppSpacing.horizontalSpacerSm,
                        _DifficultyChip(
                          label: '中級',
                          emoji: '🟡',
                          selected: _maxDifficulty == 2,
                          onTap: () => setState(() => _maxDifficulty = 2),
                        ),
                        AppSpacing.horizontalSpacerSm,
                        _DifficultyChip(
                          label: '上級',
                          emoji: '🟠',
                          selected: _maxDifficulty == 3,
                          onTap: () => setState(() => _maxDifficulty = 3),
                        ),
                        AppSpacing.horizontalSpacerSm,
                        _DifficultyChip(
                          label: 'アドバンス',
                          emoji: '🔴',
                          selected: _maxDifficulty == 4,
                          onTap: () => setState(() => _maxDifficulty = 4),
                        ),
                        AppSpacing.horizontalSpacerSm,
                        _DifficultyChip(
                          label: 'エキスパート',
                          emoji: '⚫',
                          selected: _maxDifficulty == 5,
                          onTap: () => setState(() => _maxDifficulty = 5),
                        ),
                      ],
                    ),
                  ),

                  // リセットボタン
                  if (_selectedCategory != null || _maxDifficulty != null || _searchQuery.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: TextButton(
                        onPressed: _resetFilters,
                        child: const Text('フィルターをリセット'),
                      ),
                    ),
                ],
              ),
            ),

            AppSpacing.verticalSpacerMd,

            // 動画リスト
            videosAsync.when(
              data: (videos) {
                if (videos.isEmpty) {
                  return Padding(
                    padding: AppSpacing.allPaddingMd,
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            '動画が見つかりません',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          AppSpacing.verticalSpacerMd,
                          ElevatedButton(
                            onPressed: _resetFilters,
                            child: const Text('フィルターをリセット'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: AppSpacing.allPaddingMd,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: videos.length,
                    itemBuilder: (context, index) {
                      final video = videos[index];
                      return _VideoListItem(
                        video: video,
                        userId: userId,
                        onTap: () => _navigateToPlayer(video),
                      );
                    },
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => Padding(
                padding: AppSpacing.allPaddingMd,
                child: Text('エラーが発生しました: $error'),
              ),
            ),

            AppSpacing.verticalSpacerLg,
          ],
        ),
      ),
    );
  }

  void _navigateToPlayer(PronunciationVideo video) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(video: video),
      ),
    );
  }
}

/// ビデオリストアイテム
class _VideoListItem extends ConsumerWidget {
  final PronunciationVideo video;
  final String userId;
  final VoidCallback onTap;

  const _VideoListItem({
    required this.video,
    required this.userId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(userVideoProgressProvider('$userId:${video.id}'));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.allPaddingMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // タイトルと難易度
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      video.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  AppSpacing.horizontalSpacerMd,
                  Chip(
                    label: Text('${video.difficultyEmoji} ${video.difficultyLabel}'),
                    compact: true,
                  ),
                ],
              ),
              AppSpacing.verticalSpacerSm,

              // 説明
              Text(
                video.description,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              AppSpacing.verticalSpacerMd,

              // メタ情報
              Row(
                children: [
                  Text(
                    '${video.formattedDuration}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  AppSpacing.horizontalSpacerMd,
                  Text(
                    '👁️ ${video.viewCount}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  AppSpacing.horizontalSpacerMd,
                  Text(
                    '❤️ ${video.likes}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  AppSpacing.horizontalSpacerMd,
                  Text(
                    '⭐ ${video.averageRating.toStringAsFixed(1)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.amber,
                        ),
                  ),
                ],
              ),
              AppSpacing.verticalSpacerMd,

              // 進捗バー
              progressAsync.when(
                data: (progress) {
                  if (progress != null && progress.watchedSeconds > 0) {
                    final percentage = progress.getWatchPercentage(video.lengthSeconds);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          value: percentage / 100,
                          minHeight: 4,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress.isWatched ? Colors.green : Colors.blue,
                          ),
                        ),
                        AppSpacing.verticalSpacerSm,
                        Text(
                          progress.isWatched ? '✅ 完了' : '$percentage% 視聴済み',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: progress.isWatched ? Colors.green : Colors.blue,
                              ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ビデオサムネイル
class _VideoThumbnail extends ConsumerWidget {
  final PronunciationVideo video;
  final String userId;
  final VoidCallback onTap;

  const _VideoThumbnail({
    required this.video,
    required this.userId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(userVideoProgressProvider('$userId:${video.id}'));

    return Card(
      margin: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 100,
          height: 120,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // プレースホルダー
              Container(
                color: Colors.grey.withOpacity(0.2),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('📹', style: TextStyle(fontSize: 32)),
                      AppSpacing.verticalSpacerSm,
                      Text(
                        video.formattedDuration,
                        style: Theme.of(context).textTheme.labelSmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              // 進捗オーバーレイ
              progressAsync.when(
                data: (progress) {
                  if (progress != null && progress.watchedSeconds > 0) {
                    final percentage = progress.getWatchPercentage(video.lengthSeconds);
                    return Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(4),
                          bottomRight: Radius.circular(4),
                        ),
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          minHeight: 4,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress.isWatched ? Colors.green : Colors.blue,
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// カテゴリチップ
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

/// 難易度チップ
class _DifficultyChip extends StatelessWidget {
  final String label;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  const _DifficultyChip({
    required this.label,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text('$emoji $label'),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}
