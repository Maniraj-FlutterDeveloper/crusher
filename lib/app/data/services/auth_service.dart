import 'package:get/get.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import 'storage_service.dart';
import '../../core/values/app_constants.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find<AuthService>();
  
  final StorageService _storageService = Get.find<StorageService>();
  late final UserRepository _userRepository;
  
  // Observables
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoggedIn = false.obs;
  
  // Initialize auth service
  Future<AuthService> init() async {
    _userRepository = Get.find<UserRepository>();
    
    // Check if user is logged in
    await checkAuth();
    
    print('Auth service initialized');
    return this;
  }
  
  // Check if user is authenticated
  Future<bool> checkAuth() async {
    final userData = _storageService.getObject(AppConstants.storageUserKey);
    
    if (userData != null) {
      try {
        final user = UserModel.fromJson(userData);
        currentUser.value = user;
        isLoggedIn.value = true;
        return true;
      } catch (e) {
        print('Error parsing user data: $e');
        await logout();
      }
    }
    
    return false;
  }
  
  // Login
  Future<bool> login(String username, String password) async {
    try {
      final user = await _userRepository.getUserByCredentials(username, password);
      
      if (user != null) {
        // Get user roles and permissions
        final userWithRoles = await _userRepository.getUserWithRolesAndPermissions(user.id!);
        
        if (userWithRoles != null) {
          // Update last login
          final updatedUser = userWithRoles.copyWith(
            lastLogin: DateTime.now(),
          );
          
          await _userRepository.updateUser(updatedUser);
          
          // Save user to storage
          await _storageService.setObject(AppConstants.storageUserKey, updatedUser.toJson());
          
          // Update current user
          currentUser.value = updatedUser;
          isLoggedIn.value = true;
          
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
    await _storageService.remove(AppConstants.storageUserKey);
    currentUser.value = null;
    isLoggedIn.value = false;
  }
  
  // Get current user
  Future<UserModel?> getCurrentUser() async {
    if (currentUser.value != null) {
      return currentUser.value;
    }
    
    await checkAuth();
    return currentUser.value;
  }

  // Check if user is admin
  bool get isAdmin => hasRole(AppConstants.roleAdmin);

  // Check if user is supervisor
  bool get isSupervisor => hasRole(AppConstants.roleSupervisor);
  
  // Check if user has role
  bool hasRole(String roleName) {
    if (currentUser.value == null || currentUser.value!.roles == null) {
      return false;
    }
    
    return currentUser.value!.roles!.any((role) => role.name == roleName && role.isActive);
  }
  
  // Check if user has permission
  bool hasPermission(String permissionName) {
    if (currentUser.value == null || currentUser.value!.roles == null) {
      return false;
    }
    
    // Admin role has all permissions
    if (hasRole(AppConstants.roleAdmin)) {
      return true;
    }
    
    // Check if any role has the permission
    for (final role in currentUser.value!.roles!) {
      if (role.isActive && role.permissions != null) {
        if (role.permissions!.any((permission) => permission.name == permissionName)) {
          return true;
        }
      }
    }
    
    return false;
  }
  
  // Check if user has any of the permissions
  bool hasAnyPermission(List<String> permissionNames) {
    if (currentUser.value == null || currentUser.value!.roles == null) {
      return false;
    }
    
    // Admin role has all permissions
    if (hasRole(AppConstants.roleAdmin)) {
      return true;
    }
    
    // Check if any role has any of the permissions
    for (final role in currentUser.value!.roles!) {
      if (role.isActive && role.permissions != null) {
        for (final permissionName in permissionNames) {
          if (role.permissions!.any((permission) => permission.name == permissionName)) {
            return true;
          }
        }
      }
    }
    
    return false;
  }
  
  // Check if user has all of the permissions
  bool hasAllPermissions(List<String> permissionNames) {
    if (currentUser.value == null || currentUser.value!.roles == null) {
      return false;
    }
    
    // Admin role has all permissions
    if (hasRole(AppConstants.roleAdmin)) {
      return true;
    }
    
    // Check if user has all of the permissions
    for (final permissionName in permissionNames) {
      if (!hasPermission(permissionName)) {
        return false;
      }
    }
    
    return true;
  }
}

