import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/values/app_constants.dart';
import '../../../data/models/audit_log_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/role_model.dart';
import '../../../data/models/permission_model.dart';
import '../../../data/repositories/audit_log_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/role_repository.dart';
import '../../../data/repositories/permission_repository.dart';
import '../../../data/services/auth_service.dart';

class SecurityController extends GetxController {
  final AuditLogRepository _auditLogRepository = Get.find<AuditLogRepository>();
  final UserRepository _userRepository = Get.find<UserRepository>();
  final RoleRepository _roleRepository = Get.find<RoleRepository>();
  final PermissionRepository _permissionRepository = Get.find<PermissionRepository>();
  final AuthService _authService = Get.find<AuthService>();
  
  // Observables
  final RxBool isLoading = false.obs;
  final RxBool isProcessing = false.obs;
  final RxString selectedTab = 'audit_logs'.obs;
  
  // Audit logs
  final RxList<AuditLogModel> auditLogs = <AuditLogModel>[].obs;
  final RxString auditLogFilter = ''.obs;
  final RxString auditLogModule = ''.obs;
  final RxString auditLogAction = ''.obs;
  final Rx<DateTime?> auditLogStartDate = Rx<DateTime?>(null);
  final Rx<DateTime?> auditLogEndDate = Rx<DateTime?>(null);
  
  // Users
  final RxList<UserModel> users = <UserModel>[].obs;
  final RxString userFilter = ''.obs;
  final Rx<UserModel?> selectedUser = Rx<UserModel?>(null);
  
  // Roles
  final RxList<RoleModel> roles = <RoleModel>[].obs;
  final RxString roleFilter = ''.obs;
  final Rx<RoleModel?> selectedRole = Rx<RoleModel?>(null);
  
  // Permissions
  final RxList<PermissionModel> permissions = <PermissionModel>[].obs;
  final RxString permissionFilter = ''.obs;
  final RxList<String> permissionModules = <String>[].obs;
  final RxString selectedPermissionModule = ''.obs;
  
  // Security settings
  final RxInt passwordMinLength = 8.obs;
  final RxBool passwordRequireUppercase = true.obs;
  final RxBool passwordRequireLowercase = true.obs;
  final RxBool passwordRequireNumbers = true.obs;
  final RxBool passwordRequireSpecialChars = true.obs;
  final RxInt passwordExpiryDays = 90.obs;
  final RxInt sessionTimeoutMinutes = 30.obs;
  final RxInt maxLoginAttempts = 5.obs;
  final RxInt lockoutDurationMinutes = 30.obs;
  final RxInt auditLogRetentionDays = 90.obs;
  
  // Form controllers
  final TextEditingController auditLogStartDateController = TextEditingController();
  final TextEditingController auditLogEndDateController = TextEditingController();
  
  @override
  void onInit() {
    super.onInit();
    loadAuditLogs();
    loadUsers();
    loadRoles();
    loadPermissions();
    loadSecuritySettings();
  }
  
  @override
  void onClose() {
    auditLogStartDateController.dispose();
    auditLogEndDateController.dispose();
    super.onClose();
  }
  
  // Change selected tab
  void changeTab(String tab) {
    selectedTab.value = tab;
  }
  
