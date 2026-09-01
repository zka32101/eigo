import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/friend_model.dart';

/// フレンド一覧を管理
final friendListProvider =
    StateNotifierProvider<FriendListNotifier, List<Friend>>((ref) {
  return FriendListNotifier();
});

class FriendListNotifier extends StateNotifier<List<Friend>> {
  static const String _storageKey = 'eigo_kore_friends';

  FriendListNotifier() : super([]) {
    _loadFriends();
  }

  /// フレンド一覧をロード
  Future<void> _loadFriends() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString);
        final items =
            decoded.map((json) => Friend.fromJson(json as Map<String, dynamic>)).toList();
        state = items;
      } catch (e) {
        print('Error loading friends: $e');
      }
    }
  }

  /// フレンド一覧を保存
  Future<void> _saveFriends() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(state.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  /// フレンドを追加
  Future<void> addFriend(Friend friend) async {
    if (!state.any((f) => f.userId == friend.userId)) {
      state = [...state, friend];
      await _saveFriends();
    }
  }

  /// フレンドを削除
  Future<void> removeFriend(String userId) async {
    state = state.where((f) => f.userId != userId).toList();
    await _saveFriends();
  }

  /// フレンドを更新
  Future<void> updateFriend(Friend friend) async {
    final index = state.indexWhere((f) => f.userId == friend.userId);
    if (index >= 0) {
      state = [
        ...state.sublist(0, index),
        friend,
        ...state.sublist(index + 1),
      ];
      await _saveFriends();
    }
  }

  /// お気に入り設定を切り替え
  Future<void> toggleFavorite(String userId) async {
    final friend = state.firstWhere((f) => f.userId == userId);
    await updateFriend(friend.copyWith(isFavorite: !friend.isFavorite));
  }

  /// お気に入りフレンド一覧を取得
  List<Friend> getFavoriteFriends() {
    return state.where((f) => f.isFavorite).toList();
  }

  /// フレンド数を取得
  int getFriendCount() => state.length;
}

/// フレンドリクエスト一覧を管理
final friendRequestsProvider =
    StateNotifierProvider<FriendRequestsNotifier, List<FriendRequest>>((ref) {
  return FriendRequestsNotifier();
});

class FriendRequestsNotifier extends StateNotifier<List<FriendRequest>> {
  static const String _storageKey = 'eigo_kore_friend_requests';

  FriendRequestsNotifier() : super([]) {
    _loadRequests();
  }

  /// リクエスト一覧をロード
  Future<void> _loadRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString);
        final items = decoded
            .map((json) => FriendRequest.fromJson(json as Map<String, dynamic>))
            .toList();
        state = items;
      } catch (e) {
        print('Error loading friend requests: $e');
      }
    }
  }

  /// リクエスト一覧を保存
  Future<void> _saveRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(state.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  /// リクエストを送信
  Future<void> sendRequest(FriendRequest request) async {
    if (!state.any((r) => r.fromUserId == request.fromUserId)) {
      state = [...state, request];
      await _saveRequests();
    }
  }

  /// リクエストを承認
  Future<void> acceptRequest(String requestId) async {
    final index = state.indexWhere((r) => r.requestId == requestId);
    if (index >= 0) {
      final request = state[index];
      state = [
        ...state.sublist(0, index),
        request.copyWith(status: FriendRequestStatus.accepted),
        ...state.sublist(index + 1),
      ];
      await _saveRequests();
    }
  }

  /// リクエストを拒否
  Future<void> rejectRequest(String requestId) async {
    final index = state.indexWhere((r) => r.requestId == requestId);
    if (index >= 0) {
      final request = state[index];
      state = [
        ...state.sublist(0, index),
        request.copyWith(status: FriendRequestStatus.rejected),
        ...state.sublist(index + 1),
      ];
      await _saveRequests();
    }
  }

  /// リクエストを削除
  Future<void> removeRequest(String requestId) async {
    state = state.where((r) => r.requestId != requestId).toList();
    await _saveRequests();
  }

  /// ペンディング状態のリクエストを取得
  List<FriendRequest> getPendingRequests() {
    return state.where((r) => r.status == FriendRequestStatus.pending).toList();
  }

  /// ペンディングリクエスト数を取得
  int getPendingCount() => getPendingRequests().length;
}
