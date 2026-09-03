import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pet_model.dart';
import 'logger_service.dart';

/// Service for managing pet operations
class PetService {
  static final PetService _instance = PetService._internal();

  factory PetService() {
    return _instance;
  }

  PetService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===== Pet Management =====

  /// Create a new pet for a user
  Future<Pet?> createPet({
    required String userId,
    required PetSpecies species,
    required String nickname,
  }) async {
    try {
      final now = DateTime.now();
      final petId = DateTime.now().millisecondsSinceEpoch.toString();

      final pet = Pet(
        petId: petId,
        species: species,
        nickname: nickname,
        level: 1,
        experience: 0,
        satiety: 50,
        happiness: 50,
        evolutionStage: EvolutionStage.egg,
        createdAt: now,
        lastFedAt: now,
        lastPlayedAt: now,
      );

      // Save to Firestore
      await _firestore.collection('userPets').doc(userId).set({
        'petId': petId,
        'species': species.name,
        'nickname': nickname,
        'level': 1,
        'experience': 0,
        'satiety': 50,
        'happiness': 50,
        'evolutionStage': 'egg',
        'learnedWords': [],
        'createdAt': Timestamp.fromDate(now),
        'lastFedAt': Timestamp.fromDate(now),
        'lastPlayedAt': Timestamp.fromDate(now),
        'totalFeedsCount': 0,
        'totalPlayCount': 0,
      });

      LoggerService.info(
        'Pet created: $petId for user $userId',
        tag: 'PetService',
      );

      return pet;
    } catch (e) {
      LoggerService.error(
        'Error creating pet',
        tag: 'PetService',
        exception: e,
      );
      return null;
    }
  }

  /// Get user's pet
  Future<Pet?> getUserPet(String userId) async {
    try {
      final doc = await _firestore.collection('userPets').doc(userId).get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data();
      if (data == null) return null;

      return Pet.fromJson(data);
    } catch (e) {
      LoggerService.error(
        'Error fetching pet',
        tag: 'PetService',
        exception: e,
      );
      return null;
    }
  }

  /// Update pet data
  Future<void> updatePet(String userId, Pet pet) async {
    try {
      await _firestore.collection('userPets').doc(userId).update(
            pet.toJson(),
          );

      LoggerService.info(
        'Pet updated: ${pet.petId}',
        tag: 'PetService',
      );
    } catch (e) {
      LoggerService.error(
        'Error updating pet',
        tag: 'PetService',
        exception: e,
      );
    }
  }

  /// Delete user's pet
  Future<void> deletePet(String userId) async {
    try {
      await _firestore.collection('userPets').doc(userId).delete();

      LoggerService.info(
        'Pet deleted for user $userId',
        tag: 'PetService',
      );
    } catch (e) {
      LoggerService.error(
        'Error deleting pet',
        tag: 'PetService',
        exception: e,
      );
    }
  }

  // ===== Pet Interactions =====

  /// Feed pet and restore satiety
  Future<Pet?> feedPet(String userId, int satietyRestore) async {
    try {
      final pet = await getUserPet(userId);
      if (pet == null) return null;

      int newSatiety = (pet.satiety + satietyRestore).clamp(0, 100);
      int newHappiness = (pet.happiness + 5).clamp(0, 100);
      int newExp = pet.experience + 2;
      int newLevel = pet.level + (newExp ~/ 100);
      int newExpMod = newExp % 100;

      final updatedPet = pet.copyWith(
        satiety: newSatiety,
        happiness: newHappiness,
        experience: newExpMod,
        level: newLevel,
        lastFedAt: DateTime.now(),
        totalFeedsCount: pet.totalFeedsCount + 1,
      );

      // Check evolution
      updatedPet = _checkEvolution(updatedPet);

      await updatePet(userId, updatedPet);

      LoggerService.info(
        'Pet fed: ${pet.petId}, new satiety: $newSatiety',
        tag: 'PetService',
      );

      return updatedPet;
    } catch (e) {
      LoggerService.error(
        'Error feeding pet',
        tag: 'PetService',
        exception: e,
      );
      return null;
    }
  }

