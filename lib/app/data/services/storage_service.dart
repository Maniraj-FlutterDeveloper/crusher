import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  static StorageService get to => Get.find<StorageService>();
  
  late SharedPreferences _prefs;
  
  // Initialize storage service
  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    print('Storage service initialized');
    return this;
  }
  
  // Get string value
  String? getString(String key) {
    return _prefs.getString(key);
  }
  
  // Set string value
  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }
  
  // Get int value
  int? getInt(String key) {
    return _prefs.getInt(key);
  }
  
  // Set int value
  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }
  
  // Get double value
  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }
  
  // Set double value
  Future<bool> setDouble(String key, double value) async {
    return await _prefs.setDouble(key, value);
  }
  
  // Get bool value
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }
  
  // Set bool value
  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }
  
  // Get string list value
  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }
  
  // Set string list value
  Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs.setStringList(key, value);
  }
  
  // Get object value
  Map<String, dynamic>? getObject(String key) {
    final String? jsonString = _prefs.getString(key);
    if (jsonString == null) {
      return null;
    }
    return json.decode(jsonString) as Map<String, dynamic>;
  }
  
  // Set object value
  Future<bool> setObject(String key, Map<String, dynamic> value) async {
    return await _prefs.setString(key, json.encode(value));
  }
  
  // Get object list value
  List<Map<String, dynamic>>? getObjectList(String key) {
    final String? jsonString = _prefs.getString(key);
    if (jsonString == null) {
      return null;
    }
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList.cast<Map<String, dynamic>>();
  }
  
  // Set object list value
  Future<bool> setObjectList(String key, List<Map<String, dynamic>> value) async {
    return await _prefs.setString(key, json.encode(value));
  }
  
  // Check if key exists
  bool hasKey(String key) {
    return _prefs.containsKey(key);
  }
  
  // Remove value
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }
  
  // Clear all values
  Future<bool> clear() async {
    return await _prefs.clear();
  }
  
  // Get all keys
  Set<String> getKeys() {
    return _prefs.getKeys();
  }
}

