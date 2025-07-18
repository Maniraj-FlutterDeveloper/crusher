import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/values/app_constants.dart';
import '../../../data/models/gate_entry_model.dart';
import '../../../data/models/material_loading_model.dart';
import '../../../data/models/material_model.dart';
import '../../../data/models/weighbridge_record_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/material_loading_repository.dart';
import '../../../data/repositories/gate_entry_repository.dart';
import '../../../data/repositories/weighbridge_repository.dart';
import '../../../data/services/auth_service.dart';

class MaterialLoadingController extends GetxController {
  final MaterialLoadingRepository _materialLoadingRepository = Get.find<MaterialLoadingRepository>();
  final GateEntryRepository _gateEntryRepository = Get.find<GateEntryRepository>();
  final WeighbridgeRepository _weighbridgeRepository = Get.find<WeighbridgeRepository>();
  final AuthService _authService = Get.find<AuthService>();
  
  // Observables
  final RxBool isLoading = false.obs;
  final RxBool isProcessing = false.obs;
  final RxList<MaterialLoadingModel> materialLoadingRecords = <MaterialLoadingModel>[].obs;
  final RxList<MaterialLoadingModel> filteredMaterialLoadingRecords = <MaterialLoadingModel>[].obs;
  final RxList<MaterialModel> materials = <MaterialModel>[].obs;
  final RxList<MaterialSizeModel> materialSizes = <MaterialSizeModel>[].obs;
  final RxList<MaterialTypeModel> materialTypes = <MaterialTypeModel>[].obs;
  final RxList<WeightUnitModel> weightUnits = <WeightUnitModel>[].obs;
  final Rx<MaterialLoadingModel?> currentMaterialLoading = Rx<MaterialLoadingModel?>(null);
  final Rx<GateEntryModel?> selectedGateEntry = Rx<GateEntryModel?>(null);
  final Rx<MaterialModel?> selectedMaterial = Rx<MaterialModel?>(null);
  final Rx<MaterialSizeModel?> selectedMaterialSize = Rx<MaterialSizeModel?>(null);
  final Rx<WeightUnitModel?> selectedWeightUnit = Rx<WeightUnitModel?>(null);
  final RxString selectedPurpose = AppConstants.purposeSale.obs;
  
  // Pagination
  final RxInt currentPage = 0.obs;
  final RxInt totalPages = 0.obs;
  final RxInt rowsPerPage = 10.obs;
  
  // Sorting
  final RxString sortColumn = 'created_at'.obs;
  final RxBool sortAscending = false.obs;
  
  // Filtering
  final RxString searchQuery = ''.obs;
  final RxString statusFilter = ''.obs;
  
  // Form keys
  final GlobalKey<FormState> materialLoadingFormKey = GlobalKey<FormState>();
  
  // Form controllers
  final TextEditingController sessionIdController = TextEditingController();
  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController driverNameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  
  @override
  void onInit() {
    super.onInit();
    fetchMaterialLoadingRecords();
    fetchMaterials();
    fetchMaterialSizes();
    fetchMaterialTypes();
    fetchWeightUnits();
  }
  
  @override
  void onClose() {
    sessionIdController.dispose();
    vehicleNumberController.dispose();
    driverNameController.dispose();
    quantityController.dispose();
    remarksController.dispose();
    super.onClose();
  }
  