  /// Play with pet to increase happiness
  Future<Pet?> playWithPet(String userId) async {
    try {
      final pet = await getUserPet(userId);
      if (pet == null) return null;

      int newSatiety = (pet.satiety - 10).clamp(0, 100);
      int newHappiness = (pet.happiness + 20).clamp(0, 100);
      int newExp = pet.experience + 5;
      int newLevel = pet.level + (newExp ~/ 100);
      int newExpMod = newExp % 100;

      var updatedPet = pet.copyWith(
        satiety: newSatiety,
        happiness: newHappiness,
        experience: newExpMod,
        level: newLevel,
        lastPlayedAt: DateTime.now(),
        totalPlayCount: pet.totalPlayCount + 1,
      );

      updatedPet = _checkEvolution(updatedPet);

      await updatePet(userId, updatedPet);

      LoggerService.info(
        'Pet played with: ${pet.petId}, new happiness: $newHappiness',
        tag: 'PetService',
      );

      return updatedPet;
    } catch (e) {
      LoggerService.error(
        'Error playing with pet',
        tag: 'PetService',
        exception: e,
      );
      return null;
    }
  }

  /// Pet the pet to increase happiness slightly
  Future<Pet?> petPet(String userId) async {
    try {
      final pet = await getUserPet(userId);
      if (pet == null) return null;

      int newHappiness = (pet.happiness + 10).clamp(0, 100);

      final updatedPet = pet.copyWith(
        happiness: newHappiness,
      );

      await updatePet(userId, updatedPet);

      LoggerService.info(
        'Pet petted: ${pet.petId}',
        tag: 'PetService',
      );

      return updatedPet;
    } catch (e) {
      LoggerService.error(
        'Error petting pet',
        tag: 'PetService',
        exception: e,
      );
      return null;
    }
  }

  /// Train pet through lesson completion
  Future<Pet?> trainPet(String userId, int xpGain) async {
    try {
      final pet = await getUserPet(userId);
      if (pet == null) return null;

      int newExp = pet.experience + xpGain;
      int newLevel = pet.level + (newExp ~/ 100);
      int newExpMod = newExp % 100;
      int newHappiness = (pet.happiness + 3).clamp(0, 100);
      int newSatiety = (pet.satiety - 2).clamp(0, 100);

      var updatedPet = pet.copyWith(
        experience: newExpMod,
        level: newLevel,
        happiness: newHappiness,
        satiety: newSatiety,
      );

      updatedPet = _checkEvolution(updatedPet);

      await updatePet(userId, updatedPet);

      LoggerService.info(
        'Pet trained: ${pet.petId}, +$xpGain XP',
        tag: 'PetService',
      );

      return updatedPet;
    } catch (e) {
      LoggerService.error(
        'Error training pet',
        tag: 'PetService',
        exception: e,
      );
      return null;
    }
  }

  /// Daily care check
  Future<Pet?> dailyCheck(String userId) async {
    try {
      final pet = await getUserPet(userId);
      if (pet == null) return null;

      DateTime lastPlayed = pet.lastPlayedAt;
      bool playedToday = DateTime.now().difference(lastPlayed).inHours < 24;

      int newHappiness = pet.happiness;
      int newSatiety = (pet.satiety - 5).clamp(0, 100);

      if (!playedToday) {
        newHappiness = (newHappiness - 10).clamp(0, 100);
      } else {
        newHappiness = (newHappiness + 5).clamp(0, 100);
      }

      final updatedPet = pet.copyWith(
        satiety: newSatiety,
        happiness: newHappiness,
      );

      await updatePet(userId, updatedPet);

      LoggerService.info(
        'Daily check completed for pet: ${pet.petId}',
        tag: 'PetService',
      );

      return updatedPet;
    } catch (e) {
      LoggerService.error(
        'Error in daily check',
        tag: 'PetService',
        exception: e,
      );
      return null;
    }
  }

  /// Teach pet a new word
  Future<Pet?> learnWord(String userId, String word) async {
    try {
      final pet = await getUserPet(userId);
      if (pet == null) return null;

      final newWords = [...pet.learnedWords];
      if (!newWords.contains(word)) {
        newWords.add(word);
      }

      int newExp = pet.experience + 10;
      int newLevel = pet.level + (newExp ~/ 100);
      int newExpMod = newExp % 100;

      var updatedPet = pet.copyWith(
        learnedWords: newWords,
        experience: newExpMod,
        level: newLevel,
      );

      updatedPet = _checkEvolution(updatedPet);

      await updatePet(userId, updatedPet);

      LoggerService.info(
        'Pet learned word: $word',
        tag: 'PetService',
      );

      return updatedPet;
    } catch (e) {
      LoggerService.error(
        'Error teaching word to pet',
        tag: 'PetService',
        exception: e,
      );
      return null;
    }
  }

  // ===== Evolution & Stats =====

