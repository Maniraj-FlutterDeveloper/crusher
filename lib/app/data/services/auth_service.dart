import 'package:get/get.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import 'storage_service.dart';
import '../../core/values/app_constants.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find<AuthService>();
  
  final UserRepository _userRepository = Get.find<UserRepository>();
  final StorageService _storageService = Get.find<StorageService>();
  
  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);
  UserModel? get currentUser => _currentUser.value;
  
  // Initialize auth service
  Future<AuthService> init() async {
    // Check if user is already logged in
    await _loadUserFromStorage();
    print('Auth service initialized');
    return this;
  }
  
  // Load user from storage
  Future<void> _loadUserFromStorage() async {
    final Map<String, dynamic>? userData = _storageService.getObject(AppConstants.storageUserKey);
    
    if (userData != null) {
      try {
        final UserModel user = UserModel.fromJson(userData);
        _currentUser.value = user;
        print('User loaded from storage: ${user.username}');
      } catch (e) {
        print('Error loading user from storage: $e');
        await _storageService.remove(AppConstants.storageUserKey);
      }
    }
  }
  
  // Save user to storage
  Future<void> _saveUserToStorage(UserModel user) async {
    await _storageService.setObject(AppConstants.storageUserKey, user.toJson());
  }
  
  // Login
  Future<bool> login(String username, String password) async {
    try {
      final UserModel? user = await _userRepository.authenticateUser(username, password);
      
      if (user != null) {
        _currentUser.value = user;
        await _saveUserToStorage(user);
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error during login: $e');
      return false;
    }
  }
  
  // Logout
  Future<void> logout() async {
    _currentUser.value = null;
    await _storageService.remove(AppConstants.storageUserKey);
  }
  
  // Check if user is logged in
  bool isLoggedIn() {
    return _currentUser.value != null;
  }
  
  // Check if user has permission
  Future<bool> hasPermission(String permissionName) async {
    if (!isLoggedIn() || _currentUser.value!.id == null) {
      return false;
    }
    
    return await _userRepository.hasPermission(_currentUser.value!.id!, permissionName);
  }
  
  // Check if user has role
  Future<bool> hasRole(String roleName) async {
    if (!isLoggedIn() || _currentUser.value!.id == null) {
      return false;
    }
    
    return await _userRepository.hasRole(_currentUser.value!.id!, roleName);
  }
  
  // Refresh user data
  Future<void> refreshUserData() async {
    if (isLoggedIn() && _currentUser.value!.id != null) {
      final UserModel? user = await _userRepository.getUserWithRoles(_currentUser.value!.id!);
      
      if (user != null) {
        _currentUser.value = user;
        await _saveUserToStorage(user);
      }
    }
  }
}

