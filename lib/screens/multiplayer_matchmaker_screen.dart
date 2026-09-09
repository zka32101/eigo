import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import '../design_system/design_system.dart';
import '../models/user_profile.dart';
import '../providers/user_profile_provider.dart';
import 'multiplayer_search_screen.dart';
import 'multiplayer_leaderboard_screen.dart';

/// リアルタイム対戦（マルチプレイ）のトップ画面。
///
/// 自分のレーティング・対戦成績・最近の対戦履歴を表示し、
/// 「対戦相手を探す」でマッチング待機画面（[MultiplayerSearchScreen]）へ進む。
/// 既存の非同期「フレンドチャレンジ」機能とは別の導線（置き換えではなく追加）。
class MultiplayerMatchmakerScreen extends ConsumerWidget {
  const MultiplayerMatchmakerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('⚔️ 対戦')),
        body: const Center(child: Text('プロフィールを選択してください')),
      );
    }

    final ratingAsync = ref.watch(
      playerRatingProvider((userId: user.id, displayName: user.name)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('⚔️ 対戦'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            tooltip: 'ランキング',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MultiplayerLeaderboardScreen()),
            ),
          ),
        ],
      ),
      body: ratingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
        data: (rating) => _MatchmakerBody(user: user, rating: rating),
      ),
    );
  }
}

class _MatchmakerBody extends ConsumerWidget {
  final UserProfile user;
  final PlayerRating rating;

  const _MatchmakerBody({required this.user, required this.rating});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(userMatchHistoryProvider(user.id as String));

    return SingleChildScrollView(
      padding: AppSpacing.allPaddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlayerRatingCard(
            rating: rating,
            avatar: Text(user.avatar as String, style: const TextStyle(fontSize: 36)),
            gradientStart: AppColors.primary,
            gradientEnd: AppColors.primaryDark,
          ),
          AppSpacing.verticalSpacerLg,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '最近の対戦',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          AppSpacing.verticalSpacerMd,
          historyAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (e, _) => Text('対戦履歴の取得に失敗: $e', style: const TextStyle(color: Colors.grey)),
            data: (matches) {
              if (matches.isEmpty) {
                return Card(
                  child: Padding(
                    padding: AppSpacing.allPaddingMd,
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.sports_score, size: 48, color: Colors.grey.shade400),
                          AppSpacing.verticalSpacerSm,
                          Text('まだ対戦がありません', style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return Column(
                children: matches.take(5).map((m) => MatchHistoryTile(match: m, userId: user.id as String)).toList(),
              );
            },
          ),
          AppSpacing.verticalSpacerLg,
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.search),
              label: const Text(
                '対戦相手を探す',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.accentRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MultiplayerSearchScreen(
                    userId: user.id as String,
                    displayName: user.name as String,
                    rating: rating.rating,
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