  /// Check if pet should evolve and evolve if needed
  Pet _checkEvolution(Pet pet) {
    if (pet.level >= 50 && pet.evolutionStage == EvolutionStage.adult) {
      return pet; // Already at max evolution
    }

    EvolutionStage newStage = pet.evolutionStage;

    if (pet.level >= 40 && pet.evolutionStage != EvolutionStage.adult) {
      newStage = EvolutionStage.adult;
    } else if (pet.level >= 25 && pet.evolutionStage != EvolutionStage.kids) {
      newStage = EvolutionStage.kids;
    } else if (pet.level >= 10 && pet.evolutionStage != EvolutionStage.baby) {
      newStage = EvolutionStage.baby;
    }

    return pet.copyWith(evolutionStage: newStage);
  }

  /// Get pet status snapshot
  Future<PetStatus> getPetStatus(String userId) async {
    try {
      final pet = await getUserPet(userId);
      if (pet == null) {
        throw Exception('Pet not found');
      }

      return PetStatus(
        level: pet.level,
        experience: pet.experience,
        happiness: pet.happiness,
        hunger: pet.satiety,
        isHungry: pet.isHungry,
        isUnhappy: pet.isUnhappy,
      );
    } catch (e) {
      LoggerService.error(
        'Error getting pet status',
        tag: 'PetService',
        exception: e,
      );
      rethrow;
    }
  }

  /// Get pet statistics
  Future<Map<String, dynamic>> getPetStats(String userId) async {
    try {
      final pet = await getUserPet(userId);
      if (pet == null) {
        return {
          'totalPets': 0,
          'maxLevel': 0,
          'totalFeeds': 0,
          'totalPlays': 0,
          'learnedWords': 0,
        };
      }

      return {
        'totalPets': 1,
        'maxLevel': pet.level,
        'totalFeeds': pet.totalFeedsCount,
        'totalPlays': pet.totalPlayCount,
        'learnedWords': pet.learnedWords.length,
        'happiness': pet.happiness,
        'satiety': pet.satiety,
      };
    } catch (e) {
      LoggerService.error(
        'Error getting pet stats',
        tag: 'PetService',
        exception: e,
      );
      return {};
    }
  }

  // ===== Leaderboard =====

  /// Get top pets leaderboard
  Future<List<Map<String, dynamic>>> getPetLeaderboard({
    int limit = 50,
    String orderBy = 'level',
  }) async {
    try {
      final query = _firestore
          .collection('userPets')
          .orderBy(orderBy, descending: true)
          .limit(limit)
          .snapshots();

      final snapshot = await query.first;
      final pets = snapshot.docs.map((doc) => doc.data()).toList();

      return pets;
    } catch (e) {
      LoggerService.error(
        'Error fetching pet leaderboard',
        tag: 'PetService',
        exception: e,
      );
      return [];
    }
  }

  /// Get user's pet rank
  Future<int?> getUserPetRank(
    String userId, {
    String orderBy = 'level',
  }) async {
    try {
      final allPets = await _firestore
          .collection('userPets')
          .orderBy(orderBy, descending: true)
          .get();

      int rank = 0;
      for (final doc in allPets.docs) {
        rank++;
        if (doc.id == userId) {
          return rank;
        }
      }

      return null;
    } catch (e) {
      LoggerService.error(
        'Error getting pet rank',
        tag: 'PetService',
        exception: e,
      );
      return null;
    }
  }

  // ===== Pet Food Shop =====

  /// Get available pet foods
  List<PetFood> getAvailableFoods() {
    return [
      const PetFood(
        foodId: 'apple',
        name: 'りんご',
        description: 'あっさりした味',
        satietyRestore: 20,
        cost: 10,
        icon: '🍎',
      ),
      const PetFood(
        foodId: 'banana',
        name: 'バナナ',
        description: 'あまいあじ',
        satietyRestore: 25,
        cost: 15,
        icon: '🍌',
      ),
      const PetFood(
        foodId: 'fish',
        name: 'さかな',
        description: 'えいようまんてん',
        satietyRestore: 35,
        cost: 25,
        icon: '🐟',
      ),
      const PetFood(
        foodId: 'meat',
        name: 'にく',
        description: 'パワーアップ!',
        satietyRestore: 40,
        cost: 40,
        icon: '🍖',
      ),
      const PetFood(
        foodId: 'deluxe',
        name: 'ごほうび',
        description: 'ぜんぶもりもり',
        satietyRestore: 100,
        cost: 99,
        icon: '🎉',
      ),
    ];
  }

  /// Get food by ID
  PetFood? getFoodById(String foodId) {
    try {
      return getAvailableFoods().firstWhere((food) => food.foodId == foodId);
    } catch (e) {
      return null;
    }
  }
}
