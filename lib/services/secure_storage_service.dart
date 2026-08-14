import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// SecureStorageService
///
/// Manages secure storage of sensitive data like authentication tokens,
/// API keys, and user credentials using platform-native secure storage:
/// - iOS: Keychain
/// - Android: Keystore
class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Token keys
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';

  // User credentials
  static const String _userEmailKey = 'user_email';
  static const String _userPasswordKey = 'user_password';

  // LLM API keys
  static const String _googleApiKeyKey = 'google_api_key';
  static const String _claudeApiKeyKey = 'claude_api_key';

  // Premium/subscription keys
  static const String _premiumTokenKey = 'premium_token';
  static const String _subscriptionIdKey = 'subscription_id';

  // Pet/voice settings
  static const String _petTokenKey = 'pet_token';

  /// Save authentication token
  static Future<void> saveAuthToken(String token) async {
    await _storage.write(key: _authTokenKey, value: token);
  }

  /// Retrieve authentication token
  static Future<String?> getAuthToken() async {
    return await _storage.read(key: _authTokenKey);
  }

  /// Save refresh token
  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// Retrieve refresh token
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Save user email (for email/password auth)
  static Future<void> saveUserEmail(String email) async {
    await _storage.write(key: _userEmailKey, value: email);
  }

  /// Retrieve user email
  static Future<String?> getUserEmail() async {
    return await _storage.read(key: _userEmailKey);
  }

  /// Save Google API key
  static Future<void> saveGoogleApiKey(String apiKey) async {
    await _storage.write(key: _googleApiKeyKey, value: apiKey);
  }

  /// Retrieve Google API key
  static Future<String?> getGoogleApiKey() async {
    return await _storage.read(key: _googleApiKeyKey);
  }

  /// Save Claude API key
  static Future<void> saveClaudeApiKey(String apiKey) async {
    await _storage.write(key: _claudeApiKeyKey, value: apiKey);
  }

  /// Retrieve Claude API key
  static Future<String?> getClaudeApiKey() async {
    return await _storage.read(key: _claudeApiKeyKey);
  }

  /// Save premium token
  static Future<void> savePremiumToken(String token) async {
    await _storage.write(key: _premiumTokenKey, value: token);
  }

  /// Retrieve premium token
  static Future<String?> getPremiumToken() async {
    return await _storage.read(key: _premiumTokenKey);
  }

  /// Save subscription ID
  static Future<void> saveSubscriptionId(String subscriptionId) async {
    await _storage.write(key: _subscriptionIdKey, value: subscriptionId);
  }

  /// Retrieve subscription ID
  static Future<String?> getSubscriptionId() async {
    return await _storage.read(key: _subscriptionIdKey);
  }

  /// Save pet token
  static Future<void> savePetToken(String petToken) async {
    await _storage.write(key: _petTokenKey, value: petToken);
  }

  /// Retrieve pet token
  static Future<String?> getPetToken() async {
    return await _storage.read(key: _petTokenKey);
  }

  /// Clear all stored data (logout)
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Clear specific token
  static Future<void> clearAuthToken() async {
    await _storage.delete(key: _authTokenKey);
  }

  /// Delete all keys (complete logout)
  static Future<void> clearAllKeys() async {
    final allKeys = [
      _authTokenKey,
      _refreshTokenKey,
      _userEmailKey,
      _userPasswordKey,
      _googleApiKeyKey,
      _claudeApiKeyKey,
      _premiumTokenKey,
      _subscriptionIdKey,
      _petTokenKey,
    ];

    for (final key in allKeys) {
      await _storage.delete(key: key);
    }
  }
}
