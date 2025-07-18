import 'package:get/get.dart';
import '../controllers/material_master_controller.dart';
import '../../../data/repositories/material_repository.dart';

class MaterialMasterBinding extends Bindings {
  @override
  void dependencies() {
    // Register repository if not already registered
    if (!Get.isRegistered<MaterialRepository>()) {
      Get.put(MaterialRepository());
    }
    
    // Register controller
    Get.lazyPut<MaterialMasterController>(() => MaterialMasterController());
  }
}

