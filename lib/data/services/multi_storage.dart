import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:html' as html; // For localStorage

class MultiStorageHandler {
  // Key for storing user ID
  static const String _storageKey = 'user_id';

  final FlutterSecureStorage _secureStorage;

  MultiStorageHandler(this._secureStorage);

  /// Save user ID to all storages
  Future<bool> saveUserId(String userId) async {
    int count = 0;

    // Save to localStorage
    html.window.localStorage[_storageKey] = userId;
    count++;

    // Save to FlutterSecureStorage
    await _secureStorage.write(key: _storageKey, value: userId);
    count++;

    print("User ID saved to all storages.");
    return count == 3;
  }

  /// Retrieve user ID from all storages
  Future<String?> retrieveUserId() async {
    print("Retrieving user ID...");

    // Retrieve from localStorage
    String? localStorageData = html.window.localStorage[_storageKey];
    print("localStorage data: $localStorageData");

    // Retrieve from FlutterSecureStorage
    String? secureStorageData = await _secureStorage.read(key: _storageKey);
    print("FlutterSecureStorage data: $secureStorageData");

    // Return user ID from the first available storage
    return localStorageData ?? secureStorageData;
  }

  /// Check which storages contain the user ID
  Future<bool> checkUserIdAvailability() async {
    bool existsInLocalStorage = html.window.localStorage.containsKey(_storageKey);
    print("Exists in localStorage: $existsInLocalStorage");

    bool existsInSecureStorage = (await _secureStorage.read(key: _storageKey)) != null;
    print("Exists in FlutterSecureStorage: $existsInSecureStorage");

    // Return true if the user ID exists in any storage
    return existsInLocalStorage || existsInSecureStorage;
  }

  /// Clear user ID from all storages
  Future<void> clearUserId() async {
    // Clear localStorage
    html.window.localStorage.remove(_storageKey);

    // Clear FlutterSecureStorage
    await _secureStorage.delete(key: _storageKey);

    print("User ID cleared from all storages.");
  }
}
