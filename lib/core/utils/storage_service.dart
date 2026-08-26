import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_constants.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'Initialize sharedPreferencesProvider in main.dart via overrideWithValue',
  );
});

final storageServiceProvider = Provider<StorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return StorageService(prefs);
});

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  Future<bool> saveToken(String token) async {
    return await _prefs.setString(StorageConstants.accessToken, token);
  }

  String? getToken() {
    return _prefs.getString(StorageConstants.accessToken);
  }

  Future<bool> clearToken() async {
    return await _prefs.remove(StorageConstants.accessToken);
  }

  Future<void> saveUserData({
    required String userId,
    required String email,
    String? displayName,
  }) async {
    await _prefs.setString(StorageConstants.userId, userId);
    await _prefs.setString(StorageConstants.userEmail, email);
    if (displayName != null) {
      await _prefs.setString(StorageConstants.displayName, displayName);
    }
  }

  Map<String, String?> getUserData() {
    return {
      'userId': _prefs.getString(StorageConstants.userId),
      'email': _prefs.getString(StorageConstants.userEmail),
      'displayName': _prefs.getString(StorageConstants.displayName),
    };
  }

  Future<bool> saveCachedProfile(String profileJson) async {
    return await _prefs.setString('cached_user_profile', profileJson);
  }

  String? getCachedProfile() {
    return _prefs.getString('cached_user_profile');
  }

  Future<bool> clearAll() async {
    return await _prefs.clear();
  }
}
