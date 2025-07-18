import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/providers/db_provider.dart';
import '../../../core/values/app_constants.dart';

class DashboardController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final DbProvider _dbProvider = Get.find<DbProvider>();
  
  // Dashboard statistics
  final RxInt totalTrips = 0.obs;
  final RxDouble totalWeight = 0.0.obs;
  final RxInt pendingVehicles = 0.obs;
  final RxInt completedVehicles = 0.obs;
  final RxDouble totalRevenue = 0.0.obs;
  
  // Loading state
  final RxBool isLoading = true.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }
  
  // Load dashboard data
  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      
      // Get total trips
      final tripsResult = await _dbProvider.rawQuery(
        'SELECT COUNT(*) as count FROM gate_entry',
      );
      totalTrips.value = tripsResult.first['count'] as int;
      
      // Get total weight
      final weightResult = await _dbProvider.rawQuery(
        'SELECT SUM(net_weight) as total FROM gate_entry WHERE net_weight IS NOT NULL',
      );
      if (weightResult.first['total'] != null) {
        totalWeight.value = weightResult.first['total'] as double;
      }
      
      // Get pending vehicles
      final pendingResult = await _dbProvider.rawQuery(
        'SELECT COUNT(*) as count FROM gate_entry WHERE status != ?',
        [AppConstants.vehicleStatusDispatched],
      );
      pendingVehicles.value = pendingResult.first['count'] as int;
      
      // Get completed vehicles
      final completedResult = await _dbProvider.rawQuery(
        'SELECT COUNT(*) as count FROM gate_entry WHERE status = ?',
        [AppConstants.vehicleStatusDispatched],
      );
      completedVehicles.value = completedResult.first['count'] as int;
      
      // Get total revenue
      final revenueResult = await _dbProvider.rawQuery(
        'SELECT SUM(total_amount) as total FROM invoice',
      );
      if (revenueResult.first['total'] != null) {
        totalRevenue.value = revenueResult.first['total'] as double;
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Refresh dashboard data
  Future<void> refreshDashboardData() async {
    await loadDashboardData();
  }
}
