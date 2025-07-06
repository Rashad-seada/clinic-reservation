import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final SharedPreferences _prefs;
  
  StorageService(this._prefs);
  
  // String operations
  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }
  
  String? getString(String key) {
    return _prefs.getString(key);
  }
  
  // Boolean operations
  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }
  
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }
  
  // Int operations
  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }
  
  int? getInt(String key) {
    return _prefs.getInt(key);
  }
  
  // Double operations
  Future<bool> setDouble(String key, double value) async {
    return await _prefs.setDouble(key, value);
  }
  
  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }
  
  // Object operations
  Future<bool> setObject(String key, Object value) async {
    return await _prefs.setString(key, jsonEncode(value));
  }
  
  Map<String, dynamic>? getObject(String key) {
    final String? data = _prefs.getString(key);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }
  
  // Remove and clear operations
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }
  
  Future<bool> clear() async {
    return await _prefs.clear();
  }
  
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }
} 