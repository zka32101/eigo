import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eigo_kore/services/npc_firebase_service.dart';

/// ==================== NPC FIREBASE SERVICE PROVIDER ====================

/// NPC Firebase service instance (singleton)
final npcFirebaseServiceProvider = Provider<NPCFirebaseService>((ref) {
  return NPCFirebaseService();
});
