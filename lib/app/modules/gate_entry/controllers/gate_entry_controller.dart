import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/models/gate_entry_model.dart';
import '../../../data/models/vehicle_model.dart';
import '../../../data/repositories/gate_entry_repository.dart';
import '../../../data/repositories/vehicle_repository.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/pdf_service.dart';
import '../../../core/values/app_constants.dart';

class GateEntryController extends GetxController {
  final GateEntryRepository _gateEntryRepository = Get.find<GateEntryRepository>();
  final VehicleRepository _vehicleRepository = Get.find<VehicleRepository>();
  final AuthService _authService = Get.find<AuthService>();
  final PdfService _pdfService = Get.find<PdfService>();
  
  // Observables
  final RxList<GateEntryModel> gateEntries = <GateEntryModel>[].obs;
  final RxList<GateEntryModel> filteredGateEntries = <GateEntryModel>[].obs;
  final RxList<VehicleModel> vehicles = <VehicleModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isProcessing = false.obs;
  final RxInt currentPage = 0.obs;
  final RxInt rowsPerPage = 10.obs;
  final RxInt totalPages = 0.obs;
  final RxString searchQuery = ''.obs;
  final RxString sortColumn = 'entry_time'.obs;
  final RxBool sortAscending = false.obs;
  final RxString selectedStatus = 'ALL'.obs;
  
  // Form controllers
  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController driverNameController = TextEditingController();
  final TextEditingController driverMobileController = TextEditingController();
  final TextEditingController entryTimeController = TextEditingController();
  final TextEditingController exitTimeController = TextEditingController();
  final TextEditingController tareWeightController = TextEditingController();
  final TextEditingController grossWeightController = TextEditingController();
  final TextEditingController netWeightController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  
  // Selected vehicle
  final Rx<VehicleModel?> selectedVehicle = Rx<VehicleModel?>(null);
  
  // Form keys
  final GlobalKey<FormState> vehicleInFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> vehicleOutFormKey = GlobalKey<FormState>();
  
  // Current gate entry
  final Rx<GateEntryModel?> currentGateEntry = Rx<GateEntryModel?>(null);
  
  // Status filter options
  final List<String> statusOptions = [
    'ALL',
    AppConstants.vehicleStatusInProcess,
    AppConstants.vehicleStatusLoading,
    AppConstants.vehicleStatusLoaded,
    AppConstants.vehicleStatusDispatched,
  ];
  
  @override
  void onInit() {
    super.onInit();
    fetchGateEntries();
    fetchVehicles();
    
    // Set default entry time
    entryTimeController.text = DateFormat(AppConstants.dateTimeFormat).format(DateTime.now());
  }
  
  @override
  void onClose() {
    vehicleNumberController.dispose();
    driverNameController.dispose();
    driverMobileController.dispose();
    entryTimeController.dispose();
    exitTimeController.dispose();
    tareWeightController.dispose();
    grossWeightController.dispose();
    netWeightController.dispose();
    remarksController.dispose();
    super.onClose();
  }
  
