import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/challenge_model.dart';
import 'logger_service.dart';

class ChallengeService {
  static final ChallengeService _instance = ChallengeService._internal();

  factory ChallengeService() {
    return _instance;
  }

  ChallengeService._internal();

  final _firestore = FirebaseFirestore.instance;
  final _logger = LoggerService();

  // Create a new challenge
  Future<SocialChallenge> createChallenge(
    SocialChallenge challenge,
  ) async {
    try {
      final docRef = _firestore.collection('challenges').doc();
      final newChallenge = challenge.copyWith(id: docRef.id);
      
      await docRef.set(newChallenge.toJson());
      return newChallenge;
    } catch (e) {
      _logger.error('Error creating challenge', e);
      throw Exception('チャレンジの作成に失敗しました');
    }
  }

  // Get challenge by ID
  Future<SocialChallenge> getChallengeById(String challengeId) async {
    try {
      final snapshot = await _firestore
          .collection('challenges')
          .doc(challengeId)
          .get();

      if (!snapshot.exists) {
        throw Exception('チャレンジが見つかりません');
      }

      return SocialChallenge.fromJson(snapshot.data() as Map<String, dynamic>);
    } catch (e) {
      _logger.error('Error fetching challenge', e);
      rethrow;
    }
  }

  // Get active challenges (public)
  Future<List<SocialChallenge>> getActiveChallenges({int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('challenges')
          .where('status', isEqualTo: 'active')
          .where('isPublic', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => SocialChallenge.fromJson(doc.data()))
          .toList();
    } catch (e) {
      _logger.error('Error fetching active challenges', e);
      return [];
    }
  }

  // Get challenges created by user
  Future<List<SocialChallenge>> getUserCreatedChallenges(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('challenges')
          .where('creatorId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => SocialChallenge.fromJson(doc.data()))
          .toList();
    } catch (e) {
      _logger.error('Error fetching user challenges', e);
      return [];
    }
  }

