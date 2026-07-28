import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/service_setlist.dart';

class StorageService {
  final SharedPreferences _prefs;

  static const String _favoritesKey = 'app_favorites';
  static const String _setlistsKey = 'app_setlists';

  StorageService(this._prefs);

  /// Factory initializer to set up SharedPreferences before app launch
  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // --- Favorites Persistence ---
  
  /// Retrieves list of saved favorite hymn IDs/numbers
  List<String> getFavorites() {
    return _prefs.getStringList(_favoritesKey) ?? [];
  }

  /// Saves list of favorite hymn IDs/numbers
  Future<bool> saveFavorites(List<String> favorites) {
    return _prefs.setStringList(_favoritesKey, favorites);
  }

  // --- Setlists Persistence ---

  /// Retrieves list of saved ServiceSetlist objects from JSON
  List<ServiceSetlist> getSetlists() {
    final String? rawJson = _prefs.getString(_setlistsKey);
    if (rawJson == null || rawJson.isEmpty) return [];
    
    try {
      final List<dynamic> decoded = jsonDecode(rawJson);
      return decoded.map((item) => ServiceSetlist.fromJson(item)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Encodes and saves list of ServiceSetlist objects to JSON
  Future<bool> saveSetlists(List<ServiceSetlist> setlists) {
    final List<Map<String, dynamic>> jsonList = 
        setlists.map((s) => s.toJson()).toList();
    return _prefs.setString(_setlistsKey, jsonEncode(jsonList));
  }

  // --- Primitive Storage Helpers ---

  bool? getBool(String key) => _prefs.getBool(key);
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  double? getDouble(String key) => _prefs.getDouble(key);
  Future<bool> setDouble(String key, double value) => _prefs.setDouble(key, value);

  String? getString(String key) => _prefs.getString(key);
  Future<bool> setString(String key, String value) => _prefs.setString(key, value);

  List<String>? getStringList(String key) => _prefs.getStringList(key);
  Future<bool> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  int? getInt(String key) => _prefs.getInt(key);
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);

  bool containsKey(String key) => _prefs.containsKey(key);
  Future<bool> remove(String key) => _prefs.remove(key);
  Future<bool> clear() => _prefs.clear();
}