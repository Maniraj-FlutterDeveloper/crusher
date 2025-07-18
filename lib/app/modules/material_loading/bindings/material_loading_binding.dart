import 'package:get/get.dart';
import '../controllers/material_loading_controller.dart';
import '../../../data/repositories/material_loading_repository.dart';
import '../../../data/repositories/gate_entry_repository.dart';
import '../../../data/repositories/weighbridge_repository.dart';

class MaterialLoadingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MaterialLoadingRepository>(() => MaterialLoadingRepository());
    Get.lazyPut<GateEntryRepository>(() => GateEntryRepository());
    Get.lazyPut<WeighbridgeRepository>(() => WeighbridgeRepository());
    Get.lazyPut<MaterialLoadingController>(() => MaterialLoadingController());
  }
}

