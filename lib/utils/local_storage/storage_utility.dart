import 'package:shared_preferences/shared_preferences.dart';

class TLocalStorage {
  static SharedPreferences? _storage;

  // Singleton instance
  static TLocalStorage? _instance;

  TLocalStorage._internal();

  factory TLocalStorage.instance() {
    _instance ??= TLocalStorage._internal();
    return _instance!;
  }

  /// Asynchronous initialization method
  static Future<void> init() async {
    _storage = await SharedPreferences.getInstance();
    _instance = TLocalStorage._internal();
  }

  /// Generic method to save data
  Future<void> writeData<T>(String key, T value) async {
    if (_storage == null) return;
    
    if (value is String) {
      await _storage!.setString(key, value);
    } else if (value is int) {
      await _storage!.setInt(key, value);
    } else if (value is bool) {
      await _storage!.setBool(key, value);
    } else if (value is double) {
      await _storage!.setDouble(key, value);
    } else if (value is List<String>) {
      await _storage!.setStringList(key, value);
    }
  }

  /// Generic method to read data
  T? readData<T>(String key) {
    if (_storage == null) return null;
    return _storage!.get(key) as T?;
  }

  /// Generic method to remove data
  Future<void> removeData(String key) async {
    if (_storage == null) return;
    await _storage!.remove(key);
  }

  /// Clear all data in storage
  Future<void> clearAll() async {
    if (_storage == null) return;
    await _storage!.clear();
  }
}
