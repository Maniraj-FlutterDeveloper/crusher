import 'package:get/get.dart';
import '../controllers/gate_entry_controller.dart';
import '../../../data/providers/db_provider.dart';
import '../../../data/repositories/gate_entry_repository.dart';
import '../../../data/repositories/vehicle_repository.dart';

class GateEntryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DbProvider>(() => DbProvider());
    Get.lazyPut<GateEntryRepository>(() => GateEntryRepository());
    Get.lazyPut<VehicleRepository>(() => VehicleRepository());
    Get.lazyPut<GateEntryController>(() => GateEntryController());
  }
}