  // Load audit logs
  Future<void> loadAuditLogs() async {
    isLoading.value = true;
    
    try {
      List<AuditLogModel> logs;
      
      if (auditLogModule.isNotEmpty) {
        logs = await _auditLogRepository.getAuditLogsByModule(auditLogModule.value);
      } else if (auditLogAction.isNotEmpty) {
        logs = await _auditLogRepository.getAuditLogsByAction(auditLogAction.value);
      } else if (auditLogStartDate.value != null && auditLogEndDate.value != null) {
        logs = await _auditLogRepository.getAuditLogsByDateRange(
          auditLogStartDate.value!,
          auditLogEndDate.value!.add(const Duration(days: 1)),
        );
      } else {
        logs = await _auditLogRepository.getAllAuditLogs();
      }
      
      // Apply text filter if provided
      if (auditLogFilter.isNotEmpty) {
        logs = logs.where((log) {
          final filter = auditLogFilter.value.toLowerCase();
          
          return log.action.toLowerCase().contains(filter) ||
                 log.module.toLowerCase().contains(filter) ||
                 (log.details?.toLowerCase().contains(filter) ?? false) ||
                 (log.user?.name.toLowerCase().contains(filter) ?? false);
        }).toList();
      }
      
      auditLogs.assignAll(logs);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load audit logs: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Filter audit logs by module
  void filterAuditLogsByModule(String module) {
    auditLogModule.value = module;
    auditLogAction.value = '';
    auditLogStartDate.value = null;
    auditLogEndDate.value = null;
    auditLogStartDateController.clear();
    auditLogEndDateController.clear();
    loadAuditLogs();
  }
  
  // Filter audit logs by action
  void filterAuditLogsByAction(String action) {
    auditLogAction.value = action;
    auditLogModule.value = '';
    auditLogStartDate.value = null;
    auditLogEndDate.value = null;
    auditLogStartDateController.clear();
    auditLogEndDateController.clear();
    loadAuditLogs();
  }
  
  // Filter audit logs by date range
  void filterAuditLogsByDateRange(DateTime startDate, DateTime endDate) {
    auditLogStartDate.value = startDate;
    auditLogEndDate.value = endDate;
    auditLogModule.value = '';
    auditLogAction.value = '';
    auditLogStartDateController.text = DateFormat(AppConstants.dateFormat).format(startDate);
    auditLogEndDateController.text = DateFormat(AppConstants.dateFormat).format(endDate);
    loadAuditLogs();
  }
  
  // Clear audit log filters
  void clearAuditLogFilters() {
    auditLogFilter.value = '';
    auditLogModule.value = '';
    auditLogAction.value = '';
    auditLogStartDate.value = null;
    auditLogEndDate.value = null;
    auditLogStartDateController.clear();
    auditLogEndDateController.clear();
    loadAuditLogs();
  }
  
  // Select audit log start date
  Future<void> selectAuditLogStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: auditLogStartDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      auditLogStartDate.value = picked;
      auditLogStartDateController.text = DateFormat(AppConstants.dateFormat).format(picked);
      
      if (auditLogEndDate.value != null && auditLogEndDate.value!.isBefore(picked)) {
        auditLogEndDate.value = picked;
        auditLogEndDateController.text = DateFormat(AppConstants.dateFormat).format(picked);
      }
      
      if (auditLogEndDate.value != null) {
        filterAuditLogsByDateRange(auditLogStartDate.value!, auditLogEndDate.value!);
      }
    }
  }
  
  // Select audit log end date
  Future<void> selectAuditLogEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: auditLogEndDate.value ?? DateTime.now(),
      firstDate: auditLogStartDate.value ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      auditLogEndDate.value = picked;
      auditLogEndDateController.text = DateFormat(AppConstants.dateFormat).format(picked);
      
