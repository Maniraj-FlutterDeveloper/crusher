import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/values/app_constants.dart';
import '../../controllers/reports_controller.dart';

class ReportSelectionView extends GetView<ReportsController> {
  const ReportSelectionView({Key? key}) : super(key: key);

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
              'Generate Reports',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Report Type:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildReportTypeSelection(),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.selectedReport.value.isEmpty) {
                return const SizedBox.shrink();
              }
              
              final selectedReport = controller.availableReports.firstWhere(
                (report) => report['id'] == controller.selectedReport.value,
              );
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Report: ${selectedReport['name']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Description: ${selectedReport['description']}',
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (selectedReport['requiresDateRange'] == true)
                    _buildDateRangeSelection(context)
                  else
                    _buildSingleDateSelection(context),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: controller.isProcessing.value
                          ? null
                          : () async {
                              final filePath = await controller.generateReport();
                              if (filePath != null) {
                                Get.toNamed('/pdf-viewer', arguments: {
                                  'path': filePath,
                                  'title': selectedReport['name'],
                                });
                              }
                            },
                      icon: controller.isProcessing.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.file_download),
                      label: Text(
                        controller.isProcessing.value
                            ? 'Generating...'
                            : 'Generate Report',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
  
  Widget _buildReportTypeSelection() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: controller.availableReports.length,
      itemBuilder: (context, index) {
        final report = controller.availableReports[index];
        
        return Obx(() {
          final isSelected = controller.selectedReport.value == report['id'];
          
          return InkWell(
            onTap: () => controller.selectReport(report['id']),
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                  width: 2,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    report['icon'],
                    size: 32,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    report['name'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
  
  Widget _buildSingleDateSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Date:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.dateController,
          decoration: InputDecoration(
            labelText: 'Date',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () => controller.selectDate(context),
            ),
          ),
          readOnly: true,
        ),
      ],
    );
  }
  
  Widget _buildDateRangeSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Date Range:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller.startDateController,
                decoration: InputDecoration(
                  labelText: 'Start Date',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => controller.selectStartDate(context),
                  ),
                ),
                readOnly: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: controller.endDateController,
                decoration: InputDecoration(
                  labelText: 'End Date',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => controller.selectEndDate(context),
                  ),
                ),
                readOnly: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