  // Fetch all gate entries
  Future<void> fetchGateEntries() async {
    isLoading.value = true;
    try {
      final List<GateEntryModel> result = await _gateEntryRepository.getAllGateEntries();
      gateEntries.value = result;
      applyFilters();
      calculateTotalPages();
    } catch (e) {
      print('Error fetching gate entries: $e');
      Get.snackbar(
        'Error',
        'Failed to fetch gate entries',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Fetch all vehicles
  Future<void> fetchVehicles() async {
    try {
      final List<VehicleModel> result = await _vehicleRepository.getActiveVehicles();
      vehicles.value = result;
    } catch (e) {
      print('Error fetching vehicles: $e');
      Get.snackbar(
        'Error',
        'Failed to fetch vehicles',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  // Apply filters and sorting
  void applyFilters() {
    if (selectedStatus.value == 'ALL' && searchQuery.isEmpty) {
      filteredGateEntries.value = List.from(gateEntries);
    } else {
      filteredGateEntries.value = gateEntries.where((entry) {
        bool statusMatch = selectedStatus.value == 'ALL' || entry.status == selectedStatus.value;
        bool searchMatch = true;
        
        if (searchQuery.isNotEmpty) {
          searchMatch = entry.sessionId.toLowerCase().contains(searchQuery.toLowerCase()) ||
                       (entry.vehicle?.vehicleNumber.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
                       (entry.driverName?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false);
        }
        
        return statusMatch && searchMatch;
      }).toList();
    }
    
    // Apply sorting
    filteredGateEntries.sort((a, b) {
      int result;
      switch (sortColumn.value) {
        case 'entry_time':
          result = a.entryTime.compareTo(b.entryTime);
          break;
        case 'exit_time':
          final DateTime aExitTime = a.exitTime ?? DateTime(9999);
          final DateTime bExitTime = b.exitTime ?? DateTime(9999);
          result = aExitTime.compareTo(bExitTime);
          break;
        case 'session_id':
          result = a.sessionId.compareTo(b.sessionId);
          break;
        case 'vehicle_number':
          final String aVehicleNumber = a.vehicle?.vehicleNumber ?? '';
          final String bVehicleNumber = b.vehicle?.vehicleNumber ?? '';
          result = aVehicleNumber.compareTo(bVehicleNumber);
          break;
        case 'status':
          result = a.status.compareTo(b.status);
          break;
        default:
          result = a.entryTime.compareTo(b.entryTime);
      }
      
      return sortAscending.value ? result : -result;
    });
    
    calculateTotalPages();
  }
  
  // Calculate total pages
  void calculateTotalPages() {
    totalPages.value = (filteredGateEntries.length / rowsPerPage.value).ceil();
    if (currentPage.value >= totalPages.value && totalPages.value > 0) {
      currentPage.value = totalPages.value - 1;
    }
  }
  
  // Get paginated gate entries
  List<GateEntryModel> getPaginatedGateEntries() {
    if (filteredGateEntries.isEmpty) return [];
    
    final int start = currentPage.value * rowsPerPage.value;
    final int end = (start + rowsPerPage.value) > filteredGateEntries.length
        ? filteredGateEntries.length
        : (start + rowsPerPage.value);
    
    if (start >= filteredGateEntries.length) return [];
    
    return filteredGateEntries.sublist(start, end);
  }
  
  // Change page
  void changePage(int page) {
    currentPage.value = page;
  }
  
  // Change rows per page
  void changeRowsPerPage(int? value) {
    if (value != null) {
      rowsPerPage.value = value;
      calculateTotalPages();
      if (currentPage.value >= totalPages.value && totalPages.value > 0) {
        currentPage.value = totalPages.value - 1;
      }
    }
  }
  
  // Change sort column
  void changeSortColumn(String column) {
    if (sortColumn.value == column) {
      sortAscending.toggle();
    } else {
      sortColumn.value = column;
      sortAscending.value = true;
    }
    applyFilters();
  }
  
  // Search gate entries
  void searchGateEntries(String query) {
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
  
  // Change status filter
  void changeStatusFilter(String? status) {
    if (status != null) {
      selectedStatus.value = status;
      currentPage.value = 0;
      applyFilters();
    }
  }
  
  // Clear vehicle in form
  void clearVehicleInForm() {
    vehicleNumberController.clear();
    driverNameController.clear();
    driverMobileController.clear();
    entryTimeController.text = DateFormat(AppConstants.dateTimeFormat).format(DateTime.now());
    tareWeightController.clear();
    remarksController.clear();
    selectedVehicle.value = null;
  }
  
  // Clear vehicle out form
  void clearVehicleOutForm() {
    exitTimeController.text = DateFormat(AppConstants.dateTimeFormat).format(DateTime.now());
    grossWeightController.clear();
    netWeightController.clear();
    currentGateEntry.value = null;
  }
  
  // Set vehicle for vehicle in form
  void setVehicleForForm(VehicleModel vehicle) {
    selectedVehicle.value = vehicle;
    vehicleNumberController.text = vehicle.vehicleNumber;
  }
  
  // Set gate entry for vehicle out form
  void setGateEntryForVehicleOut(GateEntryModel gateEntry) {
    currentGateEntry.value = gateEntry;
    exitTimeController.text = DateFormat(AppConstants.dateTimeFormat).format(DateTime.now());
    if (gateEntry.tareWeight != null) {
      tareWeightController.text = gateEntry.tareWeight.toString();
    }
  }
  
  // Save vehicle in (gate entry)
  Future<bool> saveVehicleIn() async {
    if (!vehicleInFormKey.currentState!.validate()) {
      return false;
    }
    
    isProcessing.value = true;
    try {
      final now = DateTime.now();
      final sessionId = await _gateEntryRepository.generateSessionId();
      final gatePassNumber = await _gateEntryRepository.generateGatePassNumber();
      
      // Create gate entry
      final gateEntry = GateEntryModel(
        sessionId: sessionId,
        vehicleId: selectedVehicle.value!.id!,
        driverName: driverNameController.text.isEmpty ? null : driverNameController.text,
        driverMobile: driverMobileController.text.isEmpty ? null : driverMobileController.text,
        entryTime: DateFormat(AppConstants.dateTimeFormat).parse(entryTimeController.text),
        tareWeight: tareWeightController.text.isEmpty ? null : double.parse(tareWeightController.text),
        status: AppConstants.vehicleStatusInProcess,
        gatePassNumber: gatePassNumber,
        operatorId: _authService.currentUser!.id!,
        createdAt: now,
        updatedAt: now,
        vehicle: selectedVehicle.value,
      );
      
      final int id = await _gateEntryRepository.insertGateEntry(gateEntry);
      
      // Add to the list
      final newGateEntry = gateEntry.copyWith(id: id);
      gateEntries.add(newGateEntry);
      applyFilters();
      
      // Generate gate pass
      await _pdfService.generateGatePass(newGateEntry);
      
      Get.snackbar(
        'Success',
        'Vehicle entry recorded successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      clearVehicleInForm();
      return true;
    } catch (e) {
      print('Error saving vehicle in: $e');
      Get.snackbar(
        'Error',
        'Failed to record vehicle entry',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isProcessing.value = false;
    }
  }
  
  // Save vehicle out (update gate entry)
  Future<bool> saveVehicleOut() async {
    if (!vehicleOutFormKey.currentState!.validate()) {
      return false;
    }
    
    isProcessing.value = true;
    try {
      final now = DateTime.now();
      final double grossWeight = double.parse(grossWeightController.text);
      final double tareWeight = currentGateEntry.value!.tareWeight ?? 0;
      final double netWeight = grossWeight - tareWeight;
      
      // Update gate entry
      final updatedGateEntry = currentGateEntry.value!.copyWith(
        exitTime: DateFormat(AppConstants.dateTimeFormat).parse(exitTimeController.text),
        grossWeight: grossWeight,
        netWeight: netWeight,
        status: AppConstants.vehicleStatusDispatched,
        updatedAt: now,
      );
      
      await _gateEntryRepository.updateGateEntry(updatedGateEntry);
      
      // Update in the list
      final index = gateEntries.indexWhere((entry) => entry.id == currentGateEntry.value!.id);
      if (index != -1) {
        gateEntries[index] = updatedGateEntry;
      }
      applyFilters();
      
      Get.snackbar(
        'Success',
        'Vehicle exit recorded successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      clearVehicleOutForm();
      return true;
    } catch (e) {
      print('Error saving vehicle out: $e');
      Get.snackbar(
        'Error',
        'Failed to record vehicle exit',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isProcessing.value = false;
    }
  }
  
  // Print gate pass
  Future<void> printGatePass(GateEntryModel gateEntry) async {
    try {
      final file = await _pdfService.generateGatePass(gateEntry);
      await _pdfService.printPdf(file);
    } catch (e) {
      print('Error printing gate pass: $e');
      Get.snackbar(
        'Error',
        'Failed to print gate pass',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  // Cancel gate entry
  Future<bool> cancelGateEntry(GateEntryModel gateEntry) async {
    try {
      await _gateEntryRepository.deleteGateEntry(gateEntry.id!);
      
      // Remove from the list
      gateEntries.removeWhere((entry) => entry.id == gateEntry.id);
      applyFilters();
      
      Get.snackbar(
        'Success',
        'Gate entry cancelled successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      return true;
    } catch (e) {
      print('Error cancelling gate entry: $e');
      Get.snackbar(
        'Error',
        'Failed to cancel gate entry',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }
  
  // Check if user has permission to add gate entries
  bool get canAddGateEntries => _authService.isAdmin || _authService.isSupervisor || _authService.isOperator;
  
  // Check if user has permission to cancel gate entries
  bool get canCancelGateEntries => _authService.isAdmin || _authService.isSupervisor;
  
  // Validate vehicle number
  String? validateVehicleNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vehicle number is required';
    }
    
    if (selectedVehicle.value == null) {
      return 'Please select a valid vehicle';
    }
    
    return null;
  }
  
  // Validate driver mobile
  String? validateDriverMobile(String? value) {
    if (value != null && value.isNotEmpty) {
      if (!RegExp(r'^\d{10}$').hasMatch(value)) {
        return 'Mobile number must be 10 digits';
      }
    }
    return null;
  }
  
  // Validate entry time
  String? validateEntryTime(String? value) {
    if (value == null || value.isEmpty) {
      return 'Entry time is required';
    }
    
    try {
      DateFormat(AppConstants.dateTimeFormat).parse(value);
    } catch (e) {
      return 'Invalid date/time format';
    }
    
    return null;
  }
  
  // Validate exit time
  String? validateExitTime(String? value) {
    if (value == null || value.isEmpty) {
      return 'Exit time is required';
    }
    
    try {
      final exitTime = DateFormat(AppConstants.dateTimeFormat).parse(value);
      final entryTime = currentGateEntry.value!.entryTime;
      
      if (exitTime.isBefore(entryTime)) {
        return 'Exit time cannot be before entry time';
      }
    } catch (e) {
      return 'Invalid date/time format';
    }
    
    return null;
  }
  
  // Validate tare weight
  String? validateTareWeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tare weight is required';
    }
    
    try {
      final weight = double.parse(value);
      if (weight <= 0) {
        return 'Tare weight must be greater than 0';
      }
    } catch (e) {
      return 'Invalid weight';
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
      
      final tareWeight = currentGateEntry.value!.tareWeight ?? 0;
      if (grossWeight <= tareWeight) {
        return 'Gross weight must be greater than tare weight';
      }
    } catch (e) {
      return 'Invalid weight';
    }
    
    return null;
  }
  
  // Calculate net weight
  void calculateNetWeight() {
    if (grossWeightController.text.isNotEmpty && currentGateEntry.value != null && currentGateEntry.value!.tareWeight != null) {
      try {
        final grossWeight = double.parse(grossWeightController.text);
        final tareWeight = currentGateEntry.value!.tareWeight!;
        final netWeight = grossWeight - tareWeight;
        
        netWeightController.text = netWeight.toString();
      } catch (e) {
        netWeightController.clear();
      }
    } else {
      netWeightController.clear();
    }
  }
  
  // Get status color
  Color getStatusColor(String status) {
    switch (status) {
      case AppConstants.vehicleStatusInProcess:
        return Colors.blue;
      case AppConstants.vehicleStatusLoading:
        return Colors.orange;
      case AppConstants.vehicleStatusLoaded:
        return Colors.purple;
      case AppConstants.vehicleStatusDispatched:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
  
  // Get pending vehicles
  List<GateEntryModel> getPendingVehicles() {
    return gateEntries.where((entry) => 
      entry.status != AppConstants.vehicleStatusDispatched
    ).toList();
  }
  
  // Search vehicles
  List<VehicleModel> searchVehicles(String query) {
    if (query.isEmpty) {
      return [];
    }
    
    return vehicles.where((vehicle) => 
      vehicle.vehicleNumber.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}

