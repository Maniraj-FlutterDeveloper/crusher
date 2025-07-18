import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/values/app_colors.dart';
import '../../controllers/reports_controller.dart';

class DashboardStatsView extends GetView<ReportsController> {
  const DashboardStatsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              
              return GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildStatCard(
                    'Total Vehicles',
                    controller.totalVehicles.value.toString(),
                    Icons.directions_car,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    'Vehicles In Process',
                    controller.vehiclesInProcess.value.toString(),
                    Icons.hourglass_bottom,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    'Vehicles Dispatched',
                    controller.vehiclesDispatched.value.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                  _buildStatCard(
                    'Total Material Loaded',
                    '${controller.totalMaterialLoaded.value.toStringAsFixed(2)} Tons',
                    Icons.category,
                    Colors.purple,
                  ),
                  _buildStatCard(
                    'Total Sales',
                    '₹${controller.totalSales.value.toStringAsFixed(2)}',
                    Icons.attach_money,
                    Colors.teal,
                  ),
                  _buildStatCard(
                    'Total Tax',
                    '₹${controller.totalTax.value.toStringAsFixed(2)}',
                    Icons.receipt,
                    Colors.red,
                  ),
                ],
              );
            }),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: controller.loadDashboardStatistics,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Statistics'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