  // Get challenges joined by user
  Future<List<SocialChallenge>> getUserJoinedChallenges(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('challenges')
          .where('participants', arrayContains: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => SocialChallenge.fromJson(doc.data()))
          .toList();
    } catch (e) {
      _logger.error('Error fetching joined challenges', e);
      return [];
    }
  }

  // Get challenges by type
  Future<List<SocialChallenge>> getChallengesByType(
    ChallengeType type, {
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('challenges')
          .where('type', isEqualTo: type.toString())
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => SocialChallenge.fromJson(doc.data()))
          .toList();
    } catch (e) {
      _logger.error('Error fetching challenges by type', e);
      return [];
    }
  }

  // Join a challenge
  Future<ChallengeParticipation> joinChallenge(
    String challengeId,
    String userId,
    String userName,
    String userAvatar,
  ) async {
    try {
      // Check if already joined
      final existing = await _firestore
          .collection('challenges')
          .doc(challengeId)
          .collection('participants')
          .where('userId', isEqualTo: userId)
          .get();

      if (existing.docs.isNotEmpty) {
        throw Exception('既にこのチャレンジに参加しています');
      }

      final participation = ChallengeParticipation(
        id: _firestore.collection('temp').doc().id,
        challengeId: challengeId,
        userId: userId,
        userName: userName,
        userAvatar: userAvatar,
        joinedAt: DateTime.now(),
        currentScore: 0,
        currentRank: 0,
        hasCompleted: false,
        activityLog: [],
      );

      // Add to participants subcollection
      await _firestore
          .collection('challenges')
          .doc(challengeId)
          .collection('participants')
          .doc(participation.id)
          .set(participation.toJson());

      // Update challenge participant count
      await _firestore
          .collection('challenges')
          .doc(challengeId)
          .update({
        'currentParticipants': FieldValue.increment(1),
        'participants.$userId': 0,
      });

      return participation;
    } catch (e) {
      _logger.error('Error joining challenge', e);
      rethrow;
    }
  }

  // Update participant score
  Future<void> updateParticipantScore(
    String challengeId,
    String userId,
    int newScore,
  ) async {
    try {
      await _firestore
          .collection('challenges')
          .doc(challengeId)
          .update({
        'participants.$userId': newScore,
      });
    } catch (e) {
      _logger.error('Error updating participant score', e);
      rethrow;
    }
  }

  // Complete challenge
  Future<ChallengeResult> completeChallenge(
    String challengeId,
    String userId,
    int finalScore,
    int xpEarned,
    int coinsEarned,
  ) async {
    try {
      final challenge = await getChallengeById(challengeId);
      final topParticipants = challenge.getTopParticipants(limit: 3);
      
      int rank = 999;
      for (int i = 0; i < topParticipants.length; i++) {
        if (topParticipants[i].key == userId) {
          rank = i + 1;
          break;
        }
      }

      bool isWinner = rank == 1;
      bool isPrizeWon = rank <= 3;
      String? prizeType;
      int? prizeAmount;

      if (rank == 1) prizeType = 'first';
      if (rank == 2) prizeType = 'second';
      if (rank == 3) prizeType = 'third';

      if (prizeType != null) {
        if (prizeType == 'first') prizeAmount = challenge.firstPlacePrize;
        if (prizeType == 'second') prizeAmount = challenge.secondPlacePrize;
        if (prizeType == 'third') prizeAmount = challenge.thirdPlacePrize;
      }

      final result = ChallengeResult(
        id: _firestore.collection('temp').doc().id,
        challengeId: challengeId,
        userId: userId,
        userName: challenge.participants.entries
            .firstWhere((e) => e.key == userId)
            .key,
        userAvatar: '', // TODO: Get from user profile
        finalScore: finalScore,
        finalRank: rank,
        completedAt: DateTime.now(),
        xpEarned: xpEarned,
        coinsEarned: coinsEarned,
        isWinner: isWinner,
        isPrizeWon: isPrizeWon,
        prizeType: prizeType,
        prizeAmount: prizeAmount,
        badgesEarned: [],
      );

      await _firestore
          .collection('challenges')
          .doc(challengeId)
          .collection('results')
          .doc(result.id)
          .set(result.toJson());

      return result;
    } catch (e) {
      _logger.error('Error completing challenge', e);
      rethrow;
    }
  }

  // Invite users to challenge
  Future<void> inviteUsersToChallenge(
    String challengeId,
    List<String> userIds,
    String inviterName,
  ) async {
    try {
      final challenge = await getChallengeById(challengeId);

      for (final userId in userIds) {
        final invitation = ChallengeInvitation(
          id: _firestore.collection('temp').doc().id,
          challengeId: challengeId,
          invitedUserId: userId,
          invitedUserName: '', // TODO: Get from user profile
          inviterUserId: challenge.creatorId,
          inviterName: inviterName,
          invitedAt: DateTime.now(),
          accepted: false,
          challengeTitle: challenge.title,
          challengeDescription: challenge.description,
        );

        await _firestore
            .collection('users')
            .doc(userId)
            .collection('invitations')
            .doc(invitation.id)
            .set(invitation.toJson());
      }

      // Update challenge invitations
      await _firestore
          .collection('challenges')
          .doc(challengeId)
          .update({
        'invitedUserIds': FieldValue.arrayUnion(userIds),
      });
    } catch (e) {
      _logger.error('Error inviting users', e);
      rethrow;
    }
  }

  // Get challenge invitations
  Future<List<ChallengeInvitation>> getChallengeInvitations(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('invitations')
          .where('accepted', isEqualTo: false)
          .orderBy('invitedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ChallengeInvitation.fromJson(doc.data()))
          .toList();
    } catch (e) {
      _logger.error('Error fetching invitations', e);
      return [];
    }
  }

  // Accept invitation
  Future<void> acceptChallengeInvitation(
    String invitationId,
    String challengeId,
    String userId,
  ) async {
    try {
      // Join the challenge
      final challenge = await getChallengeById(challengeId);
      await joinChallenge(challengeId, userId, '', '');

      // Mark invitation as accepted
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('invitations')
          .doc(invitationId)
          .update({'accepted': true, 'respondedAt': DateTime.now()});
    } catch (e) {
      _logger.error('Error accepting invitation', e);
      rethrow;
    }
  }

  // Get challenge statistics
  Future<ChallengeStats> getUserChallengeStats(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('challenge_stats')
          .doc('stats')
          .get();

      if (!snapshot.exists) {
        return _createDefaultStats(userId);
      }

      return ChallengeStats.fromJson(snapshot.data() as Map<String, dynamic>);
    } catch (e) {
      _logger.error('Error fetching challenge stats', e);
      return _createDefaultStats(userId);
    }
  }

  // Search challenges
  Future<List<SocialChallenge>> searchChallenges(
    String query, {
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('challenges')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: '${query}z')
          .where('status', isEqualTo: 'active')
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => SocialChallenge.fromJson(doc.data()))
          .toList();
    } catch (e) {
      _logger.error('Error searching challenges', e);
      return [];
    }
  }

  // Helper methods
  ChallengeStats _createDefaultStats(String userId) {
    return ChallengeStats(
      userId: userId,
      totalChallengesCreated: 0,
      totalChallengesJoined: 0,
      totalChallengesWon: 0,
      totalXpFromChallenges: 0,
      totalCoinsFromChallenges: 0,
      winRate: 0,
      averageRank: 0,
      favoriteTypes: [],
      lastChallengeDate: DateTime.now(),
    );
  }
}
