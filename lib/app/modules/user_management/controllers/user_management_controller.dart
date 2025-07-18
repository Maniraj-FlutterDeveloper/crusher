import 'package:get/get.dart';
import '../../../core/error/error_handler.dart';
import '../../../core/services/logger_service.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../global_widgets/error_display.dart';

class UserManagementController extends GetxController {
  final UserRepository _repository = Get.find<UserRepository>();
  final LoggerService _logger = Get.find<LoggerService>();
  final ErrorHandler _errorHandler = Get.find<ErrorHandler>();
  
  final RxBool isLoading = false.obs;
  final RxList<UserModel> users = <UserModel>[].obs;
  final RxList<UserModel> filteredUsers = <UserModel>[].obs;
  
  final RxString searchQuery = ''.obs;
  final RxString filterRole = 'All'.obs;
  final RxInt sortColumnIndex = 0.obs;
  final RxBool sortAscending = true.obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }
  
  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      final result = await _repository.getAllUsers();
      users.value = result;
      filterUsers(searchQuery.value);
      _logger.info('Fetched ${users.length} users');
    } catch (e, stackTrace) {
      final error = await _errorHandler.handleError(e, stackTrace);
      ErrorSnackbar.show(error);
      _logger.error('Failed to fetch users', e);
    } finally {
      isLoading.value = false;
    }
  }
  
  void refreshUsers() {
    fetchUsers();
  }
  
  void filterUsers(String query) {
    searchQuery.value = query;
    
    if (query.isEmpty && filterRole.value == 'All') {
      filteredUsers.value = users;
    } else {
      filteredUsers.value = users.where((user) {
        final fullName = '${user.firstName} ${user.lastName}'.toLowerCase();
        
        final matchesQuery = query.isEmpty || 
            fullName.contains(query.toLowerCase()) ||
            user.username.toLowerCase().contains(query.toLowerCase()) ||
            user.email.toLowerCase().contains(query.toLowerCase());
        
        final matchesRole = filterRole.value == 'All' || 
            user.role == filterRole.value;
        
        return matchesQuery && matchesRole;
      }).toList();
    }
    
    sortUsers(sortColumnIndex.value, sortAscending.value);
  }
  
  void sortUsers(int columnIndex, bool ascending) {
    sortColumnIndex.value = columnIndex;
    sortAscending.value = ascending;
    
    filteredUsers.sort((a, b) {
      var result = 0;
      
      switch (columnIndex) {
        case 0: // Name
          final aName = '${a.firstName} ${a.lastName}';
          final bName = '${b.firstName} ${b.lastName}';
          result = aName.compareTo(bName);
          break;
        case 1: // Username
          result = a.username.compareTo(b.username);
          break;
        case 2: // Email
          result = a.email.compareTo(b.email);
          break;
        case 3: // Role
          result = a.role.compareTo(b.role);
          break;
        case 4: // Status
          result = a.isActive == b.isActive ? 0 : (a.isActive ? 1 : -1);
          break;
        case 5: // Last Login
          if (a.lastLoginAt == null && b.lastLoginAt == null) {
            result = 0;
          } else if (a.lastLoginAt == null) {
            result = -1;
          } else if (b.lastLoginAt == null) {
            result = 1;
          } else {
            result = a.lastLoginAt!.compareTo(b.lastLoginAt!);
          }
          break;
        default:
          result = 0;
      }
      
      return ascending ? result : -result;
    });
  }
  
  Future<void> addUser(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      final user = UserModel.fromJson(data);
      await _repository.createUser(user, data['password']);
      await fetchUsers();
      Get.snackbar(
        'Success',
        'User added successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      _logger.info('Added new user: ${user.username}');
    } catch (e, stackTrace) {
      final error = await _errorHandler.handleError(e, stackTrace);
      ErrorSnackbar.show(error);
      _logger.error('Failed to add user', e);
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      final user = UserModel.fromJson({...data, 'id': id});
      await _repository.updateUser(user);
      await fetchUsers();
      Get.snackbar(
        'Success',
        'User updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      _logger.info('Updated user: ${user.username}');
    } catch (e, stackTrace) {
      final error = await _errorHandler.handleError(e, stackTrace);
      ErrorSnackbar.show(error);
      _logger.error('Failed to update user', e);
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> resetPassword(int id, String newPassword) async {
    try {
      isLoading.value = true;
      await _repository.resetPassword(id, newPassword);
      Get.snackbar(
        'Success',
        'Password reset successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      _logger.info('Reset password for user ID: $id');
    } catch (e, stackTrace) {
      final error = await _errorHandler.handleError(e, stackTrace);
      ErrorSnackbar.show(error);
      _logger.error('Failed to reset password', e);
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> deleteUser(int id) async {
    try {
      isLoading.value = true;
      await _repository.deleteUser(id);
      await fetchUsers();
      Get.snackbar(
        'Success',
        'User deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      _logger.info('Deleted user with ID: $id');
    } catch (e, stackTrace) {
      final error = await _errorHandler.handleError(e, stackTrace);
      ErrorSnackbar.show(error);
      _logger.error('Failed to delete user', e);
    } finally {
      isLoading.value = false;
    }
  }
}

