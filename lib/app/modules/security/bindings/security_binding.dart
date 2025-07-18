import 'package:get/get.dart';
import '../controllers/security_controller.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/role_repository.dart';
import '../../../data/repositories/permission_repository.dart';
import '../../../data/repositories/audit_log_repository.dart';
import '../../../data/services/auth_service.dart';

class SecurityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserRepository>(() => UserRepository());
    Get.lazyPut<RoleRepository>(() => RoleRepository());
    Get.lazyPut<PermissionRepository>(() => PermissionRepository());
    Get.lazyPut<AuditLogRepository>(() => AuditLogRepository());
    Get.lazyPut<SecurityController>(() => SecurityController());
  }
}

