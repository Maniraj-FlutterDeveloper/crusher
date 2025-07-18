import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import '../controllers/material_loading_controller.dart';
import '../../../global_widgets/custom_form_field.dart';
import '../../../global_widgets/master_data_table.dart';
import '../../../global_widgets/responsive_layout.dart';
import '../../../core/values/app_colors.dart';
import '../../../core/values/app_constants.dart';
import '../../../data/models/gate_entry_model.dart';
import '../../../data/models/material_loading_model.dart';
import '../../../data/models/material_model.dart';

class MaterialLoadingView extends GetView<MaterialLoadingController> {
  const MaterialLoadingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Material Loading'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchMaterialLoadingRecords,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(context),
        desktop: _buildDesktopLayout(context),
      ),
      floatingActionButton: Obx(() {
        if (controller.canAddMaterialLoadingRecords) {
          return FloatingActionButton(
            onPressed: () => _showGateEntrySearchDialog(context),
            child: const Icon(Icons.add),
            tooltip: 'Add Material Loading',
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
            hint: 'Search by session ID, vehicle number, or material',
            controller: TextEditingController(),
            onChanged: controller.searchMaterialLoadingRecords,
            onClear: controller.clearSearch,
          ),
        ),
        _buildStatusFilter(),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final materialLoadingRecords = controller.getPaginatedMaterialLoadingRecords();
            if (materialLoadingRecords.isEmpty) {
              return const Center(
                child: Text('No material loading records found'),
              );
            }

            return ListView.builder(
              itemCount: materialLoadingRecords.length,
              itemBuilder: (context, index) {
                final record = materialLoadingRecords[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ExpansionTile(
                    title: Text('Session ID: ${record.gateEntry?.sessionId ?? "N/A"}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vehicle: ${record.gateEntry?.vehicle?.vehicleNumber ?? "N/A"}'),
                        Text('Material: ${record.material?.name ?? "N/A"}'),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Driver: ${record.gateEntry?.driverName ?? "N/A"}'),
                            Text('Material Size: ${record.materialSize?.name ?? "N/A"}'),
                            Text('Quantity: ${record.quantity} ${record.weightUnit?.symbol ?? "kg"}'),
                            Text('Purpose: ${record.purpose}'),
                            Text('Status: ${record.status}'),
                            Text('Created At: ${DateFormat(AppConstants.dateTimeFormat).format(record.createdAt)}'),
                            Text('Remarks: ${record.remarks ?? "N/A"}'),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                if (controller.canEditMaterialLoadingRecords && record.status != AppConstants.statusCancelled)
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Edit'),
                                    onPressed: () {
                                      if (record.gateEntry != null) {
                                        controller.setGateEntryForMaterialLoading(record.gateEntry!);
                                        _showMaterialLoadingForm(context);
                                      }
                                    },
                                  ),
                                if (controller.canEditMaterialLoadingRecords && record.status != AppConstants.statusCancelled)
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.cancel),
                                    label: const Text('Cancel'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    onPressed: () {
                                      _showCancelConfirmationDialog(context, record);
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
                title: 'Material Loading Records',
                searchField: CustomSearchField(
                  hint: 'Search by session ID, vehicle number, or material',
                  controller: TextEditingController(),
                  onChanged: controller.searchMaterialLoadingRecords,
                  onClear: controller.clearSearch,
                ),
                actions: Row(
                  children: [
                    MasterDataTableActions(
                      onAdd: controller.canAddMaterialLoadingRecords
                          ? () => _showGateEntrySearchDialog(context)
                          : null,
                      onRefresh: controller.fetchMaterialLoadingRecords,
                      onExport: () {}, // TODO: Implement export functionality
                      showDelete: false,
                    ),
                  ],
                ),
              ),
              _buildStatusFilter(),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final materialLoadingRecords = controller.getPaginatedMaterialLoadingRecords();
                  
                  return MasterDataTable<MaterialLoadingModel>(
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
                        label: const Text('Material'),
                        onSort: (_, __) => controller.changeSortColumn('material_name'),
                        tooltip: 'Material',
                      ),
                      DataColumn2(
                        label: const Text('Size'),
                        tooltip: 'Material Size',
                      ),
                      DataColumn2(
                        label: const Text('Quantity'),
                        numeric: true,
                        onSort: (_, __) => controller.changeSortColumn('quantity'),
                        tooltip: 'Quantity',
                      ),
                      DataColumn2(
                        label: const Text('Purpose'),
                        tooltip: 'Purpose',
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
                    data: materialLoadingRecords,
                    dataRowBuilder: (record, index) {
                      return DataRow2(
                        cells: [
                          DataCell(Text(record.gateEntry?.sessionId ?? 'N/A')),
                          DataCell(Text(record.gateEntry?.vehicle?.vehicleNumber ?? 'N/A')),
                          DataCell(Text(record.material?.name ?? 'N/A')),
                          DataCell(Text(record.materialSize?.name ?? 'N/A')),
                          DataCell(Text('${record.quantity} ${record.weightUnit?.symbol ?? 'kg'}')),
                          DataCell(Text(record.purpose)),
                          DataCell(_buildStatusCell(record.status)),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (controller.canEditMaterialLoadingRecords && record.status != AppConstants.statusCancelled)
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () {
                                      if (record.gateEntry != null) {
                                        controller.setGateEntryForMaterialLoading(record.gateEntry!);
                                        _showMaterialLoadingForm(context);
                                      }
                                    },
                                    tooltip: 'Edit',
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                const SizedBox(width: 8),
                                if (controller.canEditMaterialLoadingRecords && record.status != AppConstants.statusCancelled)
                                  IconButton(
                                    icon: const Icon(Icons.cancel, size: 20, color: Colors.red),
                                    onPressed: () {
                                      _showCancelConfirmationDialog(context, record);
                                    },
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
                    emptyMessage: 'No material loading records found',
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Text('Filter by Status:'),
            const SizedBox(width: 8),
            Obx(() => ChoiceChip(
              label: const Text('All'),
              selected: controller.statusFilter.value.isEmpty,
              onSelected: (selected) {
                if (selected) {
                  controller.clearStatusFilter();
                }
              },
            )),
            const SizedBox(width: 8),
            Obx(() => ChoiceChip(
              label: const Text('Pending'),
              selected: controller.statusFilter.value == AppConstants.statusPending,
              onSelected: (selected) {
                if (selected) {
                  controller.filterByStatus(AppConstants.statusPending);
                } else {
                  controller.clearStatusFilter();
                }
              },
            )),
            const SizedBox(width: 8),
            Obx(() => ChoiceChip(
              label: const Text('Loading'),
              selected: controller.statusFilter.value == AppConstants.statusLoading,
              onSelected: (selected) {
                if (selected) {
                  controller.filterByStatus(AppConstants.statusLoading);
                } else {
                  controller.clearStatusFilter();
                }
              },
            )),
            const SizedBox(width: 8),
            Obx(() => ChoiceChip(
              label: const Text('Loaded'),
              selected: controller.statusFilter.value == AppConstants.statusLoaded,
              onSelected: (selected) {
                if (selected) {
                  controller.filterByStatus(AppConstants.statusLoaded);
                } else {
                  controller.clearStatusFilter();
                }
              },
            )),
            const SizedBox(width: 8),
            Obx(() => ChoiceChip(
              label: const Text('Cancelled'),
              selected: controller.statusFilter.value == AppConstants.statusCancelled,
              onSelected: (selected) {
                if (selected) {
                  controller.filterByStatus(AppConstants.statusCancelled);
                } else {
                  controller.clearStatusFilter();
                }
              },
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCell(String status) {
    Color color;
    IconData icon;
    
    switch (status) {
      case AppConstants.statusPending:
        color = Colors.orange;
        icon = Icons.pending;
        break;
      case AppConstants.statusLoading:
        color = Colors.blue;
        icon = Icons.hourglass_top;
        break;
      case AppConstants.statusLoaded:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case AppConstants.statusCancelled:
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          status,
          style: TextStyle(color: color),
        ),
      ],
    );
  }

  int? _getSortColumnIndex() {
    switch (controller.sortColumn.value) {
      case 'session_id':
        return 0;
      case 'vehicle_number':
        return 1;
      case 'material_name':
        return 2;
      case 'quantity':
        return 4;
      case 'status':
        return 6;
      default:
        return 0;
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
                        controller.setGateEntryForMaterialLoading(gateEntry);
                        Navigator.of(context).pop();
                        
                        // Show material loading form
                        _showMaterialLoadingForm(context);
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

  void _showMaterialLoadingForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Material Loading'),
        content: SingleChildScrollView(
          child: Form(
            key: controller.materialLoadingFormKey,
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
                            'Status: ${controller.selectedGateEntry.value!.status}',
                          ),
                        ],
                      )
                    : const Text('No gate entry selected')),
                const SizedBox(height: 16),
                Obx(() => DropdownButtonFormField<MaterialModel>(
                  value: controller.selectedMaterial.value,
                  items: controller.materials.map((MaterialModel material) {
                    return DropdownMenuItem<MaterialModel>(
                      value: material,
                      child: Text(material.name),
                    );
                  }).toList(),
                  onChanged: (MaterialModel? value) {
                    if (value != null) {
                      controller.selectedMaterial.value = value;
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Material',
                    border: OutlineInputBorder(),
                  ),
                )),
                const SizedBox(height: 16),
                Obx(() => DropdownButtonFormField<MaterialSizeModel>(
                  value: controller.selectedMaterialSize.value,
                  items: controller.materialSizes.map((MaterialSizeModel size) {
                    return DropdownMenuItem<MaterialSizeModel>(
                      value: size,
                      child: Text(size.name),
                    );
                  }).toList(),
                  onChanged: (MaterialSizeModel? value) {
                    if (value != null) {
                      controller.selectedMaterialSize.value = value;
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Material Size',
                    border: OutlineInputBorder(),
                  ),
                )),
                const SizedBox(height: 16),
                CustomNumberField(
                  label: 'Quantity',
                  controller: controller.quantityController,
                  hint: 'e.g., 1000',
                  validator: controller.validateQuantity,
                  suffixText: Obx(() => controller.selectedWeightUnit.value?.symbol ?? 'kg'),
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
                Obx(() => Row(
                  children: [
                    const Text('Purpose:'),
                    const SizedBox(width: 16),
                    Radio<String>(
                      value: AppConstants.purposeSale,
                      groupValue: controller.selectedPurpose.value,
                      onChanged: (value) {
                        if (value != null) {
                          controller.selectedPurpose.value = value;
                        }
                      },
                    ),
                    const Text('Sale'),
                    const SizedBox(width: 16),
                    Radio<String>(
                      value: AppConstants.purposeInternal,
                      groupValue: controller.selectedPurpose.value,
                      onChanged: (value) {
                        if (value != null) {
                          controller.selectedPurpose.value = value;
                        }
                      },
                    ),
                    const Text('Internal'),
                  ],
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
                    if (await controller.saveMaterialLoading()) {
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

  void _showCancelConfirmationDialog(BuildContext context, MaterialLoadingModel record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Material Loading'),
        content: const Text('Are you sure you want to cancel this material loading record? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await controller.updateMaterialLoadingStatus(record.id!, AppConstants.statusCancelled);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}

