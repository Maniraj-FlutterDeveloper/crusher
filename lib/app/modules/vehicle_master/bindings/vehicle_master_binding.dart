import 'package:get/get.dart';
import '../controllers/vehicle_master_controller.dart';
import '../../../data/providers/db_provider.dart';
import '../../../data/repositories/vehicle_repository.dart';

class VehicleMasterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DbProvider>(() => DbProvider());
    Get.lazyPut<VehicleRepository>(() => VehicleRepository());
    Get.lazyPut<VehicleMasterController>(() => VehicleMasterController());
  }
}

