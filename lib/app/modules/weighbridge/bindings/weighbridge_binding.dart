import 'package:get/get.dart';
import '../controllers/weighbridge_controller.dart';
import '../../../data/repositories/weighbridge_repository.dart';
import '../../../data/repositories/gate_entry_repository.dart';
import '../../../data/repositories/vehicle_repository.dart';

class WeighbridgeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WeighbridgeRepository>(() => WeighbridgeRepository());
    Get.lazyPut<GateEntryRepository>(() => GateEntryRepository());
    Get.lazyPut<VehicleRepository>(() => VehicleRepository());
    Get.lazyPut<WeighbridgeController>(() => WeighbridgeController());
  }
}

