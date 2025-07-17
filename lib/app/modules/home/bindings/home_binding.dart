import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../data/services/auth_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    
    // Initialize auth service if not already initialized
    if (!Get.isRegistered<AuthService>()) {
      Get.put(AuthService());
    }
  }
}

