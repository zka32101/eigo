import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/plush_toy_model.dart';
import '../providers/plush_toy_provider.dart';
import '../providers/user_profile_provider.dart';
import '../design_system/design_system.dart';

class PlushToyScreen extends ConsumerStatefulWidget {
  const PlushToyScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PlushToyScreen> createState() => _PlushToyScreenState();
}

class _PlushToyScreenState extends ConsumerState<PlushToyScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _initializeCharacterIfNeeded();
  }

  Future<void> _initializeCharacterIfNeeded() async {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return;

    final character = ref.read(plushToyCharacterProvider).value;
    if (character == null) {
      if (mounted) {
        _showCharacterSelectionDialog();
      }
    }
  }

  void _showCharacterSelectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _CharacterSelectionDialog(
        onSelected: _createCharacter,
      ),
    );
  }

  Future<void> _createCharacter(PlushToySpecies species, String customName) async {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return;

    final notifier = ref.read(plushToyCharacterProvider.notifier);
    await notifier.createCharacter(species, customName);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final characterAsync = ref.watch(plushToyCharacterProvider);
    final currentSessionAsync = ref.watch(currentSessionProvider);
    final progressAsync = ref.watch(plushToyProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🧸 ぬいぐるみモード'),
        elevation: 0,
      ),
      body: characterAsync.when(
        data: (character) {
          if (character == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('キャラクターをまだ作成していません'),
                  AppSpacing.verticalSpacerMd,
                  ElevatedButton(
                    onPressed: _showCharacterSelectionDialog,
                    child: const Text('キャラクターを作成する'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // タブバー
              Container(
                color: AppColors.textWhite,
                child: TabBar(
                  controller: TabController(
                    length: 3,
                    vsync: this,
                    initialIndex: _selectedTab,
                  ),
                  onTap: (index) => setState(() => _selectedTab = index),
                  indicatorColor: AppColors.primary,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textMuted,
                  tabs: const [
                    Tab(text: '会話'),
                    Tab(text: '進捗'),
                    Tab(text: 'キャラ'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // Tab 1: 会話
                    _ConversationTab(
                      character: character,
                      currentSession: currentSessionAsync,
                    ),
                    // Tab 2: 進捗
                    _ProgressTab(progressAsync: progressAsync),
                    // Tab 3: キャラ
                    _CharacterTab(character: character),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラー: $err')),
      ),
    );
  }
}

/// Tab 1: 会話タブ
class _ConversationTab extends ConsumerStatefulWidget {
  final PlushToyCharacter character;
  final AsyncValue<PlushToySession?> currentSession;

  const _ConversationTab({
    required this.character,
    required this.currentSession,
  });

  @override
  ConsumerState<_ConversationTab> createState() => _ConversationTabState();
}

class _ConversationTabState extends ConsumerState<_ConversationTab> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.currentSession.when(
      data: (session) {
        if (session == null) {
          // セッション未開始：トピック選択画面
          return _SessionInitiationScreen(
            character: widget.character,
            onStartSession: _startSession,
          );
        }

        // セッション進行中：会話画面
        return _SessionConversationScreen(
          character: widget.character,
          session: session,
          onEndSession: _endSession,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('エラー: $err')),
    );
  }

  Future<void> _startSession(PlushToyTopic topic) async {
    final notifier = ref.read(currentSessionProvider.notifier);
    await notifier.startSession(topic);
  }

  Future<void> _endSession(String? userMood) async {
    final notifier = ref.read(currentSessionProvider.notifier);
    await notifier.endSession(userMood ?? 'satisfied');
  }
}

/// セッション開始画面
class _SessionInitiationScreen extends ConsumerWidget {
  final PlushToyCharacter character;
  final Function(PlushToyTopic) onStartSession;

  const _SessionInitiationScreen({
    required this.character,
    required this.onStartSession,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsAsync = ref.watch(availableTopicsProvider);

    return ListView(
      padding: AppSpacing.allPaddingMd,
      children: [
        // キャラクター表示
        _CharacterDisplayCard(character: character),
        AppSpacing.verticalSpacerLg,

        // 説明
        Container(
          decoration: BoxDecoration(
            color: AppColors.readingColor.withAlpha(25),
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            border: Border.all(color: AppColors.readingColor.withAlpha(80)),
          ),
          padding: AppSpacing.allPaddingMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ハンズフリー会話',
                style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              AppSpacing.verticalSpacerSm,
              Text(
                '${character.customName}と英語で会話しましょう！\n画面を見なくても大丈夫です。',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        AppSpacing.verticalSpacerLg,

        // トピック選択
        Text(
          'トピックを選んでください',
          style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        AppSpacing.verticalSpacerMd,

        topicsAsync.when(
          data: (topics) {
            return Column(
              children: topics.map((topic) {
                return Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.md),
                  child: _TopicCard(
                    topic: topic,
                    onTap: () => onStartSession(topic),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('エラー: $err')),
        ),
      ],
    );
  }
}

/// トピックカード
class _TopicCard extends StatelessWidget {
  final PlushToyTopic topic;
  final VoidCallback onTap;

  const _TopicCard({
    required this.topic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final difficultyColor = topic.difficulty == 'beginner'
        ? AppColors.accentGreen
        : topic.difficulty == 'intermediate'
            ? AppColors.accentOrange
            : AppColors.error;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.textWhite,
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          border: Border.all(color: AppColors.bgLight),
        ),
        padding: AppSpacing.allPaddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  topic.name,
                  style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: difficultyColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                  ),
                  child: Text(
                    topic.difficulty,
                    style: AppTypography.bodySmall.copyWith(
                      color: difficultyColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.verticalSpacerSm,
            Text(
              topic.description,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            AppSpacing.verticalSpacerSm,
            Text(
              '学習ポイント: ${topic.learningOutcomes.take(2).join(', ')}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.accentGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// セッション会話画面
class _SessionConversationScreen extends ConsumerStatefulWidget {
  final PlushToyCharacter character;
  final PlushToySession session;
  final Function(String? userMood) onEndSession;

  const _SessionConversationScreen({
    required this.character,
    required this.session,
    required this.onEndSession,
  });

  @override
  ConsumerState<_SessionConversationScreen> createState() =>
      _SessionConversationScreenState();
}

class _SessionConversationScreenState
    extends ConsumerState<_SessionConversationScreen> {
  late ScrollController _scrollController;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conversationAsync = ref.watch(conversationHistoryProvider);

    return Column(
      children: [
        // セッション情報バー
        Container(
          color: AppColors.readingColor.withAlpha(25),
          padding: AppSpacing.allPaddingMd,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ターン数: ${widget.session.turnCount}',
                    style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'スコア: ${widget.session.averageScore}点',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showEndSessionDialog(),
                icon: const Icon(Icons.stop_circle),
                label: const Text('終了'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.textWhite,
                ),
              ),
            ],
          ),
        ),

        // 会話表示
        Expanded(
          child: conversationAsync.when(
            data: (history) {
              if (history.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${widget.character.customName}を待っています...',
                        style: AppTypography.bodyMedium,
                      ),
                      AppSpacing.verticalSpacerMd,
                      const CircularProgressIndicator(),
                    ],
                  ),
                );
              }

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              });

              return ListView.builder(
                controller: _scrollController,
                padding: AppSpacing.allPaddingMd,
                itemCount: history.isNotEmpty ? history.last.messages.length : 0,
                itemBuilder: (context, index) {
                  final message = history.last.messages[index];
                  final isUser = message.sender == 'user';

                  return Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                    child: Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isUser ? AppColors.readingColor.withAlpha(50) : AppColors.bgLight,
                          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                        ),
                        padding: AppSpacing.allPaddingMd,
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.text,
                              style: AppTypography.bodySmall,
                            ),
                            if (message.pronunciationScore != null) ...[
                              AppSpacing.verticalSpacerXs,
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: message.pronunciationScore! >= 60
                                      ? AppColors.accentGreen.withAlpha(50)
                                      : AppColors.accentOrange.withAlpha(50),
                                  borderRadius:
                                      BorderRadius.circular(AppSizes.borderRadiusSmall),
                                ),
                                child: Text(
                                  '発音: ${message.pronunciationScore}点',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: message.pronunciationScore! >= 60
                                        ? AppColors.accentGreen
                                        : AppColors.accentOrange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  AppSpacing.verticalSpacerMd,
                  Text(
                    '会話を読み込んでいます...',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
            error: (err, stack) => Center(child: Text('エラー: $err')),
          ),
        ),

        // 音声制御パネル
        Container(
          color: AppColors.textWhite,
          padding: AppSpacing.allPaddingMd,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton.large(
                    onPressed: () {
                      setState(() => _isPlaying = !_isPlaying);
                      // 実装: 音声再生/停止ロジック
                    },
                    backgroundColor: _isPlaying ? AppColors.error : AppColors.readingColor,
                    child: Icon(_isPlaying ? Icons.stop : Icons.mic),
                  ),
                  AppSpacing.horizontalSpacerLg,
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: _isPlaying ? 0.7 : 0,
                            strokeWidth: 4,
                          ),
                          Text(
                            _isPlaying ? '聴取中' : 'スタンバイ',
                            style: AppTypography.labelMedium
                                .copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.verticalSpacerMd,
              Text(
                'ハンズフリーモード：マイクで話しかけてください',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showEndSessionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('セッションを終了しますか？'),
        content: const Text('今回の会話がどうでしたか？気分を教えてください。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('続ける'),
          ),
          ...['happy', 'satisfied', 'tired', 'motivated'].map(
            (mood) => TextButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onEndSession(mood);
              },
              child: Text(mood),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab 2: 進捗タブ
class _ProgressTab extends StatelessWidget {
  final AsyncValue<PlushToyProgress?> progressAsync;

  const _ProgressTab({required this.progressAsync});

  @override
  Widget build(BuildContext context) {
    return progressAsync.when(
      data: (progress) {
        if (progress == null) {
          return const Center(
            child: Text('進捗データはまだ利用できません'),
          );
        }

        return ListView(
          padding: AppSpacing.allPaddingMd,
          children: [
            // レベル・経験値
            _ProgressCard(
              title: 'レベル',
              value: 'Lv ${progress.level}',
              subtitle: '次レベルまで: ${progress.experienceToNextLevel} XP',
              progress: 1 - (progress.experienceToNextLevel / 1000),
              color: AppColors.accentPurple,
            ),
            AppSpacing.verticalSpacerMd,

            // マスター済みトピック
            Container(
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withAlpha(25),
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                border: Border.all(color: AppColors.accentGreen.withAlpha(80)),
              ),
              padding: AppSpacing.allPaddingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'トピック習得度',
                    style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  AppSpacing.verticalSpacerMd,
                  ...progress.topicMastery.entries.map((e) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                e.key,
                                style: AppTypography.bodySmall,
                              ),
                              Text(
                                '${(e.value * 100).toStringAsFixed(0)}%',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.accentGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppSizes.borderRadiusSmall),
                            child: LinearProgressIndicator(
                              value: e.value,
                              minHeight: 6,
                              backgroundColor: AppColors.bgLight,
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(AppColors.accentGreen),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            AppSpacing.verticalSpacerMd,

            // ハンズフリー率
            _ProgressCard(
              title: 'ハンズフリー率',
              value: '${(progress.handsfreeRatio * 100).toStringAsFixed(0)}%',
              progress: progress.handsfreeRatio,
              color: AppColors.readingColor,
            ),
            AppSpacing.verticalSpacerMd,

            // 発音改善度
            _ProgressCard(
              title: '発音改善度',
              value: '${(progress.pronunciationImprovement * 100).toStringAsFixed(0)}%',
              progress: progress.pronunciationImprovement,
              color: AppColors.accentOrange,
            ),
            AppSpacing.verticalSpacerMd,

            // 親満足度
            _ProgressCard(
              title: '親満足度',
              value: '${progress.parentRating.toStringAsFixed(1)}/5.0',
              progress: progress.parentRating / 5.0,
              color: AppColors.accentPink,
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('エラー: $err')),
    );
  }
}

/// 進捗カード
class _ProgressCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final double progress;
  final Color color;

  const _ProgressCard({
    required this.title,
    required this.value,
    this.subtitle,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: AppSpacing.allPaddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                value,
                style: AppTypography.labelLarge.copyWith(color: color),
              ),
            ],
          ),
          AppSpacing.verticalSpacerSm,
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.bgLight,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          if (subtitle != null) ...[
            AppSpacing.verticalSpacerXs,
            Text(
              subtitle!,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}

/// Tab 3: キャラクタータブ
class _CharacterTab extends ConsumerWidget {
  final PlushToyCharacter character;

  const _CharacterTab({required this.character});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(plushToyStatsProvider);

    return ListView(
      padding: AppSpacing.allPaddingMd,
      children: [
        // キャラクター表示
        _CharacterDisplayCard(character: character),
        AppSpacing.verticalSpacerLg,

        // キャラクター情報
        Container(
          decoration: BoxDecoration(
            color: AppColors.readingColor.withAlpha(25),
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            border: Border.all(color: AppColors.readingColor.withAlpha(80)),
          ),
          padding: AppSpacing.allPaddingMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                character.customName,
                style: AppTypography.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacing.verticalSpacerXs,
              Text(
                character.species.description,
                style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
              ),
              AppSpacing.verticalSpacerMd,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        'Lv ${(character.experiencePoints ~/ 100) + 1}',
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentPurple,
                        ),
                      ),
                      Text(
                        'レベル',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '${character.affectionLevel}',
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentPink,
                        ),
                      ),
                      Text(
                        '好感度',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '${character.unlockedSkills.length}',
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentGreen,
                        ),
                      ),
                      Text(
                        'スキル',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        AppSpacing.verticalSpacerLg,

        // アンロック済みスキル
        if (character.unlockedSkills.isNotEmpty) ...[
          Text(
            'アンロック済みスキル',
            style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          AppSpacing.verticalSpacerMd,
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: character.unlockedSkills.map((skill) {
              return Chip(
                label: Text(skill),
                backgroundColor: AppColors.accentGreen.withAlpha(50),
              );
            }).toList(),
          ),
          AppSpacing.verticalSpacerLg,
        ],

        // 統計情報
        statsAsync.when(
          data: (stats) {
            if (stats == null) return const SizedBox();

            return Container(
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withAlpha(25),
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                border: Border.all(color: AppColors.accentOrange.withAlpha(80)),
              ),
              padding: AppSpacing.allPaddingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '統計情報',
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpacing.verticalSpacerMd,
                  _StatRow(
                    label: '総セッション数',
                    value: '${stats.totalSessions}',
                  ),
                  _StatRow(
                    label: '総会話ターン数',
                    value: '${stats.totalTurns}',
                  ),
                  _StatRow(
                    label: '学習フレーズ数',
                    value: '${stats.totalPhrasesLearned}',
                  ),
                  _StatRow(
                    label: '連続ストリーク',
                    value: '${stats.consecutiveDays}日',
                  ),
                  _StatRow(
                    label: '最長ストリーク',
                    value: '${stats.longestStreak}日',
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => const SizedBox(),
        ),
      ],
    );
  }
}

/// キャラクター表示カード
class _CharacterDisplayCard extends StatelessWidget {
  final PlushToyCharacter character;

  const _CharacterDisplayCard({required this.character});

  @override
  Widget build(BuildContext context) {
    final emoji = character.species.displayName.split(' ').first;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accentPurple.withAlpha(25), AppColors.readingColor.withAlpha(25)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
        border: Border.all(color: AppColors.accentPurple.withAlpha(80)),
      ),
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.textWhite,
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textPrimary.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 80),
              ),
            ),
          ),
          AppSpacing.verticalSpacerMd,
          Text(
            character.customName,
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.verticalSpacerXs,
          Text(
            character.species.displayName,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

/// 統計行
class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall,
          ),
          Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.accentGreen,
            ),
          ),
        ],
      ),
    );
  }
}

/// キャラクター選択ダイアログ
class _CharacterSelectionDialog extends StatefulWidget {
  final Function(PlushToySpecies, String) onSelected;

  const _CharacterSelectionDialog({required this.onSelected});

  @override
  State<_CharacterSelectionDialog> createState() =>
      _CharacterSelectionDialogState();
}

class _CharacterSelectionDialogState extends State<_CharacterSelectionDialog> {
  PlushToySpecies? _selectedSpecies;
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('🧸 キャラクターを作成しよう'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'キャラクターを選んでください',
              style: AppTypography.labelMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.verticalSpacerMd,
            ...PlushToySpecies.values.map((species) {
              final emoji = species.displayName.split(' ').first;
              final isSelected = _selectedSpecies == species;

              return Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedSpecies = species),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.readingColor.withAlpha(50) : AppColors.bgLight.withAlpha(25),
                      border: Border.all(
                        color: isSelected ? AppColors.readingColor : AppColors.bgLight,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                    ),
                    padding: AppSpacing.allPaddingMd,
                    child: Row(
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 32)),
                        AppSpacing.horizontalSpacerMd,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                species.displayName.split(' ').last,
                                style: AppTypography.labelMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                species.description,
                                style: AppTypography.bodySmall
                                    .copyWith(color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
            AppSpacing.verticalSpacerLg,
            Text(
              'カスタム名を入力してください',
              style: AppTypography.labelMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.verticalSpacerMd,
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'キャラクターの名前',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                ),
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
          onPressed: _selectedSpecies == null || _nameController.text.isEmpty
              ? null
              : () {
                  widget.onSelected(_selectedSpecies!, _nameController.text);
                  Navigator.pop(context);
                },
          child: const Text('作成'),
        ),
      ],
    );
  }
}
