import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import '../design_system/design_system.dart';
import '../providers/user_profile_provider.dart';
import 'multiplayer_quiz_screen.dart';

/// マッチング待機画面。[MatchmakingSearchWidget]（shared_core）で
/// 検索中アニメーションを表示し、マッチが成立したら対戦画面へ遷移する。
class MultiplayerSearchScreen extends ConsumerStatefulWidget {
  final String userId;
  final String displayName;
  final double rating;

  const MultiplayerSearchScreen({
    super.key,
    required this.userId,
    required this.displayName,
    required this.rating,
  });

  @override
  ConsumerState<MultiplayerSearchScreen> createState() => _MultiplayerSearchScreenState();
}

class _MultiplayerSearchScreenState extends ConsumerState<MultiplayerSearchScreen> {
  bool _startedNavigation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(matchmakingProvider.notifier).startSearching(
            userId: widget.userId,
            displayName: widget.displayName,
            rating: widget.rating,
          );
    });
  }

  @override
  void dispose() {
    // 画面を離れる際、まだマッチしていなければキューから抜ける
    final state = ref.read(matchmakingProvider);
    if (!_startedNavigation && state.status == MatchmakingStatus.searching) {
      ref.read(matchmakingProvider.notifier).cancelSearch(widget.userId);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(matchmakingProvider);

    ref.listen<MatchmakingState>(matchmakingProvider, (previous, next) {
      if (next.status == MatchmakingStatus.matched && next.matchId != null && !_startedNavigation) {
        _startedNavigation = true;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => MultiplayerQuizScreen(
              matchId: next.matchId!,
              userId: widget.userId,
            ),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: state.status == MatchmakingStatus.error
            ? _buildError(context, state.errorMessage)
            : MatchmakingSearchWidget(
                avatar: const Text('⚔️', style: TextStyle(fontSize: 40)),
                displayName: widget.displayName,
                rating: widget.rating,
                accentColor: Colors.white,
                onCancel: () async {
                  await ref.read(matchmakingProvider.notifier).cancelSearch(widget.userId);
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String? message) {
    return Padding(
      padding: AppSpacing.allPaddingLg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 48),
          AppSpacing.verticalSpacerMd,
          Text(
            message ?? '対戦相手が見つかりませんでした',
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          AppSpacing.verticalSpacerLg,
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('戻る'),
          ),
        ],
      ),
    );
  }
}
