import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../data/providers/db_provider.dart';
import '../../../data/repositories/user_repository.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DbProvider>(() => DbProvider());
    Get.lazyPut<UserRepository>(() => UserRepository());
    Get.lazyPut<AuthController>(() => AuthController());
  }
}

