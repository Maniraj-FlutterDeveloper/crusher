import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:data_table_2/data_table_2.dart';
import '../controllers/vehicle_master_controller.dart';
import '../../../global_widgets/custom_form_field.dart';
import '../../../global_widgets/master_data_table.dart';
import '../../../global_widgets/responsive_layout.dart';

class VehicleMasterView extends GetView<VehicleMasterController> {
  const VehicleMasterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Master'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchVehicles,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        desktop: _buildDesktopLayout(),
      ),
      floatingActionButton: Obx(() {
        if (controller.canAddEditVehicles) {
          return FloatingActionButton(
            onPressed: () => _showVehicleForm(context),
            tooltip: 'Add Vehicle',
            child: const Icon(Icons.add),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: CustomSearchField(
            hint: 'Search by vehicle number or owner name',
            controller: TextEditingController(),
            onChanged: controller.searchVehicles,
            onClear: controller.clearSearch,
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final vehicles = controller.getPaginatedVehicles();
            if (vehicles.isEmpty) {
              return const Center(
                child: Text('No vehicles found'),
              );
            }

            return ListView.builder(
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = vehicles[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
                    title: Text(vehicle.vehicleNumber),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (vehicle.vehicleType != null)
                          Text('Type: ${vehicle.vehicleType}'),
                        if (vehicle.capacity != null)
                          Text('Capacity: ${vehicle.capacity} tons'),
                        if (vehicle.ownerName != null)
                          Text('Owner: ${vehicle.ownerName}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: controller.canAddEditVehicles
                              ? () {
                                  controller.setFormForEditing(vehicle);
                                  _showVehicleForm(Get.context!);
                                }
                              : null,
                          tooltip: 'Edit',
                        ),
                        IconButton(
                          icon: Icon(
                            vehicle.isActive ? Icons.toggle_on : Icons.toggle_off,
                            color: vehicle.isActive ? Colors.green : Colors.grey,
                          ),
                          onPressed: controller.canAddEditVehicles
                              ? () => controller.toggleVehicleActiveStatus(vehicle)
                              : null,
                          tooltip: vehicle.isActive ? 'Deactivate' : 'Activate',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: controller.canDeleteVehicles
                              ? () => _confirmDelete(Get.context!, vehicle)
                              : null,
                          tooltip: 'Delete',
                        ),
                      ],
                    ),
                    isThreeLine: true,
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

  Widget _buildDesktopLayout() {
    return Column(
      children: [
        MasterDataTableHeader(
          title: 'Vehicle Master',
          searchField: CustomSearchField(
            hint: 'Search by vehicle number or owner name',
            controller: TextEditingController(),
            onChanged: controller.searchVehicles,
            onClear: controller.clearSearch,
          ),
          actions: MasterDataTableActions(
            onAdd: controller.canAddEditVehicles
                ? () => _showVehicleForm(Get.context!)
                : null,
            onRefresh: controller.fetchVehicles,
            onExport: () {}, // TODO: Implement export functionality
            onPrint: () {}, // TODO: Implement print functionality
            onDelete: controller.canDeleteVehicles && controller.selectedVehicles.isNotEmpty
                ? () => _confirmDeleteSelected(Get.context!)
                : null,
            showDelete: controller.canDeleteVehicles,
            isDeleteEnabled: controller.selectedVehicles.isNotEmpty,
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final vehicles = controller.getPaginatedVehicles();
            
            return MasterDataTable<dynamic>(
              columns: [
                DataColumn2(
                  label: const Text('Vehicle Number'),
                  onSort: (columnIndex, ascending) => controller.changeSortColumn(columnIndex, ascending),
                  tooltip: 'Vehicle Number',
                ),
                DataColumn2(
                  label: const Text('Vehicle Type'),
                  onSort: (columnIndex, ascending) => controller.changeSortColumn(columnIndex, ascending),
                  tooltip: 'Vehicle Type',
                ),
                DataColumn2(
                  label: const Text('Capacity (tons)'),
                  numeric: true,
                  onSort: (columnIndex, ascending) => controller.changeSortColumn(columnIndex, ascending),
                  tooltip: 'Capacity in tons',
                ),
                DataColumn2(
                  label: const Text('Owner Name'),
                  onSort: (columnIndex, ascending) => controller.changeSortColumn(columnIndex, ascending),
                  tooltip: 'Owner Name',
                ),
                const DataColumn2(
                  label: Text('Owner Mobile'),
                  tooltip: 'Owner Mobile',
                ),
                const DataColumn2(
                  label: Text('Status'),
                  tooltip: 'Status',
                ),
                const DataColumn2(
                  label: Text('Actions'),
                  tooltip: 'Actions',
                  fixedWidth: 120,
                ),
              ],
              data: vehicles,
              dataRowBuilder: (vehicle, index) {
                return DataRow2(
                  cells: [
                    DataCell(Text(vehicle.vehicleNumber)),
                    DataCell(Text(vehicle.vehicleType ?? '-')),
                    DataCell(Text(vehicle.capacity?.toString() ?? '-')),
                    DataCell(Text(vehicle.ownerName ?? '-')),
                    DataCell(Text(vehicle.ownerMobile ?? '-')),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: vehicle.isActive ? Colors.green.withAlpha(51) : Colors.red.withAlpha(51),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          vehicle.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: vehicle.isActive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: controller.canAddEditVehicles
                                ? () {
                                    controller.setFormForEditing(vehicle);
                                    _showVehicleForm(Get.context!);
                                  }
                                : null,
                            tooltip: 'Edit',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              vehicle.isActive ? Icons.toggle_on : Icons.toggle_off,
                              color: vehicle.isActive ? Colors.green : Colors.grey,
                              size: 20,
                            ),
                            onPressed: controller.canAddEditVehicles
                                ? () => controller.toggleVehicleActiveStatus(vehicle)
                                : null,
                            tooltip: vehicle.isActive ? 'Deactivate' : 'Activate',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: controller.canDeleteVehicles
                                ? () => _confirmDelete(Get.context!, vehicle)
                                : null,
                            tooltip: 'Delete',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  ],
                  selected: controller.selectedVehicles.contains(vehicle),
                  onSelectChanged: controller.canDeleteVehicles
                      ? (selected) => controller.selectVehicle(vehicle, selected)
                      : null,
                );
              },
              isLoading: controller.isLoading.value,
              emptyMessage: 'No vehicles found',
              showCheckboxColumn: controller.canDeleteVehicles,
              sortAscending: controller.sortAscending.value,
              sortColumnIndex: _getSortColumnIndex(),
              onSort: controller.changeSortColumn,
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
    );
  }

  int? _getSortColumnIndex() {
    switch (controller.sortColumn.value) {
      case 'vehicle_number':
        return 0;
      case 'vehicle_type':
        return 1;
      case 'capacity':
        return 2;
      case 'owner_name':
        return 3;
      default:
        return 0;
    }
  }

  void _showVehicleForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(controller.isEditing.value ? 'Edit Vehicle' : 'Add Vehicle'),
        content: SingleChildScrollView(
          child: Form(
            key: controller.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomFormField(
                  label: 'Vehicle Number',
                  controller: controller.vehicleNumberController,
                  validator: controller.validateVehicleNumber,
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 16),
                CustomFormField(
                  label: 'Vehicle Type',
                  controller: controller.vehicleTypeController,
                  hint: 'e.g., Truck, Lorry, etc.',
                ),
                const SizedBox(height: 16),
                CustomNumberField(
                  label: 'Capacity (tons)',
                  controller: controller.capacityController,
                  hint: 'e.g., 10',
                  validator: controller.validateCapacity,
                  suffixText: 'tons',
                ),
                const SizedBox(height: 16),
                CustomFormField(
                  label: 'Owner Name',
                  controller: controller.ownerNameController,
                  hint: 'e.g., John Doe',
                ),
                const SizedBox(height: 16),
                CustomFormField(
                  label: 'Owner Mobile',
                  controller: controller.ownerMobileController,
                  hint: 'e.g., 9876543210',
                  keyboardType: TextInputType.phone,
                  validator: controller.validateOwnerMobile,
                ),
                const SizedBox(height: 16),
                CustomFormField(
                  label: 'Owner Address',
                  controller: controller.ownerAddressController,
                  hint: 'e.g., 123 Main St, City',
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
          ElevatedButton(
            onPressed: () async {
              final nav = Navigator.of(context);
              final bool success = await controller.saveVehicle();
              if (success) {
                nav.pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, dynamic vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete vehicle ${vehicle.vehicleNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final BuildContext currentContext = context;
              Navigator.of(currentContext).pop();
              await controller.deleteVehicle(vehicle);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSelected(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${controller.selectedVehicles.length} selected vehicles?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final BuildContext currentContext = context;
              Navigator.of(currentContext).pop();
              await controller.deleteSelectedVehicles();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

}

