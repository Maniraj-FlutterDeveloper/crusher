import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/material_master_controller.dart';
import '../../../core/utils/responsive_builder.dart';
import '../../../core/values/app_colors.dart';
import '../../../global_widgets/custom_app_bar.dart';
import '../../../global_widgets/custom_drawer.dart';
import '../../../global_widgets/master_data_table.dart';
import '../../../global_widgets/responsive_layout.dart';

class MaterialMasterView extends GetView<MaterialMasterController> {
  const MaterialMasterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize controller if not already initialized
    if (!Get.isRegistered<MaterialMasterController>()) {
      Get.put(MaterialMasterController());
    }
    
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Material Master',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showMaterialForm(context),
            tooltip: 'Add New Material',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshMaterials,
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: ResponsiveBuilder(
        builder: (context, deviceType, size) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 16),
                _buildSearchAndFilter(context),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildMaterialsTable(context),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMaterialForm(context),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Material Master',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Manage all materials used in the crusher operations',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textLightColor,
              ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: controller.filterMaterials,
            decoration: InputDecoration(
              hintText: 'Search materials...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        DropdownButton<String>(
          value: controller.filterType.value,
          onChanged: (value) {
            if (value != null) {
              controller.filterType.value = value;
              controller.filterMaterials(controller.searchQuery.value);
            }
          },
          items: const [
            DropdownMenuItem(
              value: 'All',
              child: Text('All Types'),
            ),
            DropdownMenuItem(
              value: 'Raw',
              child: Text('Raw Materials'),
            ),
            DropdownMenuItem(
              value: 'Crushed',
              child: Text('Crushed Materials'),
            ),
            DropdownMenuItem(
              value: 'Waste',
              child: Text('Waste Materials'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMaterialsTable(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      
      if (controller.materials.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No materials found',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _showMaterialForm(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Material'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        );
      }
      
      return MasterDataTable(
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Type')),
          DataColumn(label: Text('Size')),
          DataColumn(label: Text('Unit Price')),
          DataColumn(label: Text('GST %')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: controller.filteredMaterials.map((material) {
          return DataRow(
            cells: [
              DataCell(Text(material.name)),
              DataCell(Text(material.type)),
              DataCell(Text(material.size ?? 'N/A')),
              DataCell(Text('₹${material.unitPrice.toStringAsFixed(2)}')),
              DataCell(Text('${material.gstPercentage}%')),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: material.isActive
                        ? AppColors.successColor.withOpacity(0.2)
                        : AppColors.errorColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    material.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: material.isActive
                          ? AppColors.successColor
                          : AppColors.errorColor,
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
                      onPressed: () => _showMaterialForm(context, material),
                      tooltip: 'Edit',
                      color: AppColors.primaryColor,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () => _confirmDelete(context, material),
                      tooltip: 'Delete',
                      color: AppColors.errorColor,
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
        onSort: (columnIndex, ascending) {
          controller.sortMaterials(columnIndex, ascending);
        },
      );
    });
  }

  void _showMaterialForm(BuildContext context, [dynamic material]) {
    final isEditing = material != null;
    
    final nameController = TextEditingController(
      text: isEditing ? material.name : '',
    );
    final descriptionController = TextEditingController(
      text: isEditing ? material.description : '',
    );
    final unitPriceController = TextEditingController(
      text: isEditing ? material.unitPrice.toString() : '',
    );
    final gstPercentageController = TextEditingController(
      text: isEditing ? material.gstPercentage.toString() : '',
    );
    
    final typeController = isEditing ? material.type.obs : 'Raw'.obs;
    final sizeController = isEditing ? (material.size ?? '').obs : ''.obs;
    final isActiveController = isEditing ? material.isActive.obs : true.obs;
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Edit Material' : 'Add New Material',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Material Name',
                  hintText: 'Enter material name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter material description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Obx(() => DropdownButtonFormField<String>(
                      value: typeController.value,
                      decoration: const InputDecoration(
                        labelText: 'Material Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Raw',
                          child: Text('Raw Material'),
                        ),
                        DropdownMenuItem(
                          value: 'Crushed',
                          child: Text('Crushed Material'),
                        ),
                        DropdownMenuItem(
                          value: 'Waste',
                          child: Text('Waste Material'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          typeController.value = value;
                        }
                      },
                    )),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(() => DropdownButtonFormField<String>(
                      value: sizeController.value.isEmpty
                          ? null
                          : sizeController.value,
                      decoration: const InputDecoration(
                        labelText: 'Size (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: '6mm',
                          child: Text('6mm'),
                        ),
                        DropdownMenuItem(
                          value: '12mm',
                          child: Text('12mm'),
                        ),
                        DropdownMenuItem(
                          value: '20mm',
                          child: Text('20mm'),
                        ),
                        DropdownMenuItem(
                          value: '40mm',
                          child: Text('40mm'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          sizeController.value = value;
                        }
                      },
                    )),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: unitPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Unit Price (₹)',
                        hintText: 'Enter unit price',
                        border: OutlineInputBorder(),
                        prefixText: '₹ ',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: gstPercentageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'GST Percentage',
                        hintText: 'Enter GST %',
                        border: OutlineInputBorder(),
                        suffixText: '%',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Obx(() => SwitchListTile(
                title: const Text('Status'),
                subtitle: Text(
                  isActiveController.value ? 'Active' : 'Inactive',
                ),
                value: isActiveController.value,
                onChanged: (value) {
                  isActiveController.value = value;
                },
                activeColor: AppColors.primaryColor,
              )),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      final materialData = {
                        'name': nameController.text,
                        'description': descriptionController.text,
                        'type': typeController.value,
                        'size': sizeController.value,
                        'unitPrice': double.tryParse(unitPriceController.text) ?? 0.0,
                        'gstPercentage': int.tryParse(gstPercentageController.text) ?? 0,
                        'isActive': isActiveController.value,
                      };
                      
                      if (isEditing) {
                        controller.updateMaterial(material.id, materialData);
                      } else {
                        controller.addMaterial(materialData);
                      }
                      
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: AppColors.primaryColor,
                    ),
                    child: Text(isEditing ? 'Update' : 'Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, dynamic material) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          'Are you sure you want to delete the material "${material.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteMaterial(material.id);
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppColors.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

