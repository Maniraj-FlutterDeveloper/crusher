import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/values/app_constants.dart';
import '../../../data/models/gate_entry_model.dart';
import '../../../data/models/vehicle_model.dart';
import '../../../data/models/weighbridge_record_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/weighbridge_repository.dart';
import '../../../data/repositories/gate_entry_repository.dart';
import '../../../data/repositories/vehicle_repository.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/pdf_service.dart';

class WeighbridgeController extends GetxController {
  final WeighbridgeRepository _weighbridgeRepository = Get.find<WeighbridgeRepository>();
  final GateEntryRepository _gateEntryRepository = Get.find<GateEntryRepository>();
  final VehicleRepository _vehicleRepository = Get.find<VehicleRepository>();
  final AuthService _authService = Get.find<AuthService>();
  final PdfService _pdfService = Get.find<PdfService>();
  
  // Observables
  final RxBool isLoading = false.obs;
  final RxBool isProcessing = false.obs;
  final RxList<WeighbridgeRecordModel> weighbridgeRecords = <WeighbridgeRecordModel>[].obs;
  final RxList<WeighbridgeRecordModel> filteredWeighbridgeRecords = <WeighbridgeRecordModel>[].obs;
  final RxList<WeightUnitModel> weightUnits = <WeightUnitModel>[].obs;
  final Rx<WeighbridgeRecordModel?> currentWeighbridgeRecord = Rx<WeighbridgeRecordModel?>(null);
  final Rx<GateEntryModel?> selectedGateEntry = Rx<GateEntryModel?>(null);
  final Rx<WeightUnitModel?> selectedWeightUnit = Rx<WeightUnitModel?>(null);
  
  // Pagination
  final RxInt currentPage = 0.obs;
  final RxInt totalPages = 0.obs;
  final RxInt rowsPerPage = 10.obs;
  
  // Sorting
  final RxString sortColumn = 'created_at'.obs;
  final RxBool sortAscending = false.obs;
  
  // Filtering
  final RxString searchQuery = ''.obs;
  
  // Form keys
  final GlobalKey<FormState> tareWeightFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> grossWeightFormKey = GlobalKey<FormState>();
  
  // Form controllers
  final TextEditingController sessionIdController = TextEditingController();
  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController driverNameController = TextEditingController();
  final TextEditingController tareWeightController = TextEditingController();
  final TextEditingController tareWeightTimeController = TextEditingController();
  final TextEditingController grossWeightController = TextEditingController();
  final TextEditingController grossWeightTimeController = TextEditingController();
  final TextEditingController netWeightController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  
  @override
  void onInit() {
    super.onInit();
    fetchWeighbridgeRecords();
    fetchWeightUnits();
  }
  
  @override
  void onClose() {
    sessionIdController.dispose();
    vehicleNumberController.dispose();
    driverNameController.dispose();
    tareWeightController.dispose();
    tareWeightTimeController.dispose();
    grossWeightController.dispose();
    grossWeightTimeController.dispose();
    netWeightController.dispose();
    remarksController.dispose();
    super.onClose();
  }
  
