import 'package:get/get.dart';

import '../error/database_error_handler.dart';
import '../error/error_handler.dart';
import '../../data/services/database_service.dart';

class DatabaseBinding extends Bindings {
  @override
  void dependencies() {
    // Register DatabaseErrorHandler if not already registered
    if (!Get.isRegistered<DatabaseErrorHandler>()) {
      Get.put(DatabaseErrorHandler(
        errorHandler: Get.find<ErrorHandler>(),
      ), permanent: true);
    }
    
    // Register DatabaseService if not already registered
    if (!Get.isRegistered<DatabaseService>()) {
      Get.putAsync(() => DatabaseService().init(), permanent: true);
    }
  }
}