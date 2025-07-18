import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/dashboard_controller.dart';
import '../../../core/values/app_colors.dart';
import '../../../core/utils/responsive_builder.dart';
import '../../../global_widgets/responsive_layout.dart';
import '../../../routes/app_routes.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize controller if not already initialized
    if (!Get.isRegistered<DashboardController>()) {
      Get.put(DashboardController());
    }
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: controller.refreshDashboardData,
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                SizedBox(height: 24),
                _buildStatCards(context),
                SizedBox(height: 24),
                _buildRecentActivity(context),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: 8),
        Text(
          'Welcome to Crusher Management System',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textLightColor,
              ),
        ),
      ],
    );
  }

  Widget _buildStatCards(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 2,
    );
    
    final weightFormat = NumberFormat.decimalPattern();
    
    return ResponsiveGridView(
      children: [
        _buildStatCard(
          context,
          title: 'Total Trips',
          value: '${controller.totalTrips.value}',
          icon: Icons.directions_car,
          color: AppColors.primaryColor,
        ),
        _buildStatCard(
          context,
          title: 'Total Weight',
          value: '${weightFormat.format(controller.totalWeight.value)} kg',
          icon: Icons.scale,
          color: AppColors.secondaryColor,
        ),
        _buildStatCard(
          context,
          title: 'Pending Vehicles',
          value: '${controller.pendingVehicles.value}',
          icon: Icons.hourglass_empty,
          color: AppColors.warningColor,
        ),
        _buildStatCard(
          context,
          title: 'Completed Vehicles',
          value: '${controller.completedVehicles.value}',
          icon: Icons.check_circle,
          color: AppColors.successColor,
        ),
        _buildStatCard(
          context,
          title: 'Total Revenue',
          value: currencyFormat.format(controller.totalRevenue.value),
          icon: Icons.monetization_on,
          color: AppColors.billingColor,
        ),
      ],
      mobileColumns: 1,
      tabletColumns: 2,
      desktopColumns: 5,
      spacing: 16,
      runSpacing: 16,
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textLightColor,
                      ),
                ),
                Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: 16),
        ResponsiveLayout(
          mobile: _buildRecentActivityList(context),
          tablet: _buildRecentActivityList(context),
          desktop: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _buildRecentActivityList(context),
              ),
              SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: _buildQuickActions(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivityList(BuildContext context) {
    // This would normally be populated from a repository
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                    child: Icon(
                      Icons.directions_car,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  title: Text('Vehicle KA-01-AB-1234'),
                  subtitle: Text('Gate Entry - ${DateTime.now().subtract(Duration(hours: index)).toString().substring(0, 16)}'),
                  trailing: Chip(
                    label: Text('COMPLETED'),
                    backgroundColor: AppColors.successColor.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: AppColors.successColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () {
                  // Navigate to all transactions
                },
                child: Text('View All Transactions'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 16),
            _buildQuickActionButton(
              context,
              title: 'New Gate Entry',
              icon: Icons.add_circle,
              color: AppColors.gateEntryColor,
              onPressed: () {
                // Navigate to gate entry
              },
            ),
            SizedBox(height: 12),
            _buildQuickActionButton(
              context,
              title: 'Record Weight',
              icon: Icons.scale,
              color: AppColors.weighbridgeColor,
              onPressed: () {
                // Navigate to weighbridge
              },
            ),
            SizedBox(height: 12),
            _buildQuickActionButton(
              context,
              title: 'Generate Invoice',
              icon: Icons.receipt,
              color: AppColors.billingColor,
              onPressed: () {
                // Navigate to billing
              },
            ),
            SizedBox(height: 12),
            _buildQuickActionButton(
              context,
              title: 'View Reports',
              icon: Icons.bar_chart,
              color: AppColors.reportsColor,
              onPressed: () {
                // Navigate to reports
              },
            ),
            SizedBox(height: 12),
            _buildQuickActionButton(
              context,
              title: 'Data Synchronization',
              icon: Icons.sync,
              color: Colors.purple,
              onPressed: () {
                Get.toNamed(Routes.SYNC);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
