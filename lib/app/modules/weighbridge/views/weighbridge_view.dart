import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import '../controllers/weighbridge_controller.dart';
import '../../../global_widgets/custom_form_field.dart';
import '../../../global_widgets/master_data_table.dart';
import '../../../global_widgets/responsive_layout.dart';
import '../../../core/values/app_constants.dart';
import '../../../data/models/gate_entry_model.dart';
import '../../../data/models/weighbridge_record_model.dart';

class WeighbridgeView extends GetView<WeighbridgeController> {
  const WeighbridgeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weighbridge'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchWeighbridgeRecords,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(context),
        desktop: _buildDesktopLayout(context),
      ),
      floatingActionButton: Obx(() {
        if (controller.canAddWeighbridgeRecords) {
          return FloatingActionButton(
            onPressed: () => _showGateEntrySearchDialog(context),
            tooltip: 'Add Weighbridge Record',
            child: const Icon(Icons.add),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: CustomSearchField(
            hint: 'Search by session ID, vehicle number, or driver name',
            controller: TextEditingController(),
            onChanged: controller.searchWeighbridgeRecords,
            onClear: controller.clearSearch,
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final weighbridgeRecords = controller.getPaginatedWeighbridgeRecords();
            if (weighbridgeRecords.isEmpty) {
              return const Center(
                child: Text('No weighbridge records found'),
              );
            }

            return ListView.builder(
              itemCount: weighbridgeRecords.length,
              itemBuilder: (context, index) {
                final record = weighbridgeRecords[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ExpansionTile(
                    title: Text('Session ID: ${record.gateEntry?.sessionId ?? "N/A"}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vehicle: ${record.gateEntry?.vehicle?.vehicleNumber ?? "N/A"}'),
                        Text('Net Weight: ${record.netWeight != null ? "${record.netWeight} ${record.weightUnit?.symbol ?? 'kg'}" : "N/A"}'),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Driver: ${record.gateEntry?.driverName ?? "N/A"}'),
                            Text('Tare Weight: ${record.tareWeight != null ? "${record.tareWeight} ${record.weightUnit?.symbol ?? 'kg'}" : "N/A"}'),
                            Text('Tare Weight Time: ${record.tareWeightTime != null ? DateFormat(AppConstants.dateTimeFormat).format(record.tareWeightTime!) : "N/A"}'),
                            Text('Gross Weight: ${record.grossWeight != null ? "${record.grossWeight} ${record.weightUnit?.symbol ?? 'kg'}" : "N/A"}'),
                            Text('Gross Weight Time: ${record.grossWeightTime != null ? DateFormat(AppConstants.dateTimeFormat).format(record.grossWeightTime!) : "N/A"}'),
                            Text('Remarks: ${record.remarks ?? "N/A"}'),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                if (controller.canPrintWeighbridgeRecords)
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.print),
                                    label: const Text('Print Weigh Slip'),
                                    onPressed: () => controller.printWeighSlip(record),
                                  ),
                                if (controller.canEditWeighbridgeRecords)
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Edit'),
                                    onPressed: () {
                                      if (record.gateEntry != null) {
                                        controller.setGateEntryForWeighbridge(record.gateEntry!);
                                        if (record.tareWeight != null && record.grossWeight == null) {
                                          _showGrossWeightForm(context);
                                        } else if (record.tareWeight == null) {
                                          _showTareWeightForm(context);
                                        } else {
                                          _showWeighbridgeDetailsDialog(context, record);
                                        }
                                      }
                                    },
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ),
        Obx(() {
          final totalPages = controller.totalPages.value;
          if (totalPages <= 1) return const SizedBox.shrink();

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: controller.currentPage.value > 0
                      ? () => controller.changePage(controller.currentPage.value - 1)
                      : null,
                ),
                Text(
                  'Page ${controller.currentPage.value + 1} of $totalPages',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: controller.currentPage.value < totalPages - 1
                      ? () => controller.changePage(controller.currentPage.value + 1)
                      : null,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              MasterDataTableHeader(
                title: 'Weighbridge Records',
                searchField: CustomSearchField(
                  hint: 'Search by session ID, vehicle number, or driver name',
                  controller: TextEditingController(),
                  onChanged: controller.searchWeighbridgeRecords,
                  onClear: controller.clearSearch,
                ),
                actions: Row(
                  children: [
                    MasterDataTableActions(
                      onAdd: controller.canAddWeighbridgeRecords
                          ? () => _showGateEntrySearchDialog(context)
                          : null,
                      onRefresh: controller.fetchWeighbridgeRecords,
                      onExport: () {}, // TODO: Implement export functionality
                      onPrint: () {}, // TODO: Implement print functionality
                      showDelete: false,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final weighbridgeRecords = controller.getPaginatedWeighbridgeRecords();
                  
                  return MasterDataTable<WeighbridgeRecordModel>(
                    columns: [
                      DataColumn2(
                        label: const Text('Session ID'),
                        onSort: (_, __) => controller.changeSortColumn('session_id'),
                        tooltip: 'Session ID',
                      ),
                      DataColumn2(
                        label: const Text('Vehicle Number'),
                        onSort: (_, __) => controller.changeSortColumn('vehicle_number'),
                        tooltip: 'Vehicle Number',
                      ),
                      const DataColumn2(
                        label: Text('Driver'),
                        tooltip: 'Driver Name',
                      ),
                      const DataColumn2(
                        label: Text('Tare Weight'),
                        numeric: true,
                        tooltip: 'Tare Weight',
                      ),
                      DataColumn2(
                        label: const Text('Tare Time'),
                        onSort: (_, __) => controller.changeSortColumn('tare_weight_time'),
                        tooltip: 'Tare Weight Time',
                      ),
                      const DataColumn2(
                        label: Text('Gross Weight'),
                        numeric: true,
                        tooltip: 'Gross Weight',
                      ),
                      DataColumn2(
                        label: const Text('Gross Time'),
                        onSort: (_, __) => controller.changeSortColumn('gross_weight_time'),
                        tooltip: 'Gross Weight Time',
                      ),
                      DataColumn2(
                        label: const Text('Net Weight'),
                        numeric: true,
                        onSort: (_, __) => controller.changeSortColumn('net_weight'),
                        tooltip: 'Net Weight',
                      ),
                      const DataColumn2(
                        label: Text('Actions'),
                        tooltip: 'Actions',
                        fixedWidth: 120,
                      ),
                    ],
                    data: weighbridgeRecords,
                    dataRowBuilder: (record, index) {
                      return DataRow2(
                        cells: [
                          DataCell(Text(record.gateEntry?.sessionId ?? 'N/A')),
                          DataCell(Text(record.gateEntry?.vehicle?.vehicleNumber ?? 'N/A')),
                          DataCell(Text(record.gateEntry?.driverName ?? 'N/A')),
                          DataCell(Text(record.tareWeight != null ? '${record.tareWeight} ${record.weightUnit?.symbol ?? 'kg'}' : 'N/A')),
                          DataCell(Text(record.tareWeightTime != null ? DateFormat(AppConstants.dateTimeFormat).format(record.tareWeightTime!) : 'N/A')),
                          DataCell(Text(record.grossWeight != null ? '${record.grossWeight} ${record.weightUnit?.symbol ?? 'kg'}' : 'N/A')),
                          DataCell(Text(record.grossWeightTime != null ? DateFormat(AppConstants.dateTimeFormat).format(record.grossWeightTime!) : 'N/A')),
                          DataCell(Text(record.netWeight != null ? '${record.netWeight} ${record.weightUnit?.symbol ?? 'kg'}' : 'N/A')),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (controller.canPrintWeighbridgeRecords)
                                  IconButton(
                                    icon: const Icon(Icons.print, size: 20),
                                    onPressed: () => controller.printWeighSlip(record),
                                    tooltip: 'Print Weigh Slip',
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                const SizedBox(width: 8),
                                if (controller.canEditWeighbridgeRecords)
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () {
                                      if (record.gateEntry != null) {
                                        controller.setGateEntryForWeighbridge(record.gateEntry!);
                                        if (record.tareWeight != null && record.grossWeight == null) {
                                          _showGrossWeightForm(context);
                                        } else if (record.tareWeight == null) {
                                          _showTareWeightForm(context);
                                        } else {
                                          _showWeighbridgeDetailsDialog(context, record);
                                        }
                                      }
                                    },
                                    tooltip: 'Edit',
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                              ],
                            ),
                          ),
                        ],
                        onTap: () {
                          // Show details in the side panel
                          // This will be implemented in a future update
                        },
                      );
                    },
                    isLoading: controller.isLoading.value,
                    emptyMessage: 'No weighbridge records found',
                    showCheckboxColumn: false,
                    sortAscending: controller.sortAscending.value,
                    sortColumnIndex: _getSortColumnIndex(),
                    rowsPerPage: controller.rowsPerPage.value,
                    availableRowsPerPage: const [10, 20, 50, 100],
                    onRowsPerPageChanged: controller.changeRowsPerPage,
                    currentPage: controller.currentPage.value,
                    totalPages: controller.totalPages.value,
                    onPageChanged: controller.changePage,
                  );
                }),
              ),
            ],
          ),
        ),
        // Side panel for details - will be implemented in a future update
        // Expanded(
        //   flex: 1,
        //   child: _buildDetailPanel(context),
        // ),
      ],
    );
  }

  int? _getSortColumnIndex() {
    switch (controller.sortColumn.value) {
      case 'session_id':
        return 0;
      case 'vehicle_number':
        return 1;
      case 'tare_weight_time':
        return 4;
      case 'gross_weight_time':
        return 6;
      case 'net_weight':
        return 7;
      default:
        return 4;
    }
  }

  void _showGateEntrySearchDialog(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    final RxList<GateEntryModel> searchResults = <GateEntryModel>[].obs;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Gate Entry'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Session ID or Vehicle Number',
                hintText: 'Enter session ID or vehicle number',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                if (value.length >= 2) {
                  controller.searchGateEntries(value).then((results) {
                    searchResults.value = results;
                  });
                } else {
                  searchResults.clear();
                }
              },
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (searchResults.isEmpty) {
                return const Text('No gate entries found');
              }
              
              return SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final gateEntry = searchResults[index];
                    return ListTile(
                      title: Text('Session ID: ${gateEntry.sessionId}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Vehicle: ${gateEntry.vehicle?.vehicleNumber ?? "N/A"}'),
                          Text('Status: ${gateEntry.status}'),
                        ],
                      ),
                      onTap: () {
                        controller.setGateEntryForWeighbridge(gateEntry);
                        Navigator.of(context).pop();
                        
                        // Show appropriate form based on gate entry status
                        if (gateEntry.tareWeight == null) {
                          _showTareWeightForm(context);
                        } else if (gateEntry.grossWeight == null) {
                          _showGrossWeightForm(context);
                        } else {
                          Get.snackbar(
                            'Info',
                            'This gate entry already has complete weighbridge data',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.blue,
                            colorText: Colors.white,
                          );
                        }
                      },
                    );
                  },
                ),
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showTareWeightForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Tare Weight'),
        content: SingleChildScrollView(
          child: Form(
            key: controller.tareWeightFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(() => controller.selectedGateEntry.value != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Session ID: ${controller.selectedGateEntry.value!.sessionId}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Vehicle: ${controller.selectedGateEntry.value!.vehicle?.vehicleNumber ?? "N/A"}',
                          ),
                          Text(
                            'Driver: ${controller.selectedGateEntry.value!.driverName ?? "N/A"}',
                          ),
                          Text(
                            'Entry Time: ${DateFormat(AppConstants.dateTimeFormat).format(controller.selectedGateEntry.value!.entryTime)}',
                          ),
                        ],
                      )
                    : const Text('No gate entry selected')),
                const SizedBox(height: 16),
                CustomNumberField(
                  label: 'Tare Weight',
                  controller: controller.tareWeightController,
                  hint: 'e.g., 1000',
                  validator: controller.validateTareWeight,
                  suffixText: controller.selectedWeightUnit.value?.symbol ?? 'kg',
                ),
                const SizedBox(height: 16),
                CustomFormField(
                  label: 'Tare Weight Time',
                  controller: controller.tareWeightTimeController,
                  readOnly: true,
                  validator: controller.validateTareWeightTime,
                  suffix: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final DateTime now = DateTime.now();
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: now,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    
                    if (!context.mounted) return;
                    
                    if (picked != null) {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      
                      if (!context.mounted) return;
                      
                      if (pickedTime != null) {
                        final DateTime dateTime = DateTime(
                          picked.year,
                          picked.month,
                          picked.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                        
                        controller.tareWeightTimeController.text = DateFormat(AppConstants.dateTimeFormat).format(dateTime);
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),
                Obx(() => DropdownButtonFormField<WeightUnitModel>(
                  value: controller.selectedWeightUnit.value,
                  items: controller.weightUnits.map((WeightUnitModel unit) {
                    return DropdownMenuItem<WeightUnitModel>(
                      value: unit,
                      child: Text('${unit.name} (${unit.symbol})'),
                    );
                  }).toList(),
                  onChanged: (WeightUnitModel? value) {
                    if (value != null) {
                      controller.selectedWeightUnit.value = value;
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Weight Unit',
                    border: OutlineInputBorder(),
                  ),
                )),
                const SizedBox(height: 16),
                CustomFormField(
                  label: 'Remarks',
                  controller: controller.remarksController,
                  hint: 'Any additional information',
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.clearForm();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          Obx(() => ElevatedButton(
            onPressed: controller.isProcessing.value
                ? null
                : () async {
                    final nav = Navigator.of(context);
                    if (await controller.saveTareWeight()) {
                      nav.pop();
                    }
                  },
            child: controller.isProcessing.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          )),
        ],
      ),
    );
  }

  void _showGrossWeightForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Gross Weight'),
        content: SingleChildScrollView(
          child: Form(
            key: controller.grossWeightFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(() => controller.selectedGateEntry.value != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Session ID: ${controller.selectedGateEntry.value!.sessionId}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Vehicle: ${controller.selectedGateEntry.value!.vehicle?.vehicleNumber ?? "N/A"}',
                          ),
                          Text(
                            'Driver: ${controller.selectedGateEntry.value!.driverName ?? "N/A"}',
                          ),
                          Text(
                            'Tare Weight: ${controller.selectedGateEntry.value!.tareWeight != null ? "${controller.selectedGateEntry.value!.tareWeight} kg" : "N/A"}',
                          ),
                        ],
                      )
                    : const Text('No gate entry selected')),
                const SizedBox(height: 16),
                CustomNumberField(
                  label: 'Gross Weight',
                  controller: controller.grossWeightController,
                  hint: 'e.g., 5000',
                  validator: controller.validateGrossWeight,
                  suffixText: controller.selectedWeightUnit.value?.symbol ?? 'kg',
                  onChanged: (_) => controller.calculateNetWeight(),
                ),
                const SizedBox(height: 16),
                CustomFormField(
                  label: 'Gross Weight Time',
                  controller: controller.grossWeightTimeController,
                  readOnly: true,
                  validator: controller.validateGrossWeightTime,
                  suffix: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final DateTime now = DateTime.now();
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: now,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    
                    if (!context.mounted) return;
                    
                    if (picked != null) {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      
                      if (!context.mounted) return;
                      
                      if (pickedTime != null) {
                        final DateTime dateTime = DateTime(
                          picked.year,
                          picked.month,
                          picked.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                        
                        controller.grossWeightTimeController.text = DateFormat(AppConstants.dateTimeFormat).format(dateTime);
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),
                CustomNumberField(
                  label: 'Net Weight',
                  controller: controller.netWeightController,
                  readOnly: true,
                  suffixText: controller.selectedWeightUnit.value?.symbol ?? 'kg',
                ),
                const SizedBox(height: 16),
                Obx(() => DropdownButtonFormField<WeightUnitModel>(
                  value: controller.selectedWeightUnit.value,
                  items: controller.weightUnits.map((WeightUnitModel unit) {
                    return DropdownMenuItem<WeightUnitModel>(
                      value: unit,
                      child: Text('${unit.name} (${unit.symbol})'),
                    );
                  }).toList(),
                  onChanged: (WeightUnitModel? value) {
                    if (value != null) {
                      controller.selectedWeightUnit.value = value;
                      controller.calculateNetWeight();
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Weight Unit',
                    border: OutlineInputBorder(),
                  ),
                )),
                const SizedBox(height: 16),
                CustomFormField(
                  label: 'Remarks',
                  controller: controller.remarksController,
                  hint: 'Any additional information',
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.clearForm();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          Obx(() => ElevatedButton(
            onPressed: controller.isProcessing.value
                ? null
                : () async {
                    final nav = Navigator.of(context);
                    if (await controller.saveGrossWeight()) {
                      nav.pop();
                    }
                  },
            child: controller.isProcessing.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          )),
        ],
      ),
    );
  }

  void _showWeighbridgeDetailsDialog(BuildContext context, WeighbridgeRecordModel record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Weighbridge Record Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Session ID: ${record.gateEntry?.sessionId ?? "N/A"}'),
              Text('Vehicle: ${record.gateEntry?.vehicle?.vehicleNumber ?? "N/A"}'),
              Text('Driver: ${record.gateEntry?.driverName ?? "N/A"}'),
              Text('Tare Weight: ${record.tareWeight != null ? "${record.tareWeight} ${record.weightUnit?.symbol ?? 'kg'}" : "N/A"}'),
              Text('Tare Weight Time: ${record.tareWeightTime != null ? DateFormat(AppConstants.dateTimeFormat).format(record.tareWeightTime!) : "N/A"}'),
              Text('Gross Weight: ${record.grossWeight != null ? "${record.grossWeight} ${record.weightUnit?.symbol ?? 'kg'}" : "N/A"}'),
              Text('Gross Weight Time: ${record.grossWeightTime != null ? DateFormat(AppConstants.dateTimeFormat).format(record.grossWeightTime!) : "N/A"}'),
              Text('Net Weight: ${record.netWeight != null ? "${record.netWeight} ${record.weightUnit?.symbol ?? 'kg'}" : "N/A"}'),
              Text('Remarks: ${record.remarks ?? "N/A"}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (controller.canPrintWeighbridgeRecords)
            ElevatedButton.icon(
              icon: const Icon(Icons.print),
              label: const Text('Print Weigh Slip'),
              onPressed: () {
                controller.printWeighSlip(record);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }
}

