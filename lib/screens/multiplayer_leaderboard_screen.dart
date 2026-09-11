import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';

import '../design_system/design_system.dart';
import '../providers/user_profile_provider.dart';

class MultiplayerLeaderboardScreen extends ConsumerWidget {
  const MultiplayerLeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);
    final currentUserId = ref.watch(currentUserProvider)?.id;

    return Scaffold(
      appBar: AppBar(title: const Text('🏆 対戦ランキング'), elevation: 0),
      body: leaderboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
        data: (ratings) => LeaderboardView(
          ratings: ratings,
          currentUserId: currentUserId,
          accentColor: AppColors.accentOrange,
        ),
      ),
    );
  }
}
