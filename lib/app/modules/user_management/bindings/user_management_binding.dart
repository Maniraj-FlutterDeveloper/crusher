import 'package:get/get.dart';
import '../controllers/user_management_controller.dart';
import '../../../data/repositories/user_repository.dart';

class UserManagementBinding extends Bindings {
  @override
  void dependencies() {
    // Register repository if not already registered
    if (!Get.isRegistered<UserRepository>()) {
      Get.put(UserRepository());
    }
    
    // Register controller
    Get.lazyPut<UserManagementController>(() => UserManagementController());
  }
}

