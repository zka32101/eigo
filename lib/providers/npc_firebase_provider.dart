import 'package:eigo_kore/services/npc_firebase_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final npcFirebaseServiceProvider = Provider<NPCFirebaseService>((ref) {
  return NPCFirebaseService();
});