  // Fetch all weighbridge records
  Future<void> fetchWeighbridgeRecords() async {
    isLoading.value = true;
    try {
      final records = await _weighbridgeRepository.getAllWeighbridgeRecords();
      weighbridgeRecords.assignAll(records);
      applyFilters();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch weighbridge records: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
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
    List<WeighbridgeRecordModel> filtered = List.from(weighbridgeRecords);
    
    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((record) {
        final sessionId = record.gateEntry?.sessionId.toLowerCase() ?? '';
        final vehicleNumber = record.gateEntry?.vehicle?.vehicleNumber.toLowerCase() ?? '';
        final driverName = record.gateEntry?.driverName?.toLowerCase() ?? '';
        
        return sessionId.contains(searchQuery.value.toLowerCase()) ||
               vehicleNumber.contains(searchQuery.value.toLowerCase()) ||
               driverName.contains(searchQuery.value.toLowerCase());
      }).toList();
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
        case 'tare_weight_time':
          if (a.tareWeightTime == null && b.tareWeightTime == null) {
            result = 0;
          } else if (a.tareWeightTime == null) {
            result = -1;
          } else if (b.tareWeightTime == null) {
            result = 1;
          } else {
            result = a.tareWeightTime!.compareTo(b.tareWeightTime!);
          }
          break;
        case 'gross_weight_time':
          if (a.grossWeightTime == null && b.grossWeightTime == null) {
            result = 0;
          } else if (a.grossWeightTime == null) {
            result = -1;
          } else if (b.grossWeightTime == null) {
            result = 1;
          } else {
            result = a.grossWeightTime!.compareTo(b.grossWeightTime!);
          }
          break;
        case 'net_weight':
          if (a.netWeight == null && b.netWeight == null) {
            result = 0;
          } else if (a.netWeight == null) {
            result = -1;
          } else if (b.netWeight == null) {
            result = 1;
          } else {
            result = a.netWeight!.compareTo(b.netWeight!);
          }
          break;
        case 'created_at':
        default:
          result = a.createdAt.compareTo(b.createdAt);
          break;
      }
      
      return sortAscending.value ? result : -result;
    });
    
    filteredWeighbridgeRecords.assignAll(filtered);
    
    // Update pagination
    updatePagination();
  }
  
  // Update pagination
  void updatePagination() {
    final totalItems = filteredWeighbridgeRecords.length;
    totalPages.value = (totalItems / rowsPerPage.value).ceil();
    
    if (currentPage.value >= totalPages.value && totalPages.value > 0) {
      currentPage.value = totalPages.value - 1;
    }
  }
  
  // Get paginated weighbridge records
  List<WeighbridgeRecordModel> getPaginatedWeighbridgeRecords() {
    if (filteredWeighbridgeRecords.isEmpty) return [];
    
    final startIndex = currentPage.value * rowsPerPage.value;
    final endIndex = (startIndex + rowsPerPage.value) > filteredWeighbridgeRecords.length
        ? filteredWeighbridgeRecords.length
        : startIndex + rowsPerPage.value;
    
    if (startIndex >= filteredWeighbridgeRecords.length) return [];
    
    return filteredWeighbridgeRecords.sublist(startIndex, endIndex);
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
  
  // Search weighbridge records
  void searchWeighbridgeRecords(String query) {
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
  
  // Set gate entry for weighbridge record
  void setGateEntryForWeighbridge(GateEntryModel gateEntry) {
    selectedGateEntry.value = gateEntry;
    
    // Populate form fields
    sessionIdController.text = gateEntry.sessionId;
    vehicleNumberController.text = gateEntry.vehicle?.vehicleNumber ?? '';
    driverNameController.text = gateEntry.driverName ?? '';
    
    // Check if weighbridge record already exists for this gate entry
    _weighbridgeRepository.getWeighbridgeRecordByGateEntryId(gateEntry.id!).then((record) {
      if (record != null) {
        currentWeighbridgeRecord.value = record;
        
        // Populate form fields with existing data
        if (record.tareWeight != null) {
          tareWeightController.text = record.tareWeight.toString();
        }
        
        if (record.tareWeightTime != null) {
          tareWeightTimeController.text = DateFormat(AppConstants.dateTimeFormat).format(record.tareWeightTime!);
        }
        
        if (record.grossWeight != null) {
          grossWeightController.text = record.grossWeight.toString();
        }
        
        if (record.grossWeightTime != null) {
          grossWeightTimeController.text = DateFormat(AppConstants.dateTimeFormat).format(record.grossWeightTime!);
        }
        
        if (record.netWeight != null) {
          netWeightController.text = record.netWeight.toString();
        }
        
        remarksController.text = record.remarks ?? '';
        
        // Set weight unit
        selectedWeightUnit.value = weightUnits.firstWhere(
          (unit) => unit.id == record.weightUnitId,
          orElse: () => selectedWeightUnit.value!,
        );
      } else {
        currentWeighbridgeRecord.value = null;
        
        // Clear form fields
        tareWeightController.clear();
        tareWeightTimeController.clear();
        grossWeightController.clear();
        grossWeightTimeController.clear();
        netWeightController.clear();
        remarksController.clear();
      }
    });
  }
  
  // Calculate net weight
  void calculateNetWeight() {
    if (tareWeightController.text.isNotEmpty && grossWeightController.text.isNotEmpty) {
      try {
        final tareWeight = double.parse(tareWeightController.text);
        final grossWeight = double.parse(grossWeightController.text);
        
        if (grossWeight >= tareWeight) {
          final netWeight = _weighbridgeRepository.calculateNetWeight(grossWeight, tareWeight);
          netWeightController.text = netWeight.toString();
        } else {
          netWeightController.text = '0';
          Get.snackbar(
            'Error',
            'Gross weight must be greater than or equal to tare weight',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        netWeightController.text = '';
      }
    } else {
      netWeightController.text = '';
    }
  }
  
  // Save tare weight
  Future<bool> saveTareWeight() async {
    if (!tareWeightFormKey.currentState!.validate()) {
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
      
      final tareWeight = double.parse(tareWeightController.text);
      final tareWeightTime = tareWeightTimeController.text.isNotEmpty
          ? DateFormat(AppConstants.dateTimeFormat).parse(tareWeightTimeController.text)
          : DateTime.now();
      
      // Check if weighbridge record already exists
      if (currentWeighbridgeRecord.value != null) {
        // Update existing record
        final updatedRecord = currentWeighbridgeRecord.value!.copyWith(
          tareWeight: tareWeight,
          tareWeightTime: tareWeightTime,
          remarks: remarksController.text,
          weightUnitId: selectedWeightUnit.value!.id!,
          updatedAt: DateTime.now(),
        );
        
        await _weighbridgeRepository.updateWeighbridgeRecord(updatedRecord);
        
        // Update gate entry tare weight
        final updatedGateEntry = selectedGateEntry.value!.copyWith(
          tareWeight: tareWeight,
          updatedAt: DateTime.now(),
        );
        
        await _gateEntryRepository.updateGateEntry(updatedGateEntry);
        
        Get.snackbar(
          'Success',
          'Tare weight updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        // Create new record
        final newRecord = WeighbridgeRecordModel(
          gateEntryId: selectedGateEntry.value!.id!,
          tareWeight: tareWeight,
          tareWeightTime: tareWeightTime,
          weightUnitId: selectedWeightUnit.value!.id!,
          operatorId: currentUser.id!,
          remarks: remarksController.text,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await _weighbridgeRepository.insertWeighbridgeRecord(newRecord);
        
        // Update gate entry tare weight
        final updatedGateEntry = selectedGateEntry.value!.copyWith(
          tareWeight: tareWeight,
          updatedAt: DateTime.now(),
        );
        
        await _gateEntryRepository.updateGateEntry(updatedGateEntry);
        
        Get.snackbar(
          'Success',
          'Tare weight saved successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
      
      // Refresh data
      await fetchWeighbridgeRecords();
      
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save tare weight: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isProcessing.value = false;
    }
  }
  
  // Save gross weight
  Future<bool> saveGrossWeight() async {
    if (!grossWeightFormKey.currentState!.validate()) {
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
      
      final grossWeight = double.parse(grossWeightController.text);
      final grossWeightTime = grossWeightTimeController.text.isNotEmpty
          ? DateFormat(AppConstants.dateTimeFormat).parse(grossWeightTimeController.text)
          : DateTime.now();
      
      double netWeight = 0;
      
      if (tareWeightController.text.isNotEmpty) {
        final tareWeight = double.parse(tareWeightController.text);
        netWeight = _weighbridgeRepository.calculateNetWeight(grossWeight, tareWeight);
      }
      
      // Check if weighbridge record already exists
      if (currentWeighbridgeRecord.value != null) {
        // Update existing record
        final updatedRecord = currentWeighbridgeRecord.value!.copyWith(
          grossWeight: grossWeight,
          grossWeightTime: grossWeightTime,
          netWeight: netWeight,
          remarks: remarksController.text,
          weightUnitId: selectedWeightUnit.value!.id!,
          updatedAt: DateTime.now(),
        );
        
        await _weighbridgeRepository.updateWeighbridgeRecord(updatedRecord);
        
        // Update gate entry gross weight and net weight
        final updatedGateEntry = selectedGateEntry.value!.copyWith(
          grossWeight: grossWeight,
          netWeight: netWeight,
          exitTime: grossWeightTime,
          status: AppConstants.vehicleStatusDispatched,
          updatedAt: DateTime.now(),
        );
        
        await _gateEntryRepository.updateGateEntry(updatedGateEntry);
        
        Get.snackbar(
          'Success',
          'Gross weight updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        // Create new record
        final newRecord = WeighbridgeRecordModel(
          gateEntryId: selectedGateEntry.value!.id!,
          grossWeight: grossWeight,
          grossWeightTime: grossWeightTime,
          netWeight: netWeight,
          weightUnitId: selectedWeightUnit.value!.id!,
          operatorId: currentUser.id!,
          remarks: remarksController.text,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await _weighbridgeRepository.insertWeighbridgeRecord(newRecord);
        
        // Update gate entry gross weight and net weight
        final updatedGateEntry = selectedGateEntry.value!.copyWith(
          grossWeight: grossWeight,
          netWeight: netWeight,
          exitTime: grossWeightTime,
          status: AppConstants.vehicleStatusDispatched,
          updatedAt: DateTime.now(),
        );
        
        await _gateEntryRepository.updateGateEntry(updatedGateEntry);
        
        Get.snackbar(
          'Success',
          'Gross weight saved successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
      
      // Refresh data
      await fetchWeighbridgeRecords();
      
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save gross weight: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isProcessing.value = false;
    }
  }
  
  // Print weigh slip
  Future<void> printWeighSlip(WeighbridgeRecordModel record) async {
    try {
      await _pdfService.generateWeighSlip(record);
      
      Get.snackbar(
        'Success',
        'Weigh slip generated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate weigh slip: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  // Clear form
  void clearForm() {
    selectedGateEntry.value = null;
    currentWeighbridgeRecord.value = null;
    
    sessionIdController.clear();
    vehicleNumberController.clear();
    driverNameController.clear();
    tareWeightController.clear();
    tareWeightTimeController.clear();
    grossWeightController.clear();
    grossWeightTimeController.clear();
    netWeightController.clear();
    remarksController.clear();
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
  
  // Validate tare weight
  String? validateTareWeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tare weight is required';
    }
    
    try {
      final tareWeight = double.parse(value);
      
      if (tareWeight <= 0) {
        return 'Tare weight must be greater than 0';
      }
    } catch (e) {
      return 'Invalid tare weight';
    }
    
    return null;
  }
  
  // Validate gross weight
  String? validateGrossWeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Gross weight is required';
    }
    
    try {
      final grossWeight = double.parse(value);
      
      if (grossWeight <= 0) {
        return 'Gross weight must be greater than 0';
      }
      
      if (tareWeightController.text.isNotEmpty) {
        final tareWeight = double.parse(tareWeightController.text);
        
        if (grossWeight < tareWeight) {
          return 'Gross weight must be greater than or equal to tare weight';
        }
      }
    } catch (e) {
      return 'Invalid gross weight';
    }
    
    return null;
  }
  
  // Validate tare weight time
  String? validateTareWeightTime(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tare weight time is required';
    }
    
    try {
      DateFormat(AppConstants.dateTimeFormat).parse(value);
    } catch (e) {
      return 'Invalid date/time format';
    }
    
    return null;
  }
  
  // Validate gross weight time
  String? validateGrossWeightTime(String? value) {
    if (value == null || value.isEmpty) {
      return 'Gross weight time is required';
    }
    
    try {
      final grossWeightTime = DateFormat(AppConstants.dateTimeFormat).parse(value);
      
      if (tareWeightTimeController.text.isNotEmpty) {
        final tareWeightTime = DateFormat(AppConstants.dateTimeFormat).parse(tareWeightTimeController.text);
        
        if (grossWeightTime.isBefore(tareWeightTime)) {
          return 'Gross weight time must be after tare weight time';
        }
      }
    } catch (e) {
      return 'Invalid date/time format';
    }
    
    return null;
  }
  
  // Check if user can add weighbridge records
  bool get canAddWeighbridgeRecords {
    return _authService.hasPermission('weighbridge.add');
  }
  
  // Check if user can edit weighbridge records
  bool get canEditWeighbridgeRecords {
    return _authService.hasPermission('weighbridge.edit');
  }
  
  // Check if user can delete weighbridge records
  bool get canDeleteWeighbridgeRecords {
    return _authService.hasPermission('weighbridge.delete');
  }
  
  // Check if user can print weighbridge records
  bool get canPrintWeighbridgeRecords {
    return _authService.hasPermission('weighbridge.print');
  }
}