  // Fetch all material loading records
  Future<void> fetchMaterialLoadingRecords() async {
    isLoading.value = true;
    try {
      final records = await _materialLoadingRepository.getAllMaterialLoadingRecords();
      materialLoadingRecords.assignAll(records);
      applyFilters();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch material loading records: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Fetch all materials
  Future<void> fetchMaterials() async {
    try {
      final materialsList = await _materialLoadingRepository.getActiveMaterials();
      materials.assignAll(materialsList);
      
      if (materials.isNotEmpty) {
        selectedMaterial.value = materials.first;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch materials: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  // Fetch all material sizes
  Future<void> fetchMaterialSizes() async {
    try {
      final sizesList = await _materialLoadingRepository.getActiveMaterialSizes();
      materialSizes.assignAll(sizesList);
      
      if (materialSizes.isNotEmpty) {
        selectedMaterialSize.value = materialSizes.first;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch material sizes: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  // Fetch all material types
  Future<void> fetchMaterialTypes() async {
    try {
      final typesList = await _materialLoadingRepository.getActiveMaterialTypes();
      materialTypes.assignAll(typesList);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch material types: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  // Fetch all weight units
  Future<void> fetchWeightUnits() async {
    try {
      final units = await _weighbridgeRepository.getActiveWeightUnits();
      weightUnits.assignAll(units);
      
      if (weightUnits.isNotEmpty) {
        // Set default weight unit to kg
        selectedWeightUnit.value = weightUnits.firstWhere(
          (unit) => unit.symbol.toLowerCase() == 'kg',
          orElse: () => weightUnits.first,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch weight units: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  // Apply filters and sorting
  void applyFilters() {
    List<MaterialLoadingModel> filtered = List.from(materialLoadingRecords);
    
    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((record) {
        final sessionId = record.gateEntry?.sessionId.toLowerCase() ?? '';
        final vehicleNumber = record.gateEntry?.vehicle?.vehicleNumber.toLowerCase() ?? '';
        final driverName = record.gateEntry?.driverName?.toLowerCase() ?? '';
        final materialName = record.material?.name.toLowerCase() ?? '';
        
        return sessionId.contains(searchQuery.value.toLowerCase()) ||
               vehicleNumber.contains(searchQuery.value.toLowerCase()) ||
               driverName.contains(searchQuery.value.toLowerCase()) ||
               materialName.contains(searchQuery.value.toLowerCase());
      }).toList();
    }
    
    // Apply status filter
    if (statusFilter.value.isNotEmpty) {
      filtered = filtered.where((record) => record.status == statusFilter.value).toList();
    }
    
    // Apply sorting
    filtered.sort((a, b) {
      int result = 0;
      
      switch (sortColumn.value) {
        case 'session_id':
          result = (a.gateEntry?.sessionId ?? '').compareTo(b.gateEntry?.sessionId ?? '');
          break;
        case 'vehicle_number':
          result = (a.gateEntry?.vehicle?.vehicleNumber ?? '').compareTo(b.gateEntry?.vehicle?.vehicleNumber ?? '');
          break;
        case 'material_name':
          result = (a.material?.name ?? '').compareTo(b.material?.name ?? '');
          break;
        case 'quantity':
          result = a.quantity.compareTo(b.quantity);
          break;
        case 'status':
          result = a.status.compareTo(b.status);
          break;
        case 'created_at':
        default:
          result = a.createdAt.compareTo(b.createdAt);
          break;
      }
      
      return sortAscending.value ? result : -result;
    });
    
    filteredMaterialLoadingRecords.assignAll(filtered);
    
    // Update pagination
    updatePagination();
  }
  
  // Update pagination
  void updatePagination() {
    final totalItems = filteredMaterialLoadingRecords.length;
    totalPages.value = (totalItems / rowsPerPage.value).ceil();
    
    if (currentPage.value >= totalPages.value && totalPages.value > 0) {
      currentPage.value = totalPages.value - 1;
    }
  }
  
  // Get paginated material loading records
  List<MaterialLoadingModel> getPaginatedMaterialLoadingRecords() {
    if (filteredMaterialLoadingRecords.isEmpty) return [];
    
    final startIndex = currentPage.value * rowsPerPage.value;
    final endIndex = (startIndex + rowsPerPage.value) > filteredMaterialLoadingRecords.length
        ? filteredMaterialLoadingRecords.length
        : startIndex + rowsPerPage.value;
    
    if (startIndex >= filteredMaterialLoadingRecords.length) return [];
    
    return filteredMaterialLoadingRecords.sublist(startIndex, endIndex);
  }
  
  // Change page
  void changePage(int page) {
    currentPage.value = page;
  }
  
  // Change rows per page
  void changeRowsPerPage(int? value) {
    if (value != null) {
      rowsPerPage.value = value;
      updatePagination();
    }
  }
  
  // Change sort column
  void changeSortColumn(String column) {
    if (sortColumn.value == column) {
      sortAscending.value = !sortAscending.value;
    } else {
      sortColumn.value = column;
      sortAscending.value = true;
    }
    
    applyFilters();
  }
  
  // Search material loading records
  void searchMaterialLoadingRecords(String query) {
    searchQuery.value = query;
    currentPage.value = 0;
    applyFilters();
  }
  
  // Clear search
  void clearSearch() {
    searchQuery.value = '';
    currentPage.value = 0;
    applyFilters();
  }
  
  // Filter by status
  void filterByStatus(String status) {
    statusFilter.value = status;
    currentPage.value = 0;
    applyFilters();
  }
  
  // Clear status filter
  void clearStatusFilter() {
    statusFilter.value = '';
    currentPage.value = 0;
    applyFilters();
  }
  
  // Set gate entry for material loading
  void setGateEntryForMaterialLoading(GateEntryModel gateEntry) {
    selectedGateEntry.value = gateEntry;
    
    // Populate form fields
    sessionIdController.text = gateEntry.sessionId;
    vehicleNumberController.text = gateEntry.vehicle?.vehicleNumber ?? '';
    driverNameController.text = gateEntry.driverName ?? '';
    
    // Check if material loading record already exists for this gate entry
    _materialLoadingRepository.getMaterialLoadingRecordsByGateEntry(gateEntry.id!).then((records) {
      if (records.isNotEmpty) {
        currentMaterialLoading.value = records.first;
        
        // Populate form fields with existing data
        selectedMaterial.value = materials.firstWhere(
          (material) => material.id == currentMaterialLoading.value!.materialId,
          orElse: () => materials.first,
        );
        
        if (currentMaterialLoading.value!.materialSizeId != null) {
          selectedMaterialSize.value = materialSizes.firstWhere(
            (size) => size.id == currentMaterialLoading.value!.materialSizeId,
            orElse: () => materialSizes.first,
          );
        }
        
        selectedWeightUnit.value = weightUnits.firstWhere(
          (unit) => unit.id == currentMaterialLoading.value!.weightUnitId,
          orElse: () => selectedWeightUnit.value!,
        );
        
        quantityController.text = currentMaterialLoading.value!.quantity.toString();
        selectedPurpose.value = currentMaterialLoading.value!.purpose;
        remarksController.text = currentMaterialLoading.value!.remarks ?? '';
      } else {
        currentMaterialLoading.value = null;
        
        // Clear form fields
        quantityController.clear();
        remarksController.clear();
        selectedPurpose.value = AppConstants.purposeSale;
      }
    });
  }
  
  // Save material loading
  Future<bool> saveMaterialLoading() async {
    if (!materialLoadingFormKey.currentState!.validate()) {
      return false;
    }
    
    isProcessing.value = true;
    
    try {
      final UserModel? currentUser = await _authService.getCurrentUser();
      
      if (currentUser == null) {
        Get.snackbar(
          'Error',
          'User not authenticated',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
      
      if (selectedGateEntry.value == null) {
        Get.snackbar(
          'Error',
          'No gate entry selected',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
      
      if (selectedMaterial.value == null) {
        Get.snackbar(
          'Error',
          'No material selected',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
      
      if (selectedWeightUnit.value == null) {
        Get.snackbar(
          'Error',
          'No weight unit selected',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
      
      final quantity = double.parse(quantityController.text);
      
      // Check if material loading record already exists
      if (currentMaterialLoading.value != null) {
        // Update existing record
        final updatedRecord = currentMaterialLoading.value!.copyWith(
          materialId: selectedMaterial.value!.id!,
          materialSizeId: selectedMaterialSize.value?.id,
          quantity: quantity,
          weightUnitId: selectedWeightUnit.value!.id!,
          purpose: selectedPurpose.value,
          remarks: remarksController.text,
          status: AppConstants.statusLoaded,
          updatedAt: DateTime.now(),
        );
        
        await _materialLoadingRepository.updateMaterialLoadingRecord(updatedRecord);
        
        // Update gate entry status
        final updatedGateEntry = selectedGateEntry.value!.copyWith(
          status: AppConstants.vehicleStatusLoaded,
          updatedAt: DateTime.now(),
        );
        
        await _gateEntryRepository.updateGateEntry(updatedGateEntry);
        
        Get.snackbar(
          'Success',
          'Material loading updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        // Create new record
        final newRecord = MaterialLoadingModel(
          gateEntryId: selectedGateEntry.value!.id!,
          materialId: selectedMaterial.value!.id!,
          materialSizeId: selectedMaterialSize.value?.id,
          quantity: quantity,
          weightUnitId: selectedWeightUnit.value!.id!,
          purpose: selectedPurpose.value,
          operatorId: currentUser.id!,
          remarks: remarksController.text,
          status: AppConstants.statusLoaded,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await _materialLoadingRepository.insertMaterialLoadingRecord(newRecord);
        
        // Update gate entry status
        final updatedGateEntry = selectedGateEntry.value!.copyWith(
          status: AppConstants.vehicleStatusLoaded,
          updatedAt: DateTime.now(),
        );
        
        await _gateEntryRepository.updateGateEntry(updatedGateEntry);
        
        Get.snackbar(
          'Success',
          'Material loading saved successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
      
      // Refresh data
      await fetchMaterialLoadingRecords();
      
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save material loading: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isProcessing.value = false;
    }
  }
  
  // Update material loading status
  Future<bool> updateMaterialLoadingStatus(int id, String status) async {
    isProcessing.value = true;
    
    try {
      await _materialLoadingRepository.updateMaterialLoadingStatus(id, status);
      
      // If status is cancelled, update gate entry status
      if (status == AppConstants.statusCancelled) {
        final materialLoading = await _materialLoadingRepository.getMaterialLoadingRecordById(id);
        
        if (materialLoading != null) {
          final gateEntry = await _gateEntryRepository.getGateEntryById(materialLoading.gateEntryId);
          
          if (gateEntry != null) {
            final updatedGateEntry = gateEntry.copyWith(
              status: AppConstants.vehicleStatusInProcess,
              updatedAt: DateTime.now(),
            );
            
            await _gateEntryRepository.updateGateEntry(updatedGateEntry);
          }
        }
      }
      
      Get.snackbar(
        'Success',
        'Material loading status updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      // Refresh data
      await fetchMaterialLoadingRecords();
      
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update material loading status: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isProcessing.value = false;
    }
  }
  
  // Clear form
  void clearForm() {
    selectedGateEntry.value = null;
    currentMaterialLoading.value = null;
    
    sessionIdController.clear();
    vehicleNumberController.clear();
    driverNameController.clear();
    quantityController.clear();
    remarksController.clear();
    
    if (materials.isNotEmpty) {
      selectedMaterial.value = materials.first;
    }
    
    if (materialSizes.isNotEmpty) {
      selectedMaterialSize.value = materialSizes.first;
    }
    
    if (weightUnits.isNotEmpty) {
      selectedWeightUnit.value = weightUnits.firstWhere(
        (unit) => unit.symbol.toLowerCase() == 'kg',
        orElse: () => weightUnits.first,
      );
    }
    
    selectedPurpose.value = AppConstants.purposeSale;
  }
  
  // Search gate entries
  Future<List<GateEntryModel>> searchGateEntries(String query) async {
    try {
      return await _gateEntryRepository.searchGateEntries(query);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to search gate entries: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return [];
    }
  }
  
  // Validate quantity
  String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Quantity is required';
    }
    
    try {
      final quantity = double.parse(value);
      
      if (quantity <= 0) {
        return 'Quantity must be greater than 0';
      }
    } catch (e) {
      return 'Invalid quantity';
    }
    
    return null;
  }
  
  // Check if user can add material loading records
  bool get canAddMaterialLoadingRecords {
    return _authService.hasPermission('material_loading.add');
  }
  
  // Check if user can edit material loading records
  bool get canEditMaterialLoadingRecords {
    return _authService.hasPermission('material_loading.edit');
  }
  
  // Check if user can delete material loading records
  bool get canDeleteMaterialLoadingRecords {
    return _authService.hasPermission('material_loading.delete');
  }
}