      if (auditLogStartDate.value != null) {
        filterAuditLogsByDateRange(auditLogStartDate.value!, auditLogEndDate.value!);
      }
    }
  }
  
  // Load users
  Future<void> loadUsers() async {
    isLoading.value = true;
    
    try {
      final allUsers = await _userRepository.getAllUsers();
      
      // Apply text filter if provided
      if (userFilter.isNotEmpty) {
        final filteredUsers = allUsers.where((user) {
          final filter = userFilter.value.toLowerCase();
          
          return user.name.toLowerCase().contains(filter) ||
                 user.email.toLowerCase().contains(filter) ||
                 (user.roles?.any((role) => role.name.toLowerCase().contains(filter)) ?? false);
        }).toList();
        
        users.assignAll(filteredUsers);
      } else {
        users.assignAll(allUsers);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load users: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Filter users
  void filterUsers(String filter) {
    userFilter.value = filter;
    loadUsers();
  }
  
  // Select user
  void selectUser(UserModel user) {
    selectedUser.value = user;
  }
  
  // Load roles
  Future<void> loadRoles() async {
    isLoading.value = true;
    
    try {
      final allRoles = await _roleRepository.getAllRoles();
      
      // Apply text filter if provided
      if (roleFilter.isNotEmpty) {
        final filteredRoles = allRoles.where((role) {
          final filter = roleFilter.value.toLowerCase();
          
          return role.name.toLowerCase().contains(filter) ||
                 (role.description?.toLowerCase().contains(filter) ?? false);
        }).toList();
        
        roles.assignAll(filteredRoles);
      } else {
        roles.assignAll(allRoles);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load roles: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Filter roles
  void filterRoles(String filter) {
    roleFilter.value = filter;
    loadRoles();
  }
  
  // Select role
  void selectRole(RoleModel role) {
    selectedRole.value = role;
  }
  
  // Load permissions
  Future<void> loadPermissions() async {
    isLoading.value = true;
    
    try {
      final allPermissions = await _permissionRepository.getAllPermissions();
      
      // Extract unique modules
      final modules = allPermissions.map((p) => p.module).toSet().toList();
      modules.sort();
      permissionModules.assignAll(modules);
      
      // Apply module filter if provided
      if (selectedPermissionModule.isNotEmpty) {
        final filteredPermissions = allPermissions.where((permission) {
          return permission.module == selectedPermissionModule.value;
        }).toList();
        
        permissions.assignAll(filteredPermissions);
      } else {
        permissions.assignAll(allPermissions);
      }
      
      // Apply text filter if provided
      if (permissionFilter.isNotEmpty) {
        final filter = permissionFilter.value.toLowerCase();
        final filteredPermissions = permissions.where((permission) {
          return permission.name.toLowerCase().contains(filter) ||
                 permission.code.toLowerCase().contains(filter) ||
                 (permission.description?.toLowerCase().contains(filter) ?? false);
        }).toList();
        
        permissions.assignAll(filteredPermissions);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load permissions: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Filter permissions by module
  void filterPermissionsByModule(String module) {
    selectedPermissionModule.value = module;
    loadPermissions();
  }
  
  // Filter permissions
  void filterPermissions(String filter) {
    permissionFilter.value = filter;
    loadPermissions();
  }
  
  // Load security settings
  void loadSecuritySettings() {
    // In a real app, these would be loaded from a settings repository
    // For now, we'll use default values
    passwordMinLength.value = 8;
    passwordRequireUppercase.value = true;
    passwordRequireLowercase.value = true;
    passwordRequireNumbers.value = true;
    passwordRequireSpecialChars.value = true;
    passwordExpiryDays.value = 90;
    sessionTimeoutMinutes.value = 30;
    maxLoginAttempts.value = 5;
    lockoutDurationMinutes.value = 30;
    auditLogRetentionDays.value = 90;
  }
  
  // Save security settings
  Future<void> saveSecuritySettings() async {
    isProcessing.value = true;
    
    try {
      // In a real app, these would be saved to a settings repository
      // For now, we'll just simulate a delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Log the action
      await _auditLogRepository.logAction(
        action: 'update',
        module: 'Security Settings',
        details: {
          'passwordMinLength': passwordMinLength.value,
          'passwordRequireUppercase': passwordRequireUppercase.value,
          'passwordRequireLowercase': passwordRequireLowercase.value,
          'passwordRequireNumbers': passwordRequireNumbers.value,
          'passwordRequireSpecialChars': passwordRequireSpecialChars.value,
          'passwordExpiryDays': passwordExpiryDays.value,
          'sessionTimeoutMinutes': sessionTimeoutMinutes.value,
          'maxLoginAttempts': maxLoginAttempts.value,
          'lockoutDurationMinutes': lockoutDurationMinutes.value,
          'auditLogRetentionDays': auditLogRetentionDays.value,
        },
        includeDeviceInfo: true,
      );
      
      Get.snackbar(
        'Success',
        'Security settings saved successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save security settings: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isProcessing.value = false;
    }
  }
  
  // Delete old audit logs
  Future<void> deleteOldAuditLogs() async {
    isProcessing.value = true;
    
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: auditLogRetentionDays.value));
      final deletedCount = await _auditLogRepository.deleteOldAuditLogs(cutoffDate);
      
      // Log the action
      await _auditLogRepository.logAction(
        action: 'delete',
        module: 'Audit Logs',
        details: {
          'deletedCount': deletedCount,
          'cutoffDate': cutoffDate.toIso8601String(),
        },
        includeDeviceInfo: true,
      );
      
      Get.snackbar(
        'Success',
        'Deleted $deletedCount old audit logs',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      // Reload audit logs
      loadAuditLogs();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete old audit logs: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isProcessing.value = false;
    }
  }
  
  // Check if user can access security settings
  bool get canAccessSecuritySettings {
    return _authService.hasPermission('security.settings.manage');
  }
  
  // Check if user can view audit logs
  bool get canViewAuditLogs {
    return _authService.hasPermission('security.audit_logs.view');
  }
}

