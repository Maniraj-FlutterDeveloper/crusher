import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reports_controller.dart';
import 'components/dashboard_stats_view.dart';
import 'components/report_selection_view.dart';
import '../../../core/utils/responsive_builder.dart';

class ReportsView extends GetView<ReportsController> {
  const ReportsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Dashboard'),
      ),
      body: ResponsiveBuilder(
        builder: (context, deviceType, size) {
          if (deviceType == DeviceScreenType.mobile) {
            return _buildMobileLayout();
          } else {
            return _buildDesktopLayout();
          }
        },
      ),
    );
  }
  
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: const [
          DashboardStatsView(),
          ReportSelectionView(),
        ],
      ),
    );
  }
  
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          flex: 1,
          child: DashboardStatsView(),
        ),
        const Expanded(
          flex: 1,
          child: ReportSelectionView(),
        ),
      ],
    );
  }
}

