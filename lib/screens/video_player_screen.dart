import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/video_model.dart';
import '../providers/video_provider.dart';
import '../providers/user_profile_provider.dart';
import '../design_system/design_system.dart';
import 'video_quiz_screen.dart';

/// ビデオプレイヤー画面
class VideoPlayerScreen extends ConsumerStatefulWidget {
  final PronunciationVideo video;

  const VideoPlayerScreen({
    Key? key,
    required this.video,
  }) : super(key: key);

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  late int _watchedSeconds;
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _watchedSeconds = 0;
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserProvider)?.id ?? '';
    final quizAsync = ref.watch(videoQuizProvider(widget.video.id));
    final progressAsync = ref.watch(userVideoProgressProvider('$userId:${widget.video.id}'));
    final statsAsync = ref.watch(videoWatchStatsProvider(widget.video.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('📹 ビデオプレイヤー'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ビデオプレイヤー
            _VideoPlayer(
              video: widget.video,
              onPlayingChanged: (isPlaying) => setState(() => _isPlaying = isPlaying),
              onProgressChanged: (seconds) {
                setState(() => _watchedSeconds = seconds);
                // Update progress periodically
                if (_watchedSeconds % 10 == 0) {
                  _updateProgress();
                }
              },
              onSpeedChanged: (speed) => setState(() => _playbackSpeed = speed),
            ),
            AppSpacing.verticalSpacerMd,

            // ビデオ情報
            Padding(
              padding: AppSpacing.allPaddingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // タイトル
                  Text(
                    widget.video.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  AppSpacing.verticalSpacerSm,

                  // 講師
                  Text(
                    '講師: ${widget.video.instructor}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  AppSpacing.verticalSpacerMd,

                  // メタ情報行
                  Row(
                    children: [
                      Chip(
                        label: Text(widget.video.difficultyLabel),
                        avatar: Text(widget.video.difficultyEmoji),
                      ),
                      AppSpacing.horizontalSpacerMd,
                      Chip(
                        label: Text(widget.video.categoryLabel),
                      ),
                      AppSpacing.horizontalSpacerMd,
                      Chip(
                        label: Text(widget.video.formattedDuration),
                        avatar: const Text('⏱️'),
                      ),
                    ],
                  ),
                  AppSpacing.verticalSpacerMd,

                  // 統計情報
                  statsAsync.when(
                    data: (stats) {
                      if (stats != null) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('👁️ ${stats.totalViews} 回視聴'),
                            Text('❤️ ${stats.likeCount} いいね'),
                            Text('⭐ ${stats.averageRating.toStringAsFixed(1)}'),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  AppSpacing.verticalSpacerMd,

                  // 説明
                  Text(
                    '説明',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  AppSpacing.verticalSpacerSm,
                  Text(
                    widget.video.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  AppSpacing.verticalSpacerMd,

                  // フォーカスエリア
                  if (widget.video.focusAreas.isNotEmpty) ...[
                    Text(
                      '学習ポイント',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    AppSpacing.verticalSpacerSm,
                    Wrap(
                      spacing: 8,
                      children: widget.video.focusAreas
                          .map((area) => Chip(label: Text(area)))
                          .toList(),
                    ),
                    AppSpacing.verticalSpacerMd,
                  ],

                  // タグ
                  if (widget.video.tags.isNotEmpty) ...[
                    Text(
                      'タグ',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    AppSpacing.verticalSpacerSm,
                    Wrap(
                      spacing: 8,
                      children: widget.video.tags
                          .map((tag) => Chip(
                                label: Text(tag),
                                backgroundColor: Colors.blue.withOpacity(0.2),
                              ))
                          .toList(),
                    ),
                    AppSpacing.verticalSpacerMd,
                  ],

                  // アクションボタン
                  _ActionButtons(
                    video: widget.video,
                    userId: userId,
                    onCompleted: _updateProgress,
                  ),
                  AppSpacing.verticalSpacerMd,

                  // クイズ
                  quizAsync.when(
                    data: (quiz) {
                      if (quiz != null) {
                        return Card(
                          color: Colors.blue.withOpacity(0.1),
                          child: Padding(
                            padding: AppSpacing.allPaddingMd,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '📝 このビデオについてのクイズ',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                AppSpacing.verticalSpacerMd,
                                Text(
                                  '${quiz.questions.length} 問の問題があります。',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                AppSpacing.verticalSpacerMd,
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => VideoQuizScreen(
                                          video: widget.video,
                                          quiz: quiz,
                                        ),
                                      ),
                                    ),
                                    child: const Text('クイズに挑戦'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  AppSpacing.verticalSpacerLg,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateProgress() {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return;

    final progress = VideoProgress(
      userId: userId,
      videoId: widget.video.id,
      watchedSeconds: _watchedSeconds,
      isWatched: _watchedSeconds >= widget.video.lengthSeconds * 0.9,
      isLiked: false,
      rating: 0,
      lastWatchedAt: DateTime.now(),
    );

    ref.read(updateVideoProgressProvider(progress));
  }
}

/// ビデオプレイヤーウィジェット
class _VideoPlayer extends StatefulWidget {
  final PronunciationVideo video;
  final ValueChanged<bool> onPlayingChanged;
  final ValueChanged<int> onProgressChanged;
  final ValueChanged<double> onSpeedChanged;

  const _VideoPlayer({
    required this.video,
    required this.onPlayingChanged,
    required this.onProgressChanged,
    required this.onSpeedChanged,
  });

  @override
  State<_VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<_VideoPlayer> {
  late int _currentTime;
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _currentTime = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ビデオプレースホルダー
          Container(
            width: double.infinity,
            height: 200,
            color: Colors.grey.withOpacity(0.3),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🎥', style: TextStyle(fontSize: 64)),
                    AppSpacing.verticalSpacerMd,
                    Text(
                      widget.video.title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                // 再生ボタン
                FloatingActionButton(
                  onPressed: _togglePlay,
                  child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                ),
              ],
            ),
          ),

          Padding(
            padding: AppSpacing.allPaddingMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // プログレスバー
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: _currentTime / widget.video.lengthSeconds,
                      minHeight: 4,
                    ),
                    AppSpacing.verticalSpacerSm,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDuration(_currentTime)),
                        Text(_formatDuration(widget.video.lengthSeconds)),
                      ],
                    ),
                  ],
                ),
                AppSpacing.verticalSpacerMd,

                // 再生コントロール
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.replay_10),
                      onPressed: () {
                        setState(() {
                          _currentTime = (_currentTime - 10).clamp(0, widget.video.lengthSeconds);
                          widget.onProgressChanged(_currentTime);
                        });
                      },
                    ),
                    FloatingActionButton(
                      onPressed: _togglePlay,
                      child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    ),
                    IconButton(
                      icon: const Icon(Icons.forward_10),
                      onPressed: () {
                        setState(() {
                          _currentTime = (_currentTime + 10).clamp(0, widget.video.lengthSeconds);
                          widget.onProgressChanged(_currentTime);
                        });
                      },
                    ),
                  ],
                ),
                AppSpacing.verticalSpacerMd,

                // 再生速度
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('再生速度:'),
                    DropdownButton<double>(
                      value: _playbackSpeed,
                      items: const [
                        DropdownMenuItem(value: 0.75, child: Text('0.75x')),
                        DropdownMenuItem(value: 1.0, child: Text('1.0x')),
                        DropdownMenuItem(value: 1.25, child: Text('1.25x')),
                        DropdownMenuItem(value: 1.5, child: Text('1.5x')),
                        DropdownMenuItem(value: 2.0, child: Text('2.0x')),
                      ],
                      onChanged: (speed) {
                        if (speed != null) {
                          setState(() => _playbackSpeed = speed);
                          widget.onSpeedChanged(speed);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      widget.onPlayingChanged(_isPlaying);
    });
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }
}

/// アクションボタン
class _ActionButtons extends ConsumerWidget {
  final PronunciationVideo video;
  final String userId;
  final VoidCallback onCompleted;

  const _ActionButtons({
    required this.video,
    required this.userId,
    required this.onCompleted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(userVideoProgressProvider('$userId:${video.id}'));

    return progressAsync.when(
      data: (progress) {
        final isLiked = progress?.isLiked ?? false;

        return Card(
          child: Padding(
            padding: AppSpacing.allPaddingMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'このビデオについて',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                AppSpacing.verticalSpacerMd,

                // いいねボタン
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: progress != null
                        ? () {
                            ref.read(likeVideoActionProvider(
                              LikeVideoParams(userId: userId, videoId: video.id),
                            ));
                          }
                        : null,
                    icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
                    label: Text(isLiked ? 'いいね済み' : 'いいね'),
                  ),
                ),
                AppSpacing.verticalSpacerMd,

                // 評価
                Text(
                  '評価:',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                AppSpacing.verticalSpacerSm,
                Row(
                  children: List.generate(
                    5,
                    (index) => IconButton(
                      icon: Icon(
                        index < (progress?.rating ?? 0)
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: progress != null
                          ? () {
                              ref.read(rateVideoActionProvider(
                                RateVideoParams(
                                  userId: userId,
                                  videoId: video.id,
                                  rating: index + 1,
                                ),
                              ));
                            }
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
