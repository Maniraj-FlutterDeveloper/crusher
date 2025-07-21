import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/vehicle_model.dart';
import '../../../data/repositories/vehicle_repository.dart';
import '../../../data/services/auth_service.dart';
import '../../../utils/logger.dart';

class VehicleMasterController extends GetxController {
  final VehicleRepository _vehicleRepository = Get.find<VehicleRepository>();
  final AuthService _authService = Get.find<AuthService>();
  
  // Observables
  final RxList<VehicleModel> vehicles = <VehicleModel>[].obs;
  final RxList<VehicleModel> filteredVehicles = <VehicleModel>[].obs;
  final RxList<VehicleModel> selectedVehicles = <VehicleModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isEditing = false.obs;
  final RxInt currentPage = 0.obs;
  final RxInt rowsPerPage = 10.obs;
  final RxInt totalPages = 0.obs;
  final RxString searchQuery = ''.obs;
  final RxString sortColumn = 'vehicle_number'.obs;
  final RxBool sortAscending = true.obs;
  
  // Form controllers
  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController vehicleTypeController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController ownerMobileController = TextEditingController();
  final TextEditingController ownerAddressController = TextEditingController();
  
  // Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  // Current editing vehicle
  VehicleModel? currentVehicle;
  
  @override
  void onInit() {
    super.onInit();
    fetchVehicles();
  }
  
  @override
  void onClose() {
    vehicleNumberController.dispose();
    vehicleTypeController.dispose();
    capacityController.dispose();
    ownerNameController.dispose();
    ownerMobileController.dispose();
    ownerAddressController.dispose();
    super.onClose();
  }
  
