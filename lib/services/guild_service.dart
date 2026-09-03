import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/guild.dart';
import 'logger_service.dart';

/// Service for managing guilds and guild membership
/// Phase 15 Part 2: Guilds/Teams System
class GuildService {
  static final GuildService _instance = GuildService._internal();

  factory GuildService() {
    return _instance;
  }

  GuildService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LoggerService _logger = LoggerService();

  /// Create a new guild
  Future<String?> createGuild(
    String name,
    String description,
    String icon,
    String leaderId,
    GuildSettings settings,
  ) async {
    try {
      final guildId = _firestore.collection('guilds').doc().id;
      final now = DateTime.now();

      await _firestore.collection('guilds').doc(guildId).set({
        'id': guildId,
        'name': name,
        'description': description,
        'icon': icon,
        'leaderId': leaderId,
        'memberIds': [leaderId],
        'level': 1,
        'totalScore': 0,
        'tier': 'bronze',
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'settings': settings.toJson(),
      });

      // Add guild member subcollection
      await _firestore
          .collection('guilds')
          .doc(guildId)
          .collection('members')
          .doc(leaderId)
          .set({
        'userId': leaderId,
        'userName': 'Leader',
        'userAvatar': '👑',
        'role': 'leader',
        'contributionScore': 0,
        'joinedAt': now.toIso8601String(),
        'isActive': true,
      });

      return guildId;
    } catch (e) {
      _logger.error('Failed to create guild', e);
      return null;
    }
  }

  /// Join a guild (for open guilds)
  Future<bool> joinGuild(String guildId, String userId, String userName, String userAvatar) async {
    try {
      final guildRef = _firestore.collection('guilds').doc(guildId);
      final guildDoc = await guildRef.get();
      final guildData = guildDoc.data() as Map<String, dynamic>;
      final memberIds = List<String>.from(guildData['memberIds'] as List? ?? []);

      if (memberIds.contains(userId)) {
        return false; // Already a member
      }

      memberIds.add(userId);
      await guildRef.update({'memberIds': memberIds, 'updatedAt': DateTime.now().toIso8601String()});

      // Add member to subcollection
      await guildRef.collection('members').doc(userId).set({
        'userId': userId,
        'userName': userName,
        'userAvatar': userAvatar,
        'role': 'member',
        'contributionScore': 0,
        'joinedAt': DateTime.now().toIso8601String(),
        'isActive': true,
      });

      return true;
    } catch (e) {
      _logger.error('Failed to join guild', e);
      return false;
    }
  }

  /// Leave a guild
  Future<bool> leaveGuild(String guildId, String userId) async {
    try {
      final guildRef = _firestore.collection('guilds').doc(guildId);
      final guildDoc = await guildRef.get();
      final guildData = guildDoc.data() as Map<String, dynamic>;
      final memberIds = List<String>.from(guildData['memberIds'] as List? ?? []);
      final leaderId = guildData['leaderId'] as String;

      if (userId == leaderId) {
        return false; // Leader cannot leave
      }

      memberIds.remove(userId);
      await guildRef.update({'memberIds': memberIds, 'updatedAt': DateTime.now().toIso8601String()});

      // Remove from members subcollection
      await guildRef.collection('members').doc(userId).delete();

      return true;
    } catch (e) {
      _logger.error('Failed to leave guild', e);
      return false;
    }
  }

  /// Get user's guilds
  Future<List<Guild>> getUserGuilds(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('guilds')
          .where('memberIds', arrayContains: userId)
          .get();

      return snapshot.docs
          .map((doc) => Guild.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.error('Failed to fetch user guilds', e);
      return [];
    }
  }

  /// Get guild by ID
  Future<Guild?> getGuild(String guildId) async {
    try {
      final doc = await _firestore.collection('guilds').doc(guildId).get();
      if (!doc.exists) return null;

      return Guild.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      _logger.error('Failed to fetch guild', e);
      return null;
    }
  }

  /// Get guild members
  Future<List<GuildMember>> getGuildMembers(String guildId) async {
    try {
      final snapshot = await _firestore
          .collection('guilds')
          .doc(guildId)
          .collection('members')
          .orderBy('contributionScore', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => GuildMember.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.error('Failed to fetch guild members', e);
      return [];
    }
  }

  /// Update guild info (leader only)
  Future<bool> updateGuild(
    String guildId,
    String name,
    String description,
    String icon,
  ) async {
    try {
      await _firestore.collection('guilds').doc(guildId).update({
        'name': name,
        'description': description,
        'icon': icon,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      _logger.error('Failed to update guild', e);
      return false;
    }
  }

  /// Update member contribution score
  Future<bool> updateMemberContribution(
    String guildId,
    String userId,
    int points,
  ) async {
    try {
      final memberRef = _firestore
          .collection('guilds')
          .doc(guildId)
          .collection('members')
          .doc(userId);

      final memberDoc = await memberRef.get();
      final memberData = memberDoc.data() as Map<String, dynamic>?;
      final currentScore = memberData?['contributionScore'] as int? ?? 0;

      await memberRef.update({
        'contributionScore': currentScore + points,
      });

      // Update guild total score
      final guildRef = _firestore.collection('guilds').doc(guildId);
      final guildDoc = await guildRef.get();
      final guildData = guildDoc.data() as Map<String, dynamic>;
      final currentTotal = guildData['totalScore'] as int? ?? 0;

      await guildRef.update({
        'totalScore': currentTotal + points,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      _logger.error('Failed to update member contribution', e);
      return false;
    }
  }

  /// Change member role
  Future<bool> changeMemberRole(
    String guildId,
    String userId,
    GuildRole role,
  ) async {
    try {
      await _firestore
          .collection('guilds')
          .doc(guildId)
          .collection('members')
          .doc(userId)
          .update({
        'role': role.toString().split('.').last,
      });

      return true;
    } catch (e) {
      _logger.error('Failed to change member role', e);
      return false;
    }
  }

  /// Remove member from guild
  Future<bool> removeMember(String guildId, String userId) async {
    try {
      final guildRef = _firestore.collection('guilds').doc(guildId);
      final guildDoc = await guildRef.get();
      final guildData = guildDoc.data() as Map<String, dynamic>;
      final memberIds = List<String>.from(guildData['memberIds'] as List? ?? []);

      memberIds.remove(userId);
      await guildRef.update({'memberIds': memberIds, 'updatedAt': DateTime.now().toIso8601String()});

      // Remove from members subcollection
      await guildRef.collection('members').doc(userId).delete();

      return true;
    } catch (e) {
      _logger.error('Failed to remove guild member', e);
      return false;
    }
  }

  /// Get public guilds for browsing
  Future<List<Guild>> getPublicGuilds({int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('guilds')
          .where('settings.isPublic', isEqualTo: true)
          .orderBy('totalScore', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Guild.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.error('Failed to fetch public guilds', e);
      return [];
    }
  }

  /// Search guilds by name
  Future<List<Guild>> searchGuilds(String query, {int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('guilds')
          .where('settings.isPublic', isEqualTo: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Guild.fromJson(doc.data() as Map<String, dynamic>))
          .where((guild) => guild.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      _logger.error('Failed to search guilds', e);
      return [];
    }
  }

  /// Stream guild members for real-time updates
  Stream<List<GuildMember>> streamGuildMembers(String guildId) {
    try {
      return _firestore
          .collection('guilds')
          .doc(guildId)
          .collection('members')
          .orderBy('contributionScore', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => GuildMember.fromJson(doc.data() as Map<String, dynamic>))
              .toList());
    } catch (e) {
      _logger.error('Failed to stream guild members', e);
      return Stream.value([]);
    }
  }
}
