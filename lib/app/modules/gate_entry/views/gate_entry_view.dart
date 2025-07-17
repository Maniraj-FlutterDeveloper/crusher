import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import '../controllers/gate_entry_controller.dart';
import '../../../global_widgets/custom_form_field.dart';
import '../../../global_widgets/master_data_table.dart';
import '../../../global_widgets/responsive_layout.dart';
import '../../../core/values/app_colors.dart';
import '../../../core/values/app_constants.dart';
import '../../../data/models/gate_entry_model.dart';
import '../../../data/models/vehicle_model.dart';

class GateEntryView extends GetView<GateEntryController> {
  const GateEntryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gate Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchGateEntries,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(context),
        desktop: _buildDesktopLayout(context),
      ),
      floatingActionButton: Obx(() {
        if (controller.canAddGateEntries) {
          return FloatingActionButton(
            onPressed: () => _showVehicleInForm(context),
            child: const Icon(Icons.add),
            tooltip: 'Add Vehicle Entry',
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
          child: Column(
            children: [
              CustomSearchField(
                hint: 'Search by session ID, vehicle number, or driver name',
                controller: TextEditingController(),
                onChanged: controller.searchGateEntries,
                onClear: controller.clearSearch,
              ),
              const SizedBox(height: 16),
              _buildStatusFilter(),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final gateEntries = controller.getPaginatedGateEntries();
            if (gateEntries.isEmpty) {
              return const Center(
                child: Text('No gate entries found'),
              );
            }

            return ListView.builder(
              itemCount: gateEntries.length,
              itemBuilder: (context, index) {
                final gateEntry = gateEntries[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ExpansionTile(
                    title: Text('Session ID: ${gateEntry.sessionId}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vehicle: ${gateEntry.vehicle?.vehicleNumber ?? "N/A"}'),
                        Text('Entry Time: ${DateFormat(AppConstants.dateTimeFormat).format(gateEntry.entryTime)}'),
                        _buildStatusBadge(gateEntry.status),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Driver: ${gateEntry.driverName ?? "N/A"}'),
                            Text('Mobile: ${gateEntry.driverMobile ?? "N/A"}'),
                            Text('Tare Weight: ${gateEntry.tareWeight != null ? "${gateEntry.tareWeight} kg" : "N/A"}'),
                            Text('Gross Weight: ${gateEntry.grossWeight != null ? "${gateEntry.grossWeight} kg" : "N/A"}'),
                            Text('Net Weight: ${gateEntry.netWeight != null ? "${gateEntry.netWeight} kg" : "N/A"}'),
                            Text('Exit Time: ${gateEntry.exitTime != null ? DateFormat(AppConstants.dateTimeFormat).format(gateEntry.exitTime!) : "N/A"}'),
                            Text('Gate Pass: ${gateEntry.gatePassNumber}'),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.print),
                                  label: const Text('Print Gate Pass'),
                                  onPressed: () => controller.printGatePass(gateEntry),
                                ),
                                if (gateEntry.status != AppConstants.vehicleStatusDispatched)
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.exit_to_app),
                                    label: const Text('Vehicle Out'),
                                    onPressed: controller.canAddGateEntries
                                        ? () {
                                            controller.setGateEntryForVehicleOut(gateEntry);
                                            _showVehicleOutForm(context);
                                          }
                                        : null,
                                  ),
                                if (controller.canCancelGateEntries)
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.cancel),
                                    label: const Text('Cancel'),
                                    onPressed: () => _confirmCancel(context, gateEntry),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
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
                title: 'Gate Entry',
                searchField: CustomSearchField(
                  hint: 'Search by session ID, vehicle number, or driver name',
                  controller: TextEditingController(),
                  onChanged: controller.searchGateEntries,
                  onClear: controller.clearSearch,
                ),
                actions: Row(
                  children: [
                    _buildStatusFilter(),
                    const SizedBox(width: 16),
                    MasterDataTableActions(
                      onAdd: controller.canAddGateEntries
                          ? () => _showVehicleInForm(context)
                          : null,
                      onRefresh: controller.fetchGateEntries,
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

                  final gateEntries = controller.getPaginatedGateEntries();
                  
                  return MasterDataTable<GateEntryModel>(
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
                      DataColumn2(
                        label: const Text('Driver'),
                        tooltip: 'Driver Name',
                      ),
                      DataColumn2(
                        label: const Text('Entry Time'),
                        onSort: (_, __) => controller.changeSortColumn('entry_time'),
                        tooltip: 'Entry Time',
                      ),
                      DataColumn2(
                        label: const Text('Exit Time'),
                        onSort: (_, __) => controller.changeSortColumn('exit_time'),
                        tooltip: 'Exit Time',
                      ),
                      DataColumn2(
                        label: const Text('Net Weight'),
                        numeric: true,
                        tooltip: 'Net Weight',
                      ),
                      DataColumn2(
                        label: const Text('Status'),
                        onSort: (_, __) => controller.changeSortColumn('status'),
                        tooltip: 'Status',
                      ),
                      DataColumn2(
                        label: const Text('Actions'),
                        tooltip: 'Actions',
                        fixedWidth: 120,
                      ),
                    ],
                    data: gateEntries,
                    dataRowBuilder: (gateEntry, index) {
                      return DataRow2(
                        cells: [
                          DataCell(Text(gateEntry.sessionId)),
                          DataCell(Text(gateEntry.vehicle?.vehicleNumber ?? 'N/A')),
                          DataCell(Text(gateEntry.driverName ?? 'N/A')),
                          DataCell(Text(DateFormat(AppConstants.dateTimeFormat).format(gateEntry.entryTime))),
                          DataCell(Text(gateEntry.exitTime != null ? DateFormat(AppConstants.dateTimeFormat).format(gateEntry.exitTime!) : 'N/A')),
                          DataCell(Text(gateEntry.netWeight != null ? '${gateEntry.netWeight} kg' : 'N/A')),
                          DataCell(_buildStatusBadge(gateEntry.status)),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.print, size: 20),
                                  onPressed: () => controller.printGatePass(gateEntry),
                                  tooltip: 'Print Gate Pass',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                const SizedBox(width: 8),
                                if (gateEntry.status != AppConstants.vehicleStatusDispatched)
                                  IconButton(
                                    icon: const Icon(Icons.exit_to_app, size: 20),
                                    onPressed: controller.canAddGateEntries
                                        ? () {
                                            controller.setGateEntryForVehicleOut(gateEntry);
                                            _showVehicleOutForm(context);
                                          }
                                        : null,
                                    tooltip: 'Vehicle Out',
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                const SizedBox(width: 8),
                                if (controller.canCancelGateEntries)
                                  IconButton(
                                    icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
                                    onPressed: () => _confirmCancel(context, gateEntry),
                                    tooltip: 'Cancel',
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
                    emptyMessage: 'No gate entries found',
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

  Widget _buildStatusFilter() {
    return Obx(() => DropdownButton<String>(
      value: controller.selectedStatus.value,
      items: controller.statusOptions.map((String status) {
        return DropdownMenuItem<String>(
          value: status,
          child: Text(status),
        );
      }).toList(),
      onChanged: controller.changeStatusFilter,
      hint: const Text('Filter by Status'),
      isExpanded: true,
    ));
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: controller.getStatusColor(status).withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: controller.getStatusColor(status),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  int? _getSortColumnIndex() {
    switch (controller.sortColumn.value) {
      case 'session_id':
        return 0;
      case 'vehicle_number':
        return 1;
      case 'entry_time':
        return 3;
      case 'exit_time':
        return 4;
      case 'status':
        return 6;
      default:
        return 3;
    }
  }

  void _showVehicleInForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vehicle In'),
        content: SingleChildScrollView(
          child: Form(
            key: controller.vehicleInFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildVehicleSelector(context),
                const SizedBox(height: 16),
                CustomFormField(
                  label: 'Driver Name',
                  controller: controller.driverNameController,
                  hint: 'e.g., John Doe',
                ),
                const SizedBox(height: 16),
                CustomFormField(
                  label: 'Driver Mobile',
                  controller: controller.driverMobileController,
                  hint: 'e.g., 9876543210',
                  keyboardType: TextInputType.phone,
                  validator: controller.validateDriverMobile,
                ),
                const SizedBox(height: 16),
                CustomFormField(
                  label: 'Entry Time',
                  controller: controller.entryTimeController,
                  readOnly: true,
                  validator: controller.validateEntryTime,
                  suffix: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final DateTime now = DateTime.now();
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: now,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    
                    if (picked != null) {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      
                      if (pickedTime != null) {
                        final DateTime dateTime = DateTime(
                          picked.year,
                          picked.month,
                          picked.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                        
                        controller.entryTimeController.text = DateFormat(AppConstants.dateTimeFormat).format(dateTime);
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),
                CustomNumberField(
                  label: 'Tare Weight (kg)',
                  controller: controller.tareWeightController,
                  hint: 'e.g., 1000',
                  validator: controller.validateTareWeight,
                  suffixText: 'kg',
                ),
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
              controller.clearVehicleInForm();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          Obx(() => ElevatedButton(
            onPressed: controller.isProcessing.value
                ? null
                : () async {
                    if (await controller.saveVehicleIn()) {
                      Navigator.of(context).pop();
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

  void _showVehicleOutForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vehicle Out'),
        content: SingleChildScrollView(
          child: Form(
            key: controller.vehicleOutFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(() => controller.currentGateEntry.value != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Session ID: ${controller.currentGateEntry.value!.sessionId}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Vehicle: ${controller.currentGateEntry.value!.vehicle?.vehicleNumber ?? "N/A"}',
                          ),
                          Text(
                            'Driver: ${controller.currentGateEntry.value!.driverName ?? "N/A"}',
                          ),
                          Text(
                            'Tare Weight: ${controller.currentGateEntry.value!.tareWeight != null ? "${controller.currentGateEntry.value!.tareWeight} kg" : "N/A"}',
                          ),
                          Text(
                            'Entry Time: ${DateFormat(AppConstants.dateTimeFormat).format(controller.currentGateEntry.value!.entryTime)}',
                          ),
                        ],
                      )
                    : const Text('No gate entry selected')),
                const SizedBox(height: 16),
                CustomFormField(
                  label: 'Exit Time',
                  controller: controller.exitTimeController,
                  readOnly: true,
                  validator: controller.validateExitTime,
                  suffix: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final DateTime now = DateTime.now();
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: now,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    
                    if (picked != null) {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      
                      if (pickedTime != null) {
                        final DateTime dateTime = DateTime(
                          picked.year,
                          picked.month,
                          picked.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                        
                        controller.exitTimeController.text = DateFormat(AppConstants.dateTimeFormat).format(dateTime);
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),
                CustomNumberField(
                  label: 'Gross Weight (kg)',
                  controller: controller.grossWeightController,
                  hint: 'e.g., 5000',
                  validator: controller.validateGrossWeight,
                  suffixText: 'kg',
                  onChanged: (_) => controller.calculateNetWeight(),
                ),
                const SizedBox(height: 16),
                CustomNumberField(
                  label: 'Net Weight (kg)',
                  controller: controller.netWeightController,
                  readOnly: true,
                  suffixText: 'kg',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.clearVehicleOutForm();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          Obx(() => ElevatedButton(
            onPressed: controller.isProcessing.value
                ? null
                : () async {
                    if (await controller.saveVehicleOut()) {
                      Navigator.of(context).pop();
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

  Widget _buildVehicleSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomFormField(
          label: 'Vehicle Number',
          controller: controller.vehicleNumberController,
          validator: controller.validateVehicleNumber,
          readOnly: true,
          suffix: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showVehicleSearchDialog(context),
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => controller.selectedVehicle.value != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (controller.selectedVehicle.value!.vehicleType != null)
                    Text('Type: ${controller.selectedVehicle.value!.vehicleType}'),
                  if (controller.selectedVehicle.value!.capacity != null)
                    Text('Capacity: ${controller.selectedVehicle.value!.capacity} tons'),
                  if (controller.selectedVehicle.value!.ownerName != null)
                    Text('Owner: ${controller.selectedVehicle.value!.ownerName}'),
                ],
              )
            : const SizedBox.shrink()),
      ],
    );
  }

  void _showVehicleSearchDialog(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    final RxList<VehicleModel> searchResults = <VehicleModel>[].obs;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Vehicle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Vehicle Number',
                hintText: 'Enter vehicle number',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                if (value.length >= 2) {
                  searchResults.value = controller.searchVehicles(value);
                } else {
                  searchResults.clear();
                }
              },
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (searchResults.isEmpty) {
                return const Text('No vehicles found');
              }
              
              return SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final vehicle = searchResults[index];
                    return ListTile(
                      title: Text(vehicle.vehicleNumber),
                      subtitle: Text(vehicle.vehicleType ?? 'N/A'),
                      onTap: () {
                        controller.setVehicleForForm(vehicle);
                        Navigator.of(context).pop();
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

  void _confirmCancel(BuildContext context, GateEntryModel gateEntry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Cancel'),
        content: Text('Are you sure you want to cancel gate entry for ${gateEntry.vehicle?.vehicleNumber ?? "N/A"}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await controller.cancelGateEntry(gateEntry);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}

