import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pronunciation_result.dart';
import '../models/pet_model.dart';
import '../providers/pet_provider.dart';
import '../providers/coin_provider.dart';
import '../providers/level_provider.dart';

/// 発音スコア → ペットフィード統合サービス
///
/// 流れ:
/// 1. PronunciationResult.accuracy (0.0-1.0) を受け取る
/// 2. 0-100に正規化
/// 3. ペットにフィード（hunger 減少、exp 増加）
/// 4. コイン加算
/// 5. 人間レベル XP 加算（別系統）
class PronunciationPetIntegrationService {
  final WidgetRef ref;

  PronunciationPetIntegrationService({required this.ref});

  /// 発音結果をペットと人間のレベルに反映
  ///
  /// 返却値: (coinsEarned, hungerAfter, happinessAfter, petLeveledUp)
  Future<PronunciationFeedbackResult> processResult({
    required PronunciationResult pronunciationResult,
    required String userId,
  }) async {
    // 1. 発音スコアを 0-100 に正規化
    final pronouncingScore = (pronunciationResult.accuracy * 100).toInt();

    // 2. ペットにフィード
    final coinsFromPet = await ref
        .read(petNotifierProvider(userId).notifier)
        .feedPetWithScore(pronouncingScore);

    // 3. コイン加算
    await ref.read(coinProvider.notifier).addCoins(coinsFromPet);

    // 4. 人間レベル XP 加算（独立系統）
    final xpBonus = _calculateXpBonus(pronouncingScore);
    await ref.read(levelProvider.notifier).addXp(xpBonus);

    // 5. ペット状態確認
    final petAsync = ref.read(petProvider(userId));
    final pet = petAsync.asData?.value;

    return PronunciationFeedbackResult(
      coinsEarned: coinsFromPet,
      pronouncingScore: pronouncingScore,
      petHungerAfter: pet?.hunger ?? 0,
      petHappinessAfter: pet?.happiness ?? 0,
      petLeveledUp: pet?.level ?? 0,
      xpBonusGiven: xpBonus,
      petMood: pet?.currentMood,
    );
  }

  /// 発音スコアに基づいて人間レベル XP をボーナス計算
  int _calculateXpBonus(int pronouncingScore) {
    // スコア 60 未満: ボーナスなし
    if (pronouncingScore < 60) return 0;

    // スコア 60-100: 5-15 XP
    // 60: 5, 70: 10, 80: 12, 90: 15
    return 5 + ((pronouncingScore - 60) ~/ 10) * 2;
  }
}

/// 発音フィードバック結果
class PronunciationFeedbackResult {
  /// ペットから獲得したコイン
  final int coinsEarned;

  /// 発音スコア (0-100)
  final int pronouncingScore;

  /// ペットの満腹度（フィード後）
  final int petHungerAfter;

  /// ペットの幸福度（フィード後）
  final int petHappinessAfter;

  /// ペットのレベル（フィード後）
  final int petLeveledUp;

  /// 人間レベルに付与した XP
  final int xpBonusGiven;

  /// ペットの気分
  final PetMood? petMood;

  PronunciationFeedbackResult({
    required this.coinsEarned,
    required this.pronouncingScore,
    required this.petHungerAfter,
    required this.petHappinessAfter,
    required this.petLeveledUp,
    required this.xpBonusGiven,
    required this.petMood,
  });

  /// フィードバック用メッセージ生成
  String generateFeedback() {
    final petMessage = _generatePetMessage();
    final coinMessage = coinsEarned > 0 ? '🪙 $coinsEarned コイン獲得！' : '';
    return '$petMessage\n$coinMessage'.trim();
  }

  String _generatePetMessage() {
    if (pronouncingScore < 60) {
      return '発音をもっと練習しよう！😊';
    } else if (pronouncingScore < 80) {
      return '${petMood?.displayName ?? 'ペット'} がご飯をもらいました🍖';
    } else if (pronouncingScore < 90) {
      return '${petMood?.displayName ?? 'ペット'} が大喜び！🎉';
    } else {
      return '完璧な発音！${petMood?.displayName ?? 'ペット'} が踊っています💃';
    }
  }
}

/// Provider: 統合サービスインスタンス
final pronunciationPetIntegrationProvider = Provider((ref) {
  return PronunciationPetIntegrationService(ref: ref);
});
