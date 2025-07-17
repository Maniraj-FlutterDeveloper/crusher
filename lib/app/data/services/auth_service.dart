import 'package:get/get.dart';
import '../models/user_model.dart';
import '../providers/db_provider.dart';
import 'storage_service.dart';
import '../../core/values/app_constants.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find<AuthService>();
  
  final DbProvider _dbProvider = Get.find<DbProvider>();
  final StorageService _storageService = Get.find<StorageService>();
  
  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);
  final RxBool _isLoggedIn = false.obs;
  
  // Get current user
  UserModel? get currentUser => _currentUser.value;
  
  // Check if user is logged in
  bool get isLoggedIn => _isLoggedIn.value;
  
  // Initialize auth service
  Future<AuthService> init() async {
    // Check if user is logged in
    final String? userJson = _storageService.getString(AppConstants.storageUserKey);
    if (userJson != null) {
      try {
        final Map<String, dynamic> userMap = _storageService.getObject(AppConstants.storageUserKey)!;
        _currentUser.value = UserModel.fromJson(userMap);
        _isLoggedIn.value = true;
        print('User logged in: ${_currentUser.value!.username}');
      } catch (e) {
        print('Error parsing user data: $e');
        await logout();
      }
    }
    
    print('Auth service initialized');
    return this;
  }
  
  // Login
  Future<bool> login(String username, String password) async {
    try {
      final Map<String, dynamic>? userMap = await _dbProvider.getUserByUsername(username);
      if (userMap != null && userMap['password'] == password) {
        // Get user with roles and permissions
        final Map<String, dynamic>? userWithRoles = await _dbProvider.getUserWithRolesAndPermissions(userMap['id']);
        if (userWithRoles != null) {
          // Create user model
          final UserModel user = UserModel.fromJson(userWithRoles);
          
          // Update last login
          await _dbProvider.update(
            'user',
            {
              'last_login': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            },
            user.id!,
          );
          
          // Save user to storage
          await _storageService.setObject(AppConstants.storageUserKey, user.toJson());
          
          // Set current user
          _currentUser.value = user;
          _isLoggedIn.value = true;
          
          return true;
        }
      }
      
      return false;
    } catch (e) {
      print('Error logging in: $e');
      return false;
    }
  }
  
  // Logout
  Future<void> logout() async {
    try {
      await _storageService.remove(AppConstants.storageUserKey);
      _currentUser.value = null;
      _isLoggedIn.value = false;
    } catch (e) {
      print('Error logging out: $e');
    }
  }
  
  // Check if user has permission
  bool hasPermission(String permission) {
    if (_currentUser.value == null || _currentUser.value!.roles == null) {
      return false;
    }
    
    for (var role in _currentUser.value!.roles!) {
      if (role.permissions != null) {
        for (var perm in role.permissions!) {
          if (perm.name == permission) {
            return true;
          }
        }
      }
    }
    
    return false;
  }
  
  // Check if user has role
  bool hasRole(String role) {
    if (_currentUser.value == null || _currentUser.value!.roles == null) {
      return false;
    }
    
    for (var r in _currentUser.value!.roles!) {
      if (r.name == role) {
        return true;
      }
    }
    
    return false;
  }
  
  // Check if user is admin
  bool get isAdmin => hasRole(AppConstants.roleAdmin);
  
  // Check if user is supervisor
  bool get isSupervisor => hasRole(AppConstants.roleSupervisor);
  
  // Check if user is billing operator
  bool get isBillingOperator => hasRole(AppConstants.roleBilling);
  
  // Check if user is operator
  bool get isOperator => hasRole(AppConstants.roleOperator);
}