  // Fetch all vehicles
  Future<void> fetchVehicles() async {
    isLoading.value = true;
    try {
      final List<VehicleModel> result = await _vehicleRepository.getAllVehicles();
      vehicles.value = result;
      applyFilters();
      calculateTotalPages();
    } catch (e) {
      Logger.error('Error fetching vehicles', e);
      Get.snackbar(
        'Error',
        'Failed to fetch vehicles',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Apply filters and sorting
  void applyFilters() {
    if (searchQuery.isEmpty) {
      filteredVehicles.value = List.from(vehicles);
    } else {
      filteredVehicles.value = vehicles.where((vehicle) {
        return vehicle.vehicleNumber.toLowerCase().contains(searchQuery.toLowerCase()) ||
               (vehicle.ownerName != null && vehicle.ownerName!.toLowerCase().contains(searchQuery.toLowerCase()));
      }).toList();
    }
    
    // Apply sorting
    filteredVehicles.sort((a, b) {
      int result;
      switch (sortColumn.value) {
        case 'vehicle_number':
          result = a.vehicleNumber.compareTo(b.vehicleNumber);
          break;
        case 'vehicle_type':
          result = (a.vehicleType ?? '').compareTo(b.vehicleType ?? '');
          break;
        case 'capacity':
          result = (a.capacity ?? 0).compareTo(b.capacity ?? 0);
          break;
        case 'owner_name':
          result = (a.ownerName ?? '').compareTo(b.ownerName ?? '');
          break;
        default:
          result = a.vehicleNumber.compareTo(b.vehicleNumber);
      }
      
      return sortAscending.value ? result : -result;
    });
    
    calculateTotalPages();
  }
  
  // Calculate total pages
  void calculateTotalPages() {
    totalPages.value = (filteredVehicles.length / rowsPerPage.value).ceil();
    if (currentPage.value >= totalPages.value && totalPages.value > 0) {
      currentPage.value = totalPages.value - 1;
    }
  }
  
  // Get paginated vehicles
  List<VehicleModel> getPaginatedVehicles() {
    if (filteredVehicles.isEmpty) return [];
    
    final int start = currentPage.value * rowsPerPage.value;
    final int end = (start + rowsPerPage.value) > filteredVehicles.length
        ? filteredVehicles.length
        : (start + rowsPerPage.value);
    
    if (start >= filteredVehicles.length) return [];
    
    return filteredVehicles.sublist(start, end);
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
  void changeSortColumn(int columnIndex, bool ascending) {
    // Map column index to column name
    String column;
    switch (columnIndex) {
      case 0:
        column = 'vehicle_number';
        break;
      case 1:
        column = 'vehicle_type';
        break;
      case 2:
        column = 'capacity';
        break;
      case 3:
        column = 'owner_name';
        break;
      default:
        column = 'vehicle_number';
    }
    
    sortColumn.value = column;
    sortAscending.value = ascending;
    applyFilters();
  }
  
  // Search vehicles
  void searchVehicles(String query) {
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
  
  // Select vehicle
  void selectVehicle(VehicleModel vehicle, bool? selected) {
    if (selected == true) {
      selectedVehicles.add(vehicle);
    } else {
      selectedVehicles.remove(vehicle);
    }
  }
  
  // Select all vehicles
  void selectAllVehicles(bool? selected) {
    if (selected == true) {
      selectedVehicles.value = List.from(getPaginatedVehicles());
    } else {
      selectedVehicles.clear();
    }
  }
  
  // Clear form
  void clearForm() {
    vehicleNumberController.clear();
    vehicleTypeController.clear();
    capacityController.clear();
    ownerNameController.clear();
    ownerMobileController.clear();
    ownerAddressController.clear();
    currentVehicle = null;
    isEditing.value = false;
  }
  
  // Set form for editing
  void setFormForEditing(VehicleModel vehicle) {
    currentVehicle = vehicle;
    vehicleNumberController.text = vehicle.vehicleNumber;
    vehicleTypeController.text = vehicle.vehicleType ?? '';
    capacityController.text = vehicle.capacity?.toString() ?? '';
    ownerNameController.text = vehicle.ownerName ?? '';
    ownerMobileController.text = vehicle.ownerMobile ?? '';
    ownerAddressController.text = vehicle.ownerAddress ?? '';
    isEditing.value = true;
  }
  
  // Save vehicle
  Future<bool> saveVehicle() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }
    
    try {
      final now = DateTime.now();
      
      if (isEditing.value && currentVehicle != null) {
        // Update existing vehicle
        final updatedVehicle = currentVehicle!.copyWith(
          vehicleNumber: vehicleNumberController.text,
          vehicleType: vehicleTypeController.text.isEmpty ? null : vehicleTypeController.text,
          capacity: capacityController.text.isEmpty ? null : double.parse(capacityController.text),
          ownerName: ownerNameController.text.isEmpty ? null : ownerNameController.text,
          ownerMobile: ownerMobileController.text.isEmpty ? null : ownerMobileController.text,
          ownerAddress: ownerAddressController.text.isEmpty ? null : ownerAddressController.text,
          updatedAt: now,
        );
        
        await _vehicleRepository.updateVehicle(updatedVehicle);
        
        // Update in the list
        final index = vehicles.indexWhere((v) => v.id == currentVehicle!.id);
        if (index != -1) {
          vehicles[index] = updatedVehicle;
        }
      } else {
        // Create new vehicle
        final newVehicle = VehicleModel(
          vehicleNumber: vehicleNumberController.text,
          vehicleType: vehicleTypeController.text.isEmpty ? null : vehicleTypeController.text,
          capacity: capacityController.text.isEmpty ? null : double.parse(capacityController.text),
          ownerName: ownerNameController.text.isEmpty ? null : ownerNameController.text,
          ownerMobile: ownerMobileController.text.isEmpty ? null : ownerMobileController.text,
          ownerAddress: ownerAddressController.text.isEmpty ? null : ownerAddressController.text,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        );
        
        final int id = await _vehicleRepository.insertVehicle(newVehicle);
        
        // Add to the list
        vehicles.add(newVehicle.copyWith(id: id));
      }
      
      applyFilters();
      clearForm();
      
      Get.snackbar(
        'Success',
        isEditing.value ? 'Vehicle updated successfully' : 'Vehicle added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      return true;
    } catch (e) {
      Logger.error('Error saving vehicle', e);
      Get.snackbar(
        'Error',
        'Failed to save vehicle',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }
  
  // Delete vehicle
  Future<bool> deleteVehicle(VehicleModel vehicle) async {
    try {
      await _vehicleRepository.deleteVehicle(vehicle.id!);
      
      // Remove from the list
      vehicles.removeWhere((v) => v.id == vehicle.id);
      selectedVehicles.removeWhere((v) => v.id == vehicle.id);
      applyFilters();
      
      Get.snackbar(
        'Success',
        'Vehicle deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      return true;
    } catch (e) {
      Logger.error('Error deleting vehicle', e);
      Get.snackbar(
        'Error',
        'Failed to delete vehicle',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }
  
  // Delete selected vehicles
  Future<bool> deleteSelectedVehicles() async {
    try {
      for (var vehicle in selectedVehicles) {
        await _vehicleRepository.deleteVehicle(vehicle.id!);
        vehicles.removeWhere((v) => v.id == vehicle.id);
      }
      
      selectedVehicles.clear();
      applyFilters();
      
      Get.snackbar(
        'Success',
        'Selected vehicles deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      return true;
    } catch (e) {
      Logger.error('Error deleting selected vehicles', e);
      Get.snackbar(
        'Error',
        'Failed to delete selected vehicles',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }
  
  // Toggle vehicle active status
  Future<bool> toggleVehicleActiveStatus(VehicleModel vehicle) async {
    try {
      await _vehicleRepository.toggleVehicleActiveStatus(vehicle.id!, !vehicle.isActive);
      
      // Update in the list
      final index = vehicles.indexWhere((v) => v.id == vehicle.id);
      if (index != -1) {
        vehicles[index] = vehicle.copyWith(isActive: !vehicle.isActive);
      }
      
      applyFilters();
      
      Get.snackbar(
        'Success',
        vehicle.isActive ? 'Vehicle deactivated successfully' : 'Vehicle activated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      return true;
    } catch (e) {
      Logger.error('Error toggling vehicle active status', e);
      Get.snackbar(
        'Error',
        'Failed to update vehicle status',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }
  
  // Check if user has permission to add/edit vehicles
  bool get canAddEditVehicles => _authService.isAdmin || _authService.isSupervisor;
  
  // Check if user has permission to delete vehicles
  bool get canDeleteVehicles => _authService.isAdmin;
  
  // Validate vehicle number
  String? validateVehicleNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vehicle number is required';
    }
    
    // Check if vehicle number already exists (for new vehicles)
    if (!isEditing.value) {
      final exists = vehicles.any((v) => v.vehicleNumber.toLowerCase() == value.toLowerCase());
      if (exists) {
        return 'Vehicle number already exists';
      }
    }
    
    // Check if vehicle number already exists (for editing vehicles)
    if (isEditing.value && currentVehicle != null) {
      final exists = vehicles.any((v) => 
        v.id != currentVehicle!.id && 
        v.vehicleNumber.toLowerCase() == value.toLowerCase()
      );
      if (exists) {
        return 'Vehicle number already exists';
      }
    }
    
    return null;
  }
  
  // Validate capacity
  String? validateCapacity(String? value) {
    if (value != null && value.isNotEmpty) {
      try {
        final capacity = double.parse(value);
        if (capacity <= 0) {
          return 'Capacity must be greater than 0';
        }
      } catch (e) {
        return 'Invalid capacity';
      }
    }
    return null;
  }
  
  // Validate owner mobile
  String? validateOwnerMobile(String? value) {
    if (value != null && value.isNotEmpty) {
      if (!RegExp(r'^\d{10}$').hasMatch(value)) {
        return 'Mobile number must be 10 digits';
      }
    }
    return null;
  }
}

