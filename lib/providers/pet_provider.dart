import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pet_model.dart';
import '../models/user_profile.dart';

/// ペット情報 Provider（Firestore から読み込み）
final petProvider = FutureProvider.family<PetModel?, String>((ref, userId) async {
  final firestore = FirebaseFirestore.instance;
  final docSnapshot = await firestore.collection('users').doc(userId).collection('pet').doc('data').get();

  if (!docSnapshot.exists) {
    return null;
  }

  return PetModel.fromJson(docSnapshot.data() as Map<String, dynamic>);
});

/// ペット操作用 StateNotifier
class PetNotifier extends StateNotifier<PetModel?> {
  final String userId;
  final FirebaseFirestore _firestore;

  PetNotifier(this.userId, {FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(null);

  /// ペットを初期化（新規作成）
  Future<void> initializePet(PetSpecies species) async {
    final now = DateTime.now();
    final newPet = PetModel(
      userId: userId,
      species: species,
      lastFedDate: now,
      createdAt: now,
    );

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('pet')
        .doc('data')
        .set(newPet.toJson());

    state = newPet;
  }

  /// Firestore からペット情報を再読み込み
  Future<void> refreshPet() async {
    final docSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('pet')
        .doc('data')
        .get();

    if (docSnapshot.exists) {
      final pet = PetModel.fromJson(docSnapshot.data() as Map<String, dynamic>);

      // 時間経過をシミュレート
      final simulatedPet = pet.simulateTimePass();
      state = simulatedPet;
    }
  }

  /// 発音スコアでペットにエサやり
  /// [pronouncingScore] 0-100 の発音スコア
  /// 返却値：獲得したコイン数
  Future<int> feedPetWithScore(int pronouncingScore) async {
    if (state == null) return 0;

    final coinsEarned = state!.feedPetWithScore(pronouncingScore);

    // hunger, exp を更新
    int newHunger = (state!.hunger - 10).clamp(0, 100);
    int newExp = state!.exp + 10 + ((pronouncingScore - 60) ~/ 10);

    // Level UP 判定
    PetModel updatedPet = state!.copyWith(hunger: newHunger, exp: newExp);
    while (updatedPet.exp >= 100) {
      final leveledUp = updatedPet.tryLevelUp();
      if (leveledUp != null) {
        updatedPet = leveledUp;
      } else {
        break;
      }
    }

    // Firestore に保存
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('pet')
        .doc('data')
        .update(updatedPet.toJson());

    state = updatedPet;
    return coinsEarned;
  }

  /// 毎日のプレイボーナス（朝通知から呼ぶ）
  Future<void> applyDailyBonus() async {
    if (state == null || state!.isFedToday) return;

    final newHappiness = (state!.happiness + 5).clamp(0, 100);
    final updatedPet = state!.copyWith(
      happiness: newHappiness,
      lastFedDate: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('pet')
        .doc('data')
        .update(updatedPet.toJson());

    state = updatedPet;
  }

  /// 装飾品を装備
  Future<void> equipDecoration(String decorationId) async {
    if (state == null) return;

    final decorationIds = [...state!.decorationIds];
    if (!decorationIds.contains(decorationId)) {
      decorationIds.add(decorationId);
    }

    final updatedPet = state!.copyWith(decorationIds: decorationIds);

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('pet')
        .doc('data')
        .update(updatedPet.toJson());

    state = updatedPet;
  }

  /// 装飾品を外す
  Future<void> unequipDecoration(String decorationId) async {
    if (state == null) return;

    final decorationIds = state!.decorationIds.where((id) => id != decorationId).toList();
    final updatedPet = state!.copyWith(decorationIds: decorationIds);

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('pet')
        .doc('data')
        .update(updatedPet.toJson());

    state = updatedPet;
  }
}

/// ペット操作用 StateNotifierProvider
final petNotifierProvider = StateNotifierProvider.family<PetNotifier, PetModel?, String>(
  (ref, userId) => PetNotifier(userId),
);

/// 現在のペット気分を取得
final petMoodProvider = Provider.family<PetMood?, String>((ref, userId) {
  final pet = ref.watch(petProvider(userId)).asData?.value;
  return pet?.currentMood;
});

/// 現在のペット進化段階を取得
final petEvolutionStageProvider = Provider.family<PetEvolutionStage?, String>((ref, userId) {
  final pet = ref.watch(petProvider(userId)).asData?.value;
  return pet?.currentStage;
});

/// ペットが今日既にエサを食べたかどうか
final petIsFedTodayProvider = Provider.family<bool, String>((ref, userId) {
  final pet = ref.watch(petProvider(userId)).asData?.value;
  return pet?.isFedToday ?? false;
});

/// 次のレベルアップまでの進捗（%）
final petLevelProgressProvider = Provider.family<int, String>((ref, userId) {
  final pet = ref.watch(petProvider(userId)).asData?.value;
  if (pet == null) return 0;
  return ((pet.exp / 100) * 100).toInt();
});
