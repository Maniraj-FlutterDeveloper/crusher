import 'package:get/get.dart';
import '../../../core/error/error_handler.dart';
import '../../../core/services/logger_service.dart';
import '../../../data/models/material_model.dart';
import '../../../data/repositories/material_repository.dart';
import '../../../global_widgets/error_display.dart';

class MaterialMasterController extends GetxController {
  final MaterialRepository _repository = Get.find<MaterialRepository>();
  final LoggerService _logger = Get.find<LoggerService>();
  final ErrorHandler _errorHandler = Get.find<ErrorHandler>();
  
  final RxBool isLoading = false.obs;
  final RxList<MaterialModel> materials = <MaterialModel>[].obs;
  final RxList<MaterialModel> filteredMaterials = <MaterialModel>[].obs;
  
  final RxString searchQuery = ''.obs;
  final RxString filterType = 'All'.obs;
  final RxInt sortColumnIndex = 0.obs;
  final RxBool sortAscending = true.obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchMaterials();
  }
  
  Future<void> fetchMaterials() async {
    try {
      isLoading.value = true;
      final result = await _repository.getAllMaterials();
      materials.value = result;
      filterMaterials(searchQuery.value);
      _logger.info('Fetched ${materials.length} materials');
    } catch (e, stackTrace) {
      final error = await _errorHandler.handleError(e, stackTrace);
      ErrorSnackbar.show(error);
      _logger.error('Failed to fetch materials', e);
    } finally {
      isLoading.value = false;
    }
  }
  
  void refreshMaterials() {
    fetchMaterials();
  }
  
  void filterMaterials(String query) {
    searchQuery.value = query;
    
    if (query.isEmpty && filterType.value == 'All') {
      filteredMaterials.value = materials;
    } else {
      filteredMaterials.value = materials.where((material) {
        final matchesQuery = query.isEmpty || 
            material.name.toLowerCase().contains(query.toLowerCase()) ||
            material.description.toLowerCase().contains(query.toLowerCase());
        
        final matchesType = filterType.value == 'All' || 
            material.type == filterType.value;
        
        return matchesQuery && matchesType;
      }).toList();
    }
    
    sortMaterials(sortColumnIndex.value, sortAscending.value);
  }
  
  void sortMaterials(int columnIndex, bool ascending) {
    sortColumnIndex.value = columnIndex;
    sortAscending.value = ascending;
    
    filteredMaterials.sort((a, b) {
      var result = 0;
      
      switch (columnIndex) {
        case 0: // Name
          result = a.name.compareTo(b.name);
          break;
        case 1: // Type
          result = a.type.compareTo(b.type);
          break;
        case 2: // Size
          final aSize = a.size ?? '';
          final bSize = b.size ?? '';
          result = aSize.compareTo(bSize);
          break;
        case 3: // Unit Price
          result = a.unitPrice.compareTo(b.unitPrice);
          break;
        case 4: // GST %
          result = a.gstPercentage.compareTo(b.gstPercentage);
          break;
        case 5: // Status
          result = a.isActive == b.isActive ? 0 : (a.isActive ? 1 : -1);
          break;
        default:
          result = 0;
      }
      
      return ascending ? result : -result;
    });
  }
  
  Future<void> addMaterial(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      final material = MaterialModel.fromJson(data);
      await _repository.createMaterial(material);
      await fetchMaterials();
      Get.snackbar(
        'Success',
        'Material added successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      _logger.info('Added new material: ${material.name}');
    } catch (e, stackTrace) {
      final error = await _errorHandler.handleError(e, stackTrace);
      ErrorSnackbar.show(error);
      _logger.error('Failed to add material', e);
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> updateMaterial(int id, Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      final material = MaterialModel.fromJson({...data, 'id': id});
      await _repository.updateMaterial(material);
      await fetchMaterials();
      Get.snackbar(
        'Success',
        'Material updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      _logger.info('Updated material: ${material.name}');
    } catch (e, stackTrace) {
      final error = await _errorHandler.handleError(e, stackTrace);
      ErrorSnackbar.show(error);
      _logger.error('Failed to update material', e);
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> deleteMaterial(int id) async {
    try {
      isLoading.value = true;
      await _repository.deleteMaterial(id);
      await fetchMaterials();
      Get.snackbar(
        'Success',
        'Material deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      _logger.info('Deleted material with ID: $id');
    } catch (e, stackTrace) {
      final error = await _errorHandler.handleError(e, stackTrace);
      ErrorSnackbar.show(error);
      _logger.error('Failed to delete material', e);
    } finally {
      isLoading.value = false;
    }
  }
}

