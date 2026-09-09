import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_core/shared_core.dart';

/// shared_core の [FirestoreMatchmakingService] を、英語コレ！用の
/// コレクション名（`eigo_` プレフィックス）で初期化するラッパー。
///
/// 実データアクセス自体は shared_core 側の実装をそのまま使う。
/// このアプリでは [FirebaseService] が既に Firestore/匿名認証を初期化済みのため、
/// ここでは追加の初期化は行わず、コレクション名の指定のみを担う。
class EigoMatchmakingService {
  static final EigoMatchmakingService _instance = EigoMatchmakingService._();
  factory EigoMatchmakingService() => _instance;
  EigoMatchmakingService._();

  late final FirestoreMatchmakingService _inner = FirestoreMatchmakingService(
    firestore: FirebaseFirestore.instance,
    matchmakingQueueCollection: 'eigo_matchmaking_queue',
    matchesCollection: 'eigo_matches',
    playerRatingsCollection: 'eigo_player_ratings',
  );

  MatchmakingHandlers get matchmakingHandlers => _inner.matchmakingHandlers;
  MatchHandlers get matchHandlers => _inner.matchHandlers;

  /// 対戦終了後にレーティングを更新する（勝者・敗者、または引き分け）。
  Future<void> updateRatingAfterMatch({
    required String winnerId,
    required String loserId,
    bool isDraw = false,
  }) {
    return _inner.updateRatingAfterMatch(winnerId: winnerId, loserId: loserId, isDraw: isDraw);
  }
}
