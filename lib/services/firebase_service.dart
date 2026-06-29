import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

/// Firebase/Firestore ラッパー。
/// google-services.json が存在しない場合や初期化失敗時は
/// graceful fallback（操作を無視）する。
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._();
  factory FirebaseService() => _instance;
  FirebaseService._();

  bool _available = false;
  FirebaseFirestore? _db;
  FirebaseAuth? _auth;

  bool get isAvailable => _available;

  Future<void> init() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _db = FirebaseFirestore.instance;
      _auth = FirebaseAuth.instance;
      // 匿名認証で一意ユーザーIDを確保
      if (_auth!.currentUser == null) {
        await _auth!.signInAnonymously();
      }
      _available = true;
    } catch (_) {
      // Firebase 未設定 or ネットワーク無し → ローカルのみで動作
      _available = false;
    }
  }

  String? get userId => _auth?.currentUser?.uid;

  /// 進捗をクラウドに同期
  Future<void> syncProgress({
    required Set<String> clearedStages,
    required int streakDays,
    required int totalLessons,
    required int totalSpeakingPractice,
    required Map<String, int> stageBestScores,
  }) async {
    if (!_available || userId == null) return;
    try {
      await _db!.collection('users').doc(userId).set({
        'clearedStages': clearedStages.toList(),
        'streakDays': streakDays,
        'totalLessons': totalLessons,
        'totalSpeakingPractice': totalSpeakingPractice,
        'stageBestScores': stageBestScores,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  /// クラウドから進捗を取得
  Future<Map<String, dynamic>?> fetchProgress() async {
    if (!_available || userId == null) return null;
    try {
      final doc = await _db!.collection('users').doc(userId).get();
      return doc.data();
    } catch (_) {
      return null;
    }
  }

  /// スピーキング履歴をクラウドに記録
  Future<void> addSpeakingRecord({
    required String date,         // YYYY-MM-DD
    required int wordCount,
    required int phraseCount,
    required int conversationCount,
    required double avgScore,
  }) async {
    if (!_available || userId == null) return;
    try {
      await _db!
          .collection('users')
          .doc(userId)
          .collection('speaking_history')
          .doc(date)
          .set({
        'date': date,
        'wordCount': wordCount,
        'phraseCount': phraseCount,
        'conversationCount': conversationCount,
        'avgScore': avgScore,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  /// 過去30日のスピーキング履歴を取得
  Future<List<Map<String, dynamic>>> fetchSpeakingHistory() async {
    if (!_available || userId == null) return [];
    try {
      final snap = await _db!
          .collection('users')
          .doc(userId)
          .collection('speaking_history')
          .orderBy('date', descending: true)
          .limit(30)
          .get();
      return snap.docs.map((d) => d.data()).toList();
    } catch (_) {
      return [];
    }
  }

  /// ランキング用 - 週次スコアを投稿
  Future<void> submitWeeklyScore({
    required String displayName,
    required double avgScore,
    required int weeklyPracticeCount,
  }) async {
    if (!_available || userId == null) return;
    try {
      final weekKey = _weekKey();
      await _db!.collection('weekly_ranking').doc('$weekKey/$userId').set({
        'uid': userId,
        'displayName': displayName,
        'avgScore': avgScore,
        'practiceCount': weeklyPracticeCount,
        'weekKey': weekKey,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  /// 週次ランキングを取得（上位20件）
  Future<List<Map<String, dynamic>>> fetchWeeklyRanking() async {
    if (!_available) return [];
    try {
      final weekKey = _weekKey();
      final snap = await _db!
          .collection('weekly_ranking')
          .where('weekKey', isEqualTo: weekKey)
          .orderBy('avgScore', descending: true)
          .limit(20)
          .get();
      return snap.docs.map((d) => d.data()).toList();
    } catch (_) {
      return [];
    }
  }

  String _weekKey() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
  }
}
