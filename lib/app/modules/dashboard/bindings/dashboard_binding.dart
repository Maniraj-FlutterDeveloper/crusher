import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../../../data/providers/db_provider.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DbProvider>(() => DbProvider());
    Get.lazyPut<DashboardController>(() => DashboardController());
  }
}

