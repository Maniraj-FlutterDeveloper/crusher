import 'package:get/get.dart';

import '../controllers/sync_controller.dart';
import '../../../data/repositories/sync_repository.dart';
import '../../../core/services/sync_service.dart';
import '../../../core/error/database_error_handler.dart';

class SyncBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure dependencies are registered
    if (!Get.isRegistered<DatabaseErrorHandler>()) {
      Get.put(DatabaseErrorHandler(
        logger: Get.find(),
        errorHandler: Get.find(),
      ));
    }

    // Register sync repository if not already registered
    if (!Get.isRegistered<SyncRepository>()) {
      Get.put(SyncRepository(), permanent: true);
    }

    // Register sync service if not already registered
    if (!Get.isRegistered<SyncService>()) {
      Get.put(SyncService(), permanent: true);
    }

    // Register the controller
    Get.lazyPut<SyncController>(() => SyncController());
  }
}

