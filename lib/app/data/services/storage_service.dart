import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StorageService extends GetxService {
  static StorageService get to => Get.find<StorageService>();
  
  final GetStorage _box = GetStorage();
  
  // Initialize storage service
  Future<StorageService> init() async {
    await GetStorage.init();
    print('Storage service initialized');
    return this;
  }
  
  // Get string value
  String? getString(String key) {
    return _box.read<String>(key);
  }
  
  // Set string value
  Future<void> setString(String key, String value) async {
    await _box.write(key, value);
  }
  
  // Get int value
  int? getInt(String key) {
    return _box.read<int>(key);
  }
  
  // Set int value
  Future<void> setInt(String key, int value) async {
    await _box.write(key, value);
  }
  
  // Get double value
  double? getDouble(String key) {
    return _box.read<double>(key);
  }
  
  // Set double value
  Future<void> setDouble(String key, double value) async {
    await _box.write(key, value);
  }
  
  // Get bool value
  bool? getBool(String key) {
    return _box.read<bool>(key);
  }
  
  // Set bool value
  Future<void> setBool(String key, bool value) async {
    await _box.write(key, value);
  }
  
  // Get object value
  Map<String, dynamic>? getObject(String key) {
    final String? jsonString = _box.read<String>(key);
    if (jsonString == null) return null;
    return json.decode(jsonString) as Map<String, dynamic>;
  }
  
  // Set object value
  Future<void> setObject(String key, Map<String, dynamic> value) async {
    await _box.write(key, json.encode(value));
  }
  
  // Get list value
  List<dynamic>? getList(String key) {
    final String? jsonString = _box.read<String>(key);
    if (jsonString == null) return null;
    return json.decode(jsonString) as List<dynamic>;
  }
  
  // Set list value
  Future<void> setList(String key, List<dynamic> value) async {
    await _box.write(key, json.encode(value));
  }
  
  // Check if key exists
  bool hasKey(String key) {
    return _box.hasData(key);
  }
  
  // Remove key
  Future<void> remove(String key) async {
    await _box.remove(key);
  }
  
  // Clear all keys
  Future<void> clear() async {
    await _box.erase();
  }
}

