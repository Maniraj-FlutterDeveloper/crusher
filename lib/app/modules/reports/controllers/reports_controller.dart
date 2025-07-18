import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/values/app_constants.dart';
import '../../../data/models/gate_entry_model.dart';
import '../../../data/models/invoice_model.dart';
import '../../../data/models/material_loading_model.dart';
import '../../../data/repositories/gate_entry_repository.dart';
import '../../../data/repositories/material_loading_repository.dart';
import '../../../data/repositories/invoice_repository.dart';
import '../../../data/services/pdf_service.dart';
import '../../../data/services/excel_service.dart';
import '../../../data/services/auth_service.dart';

class ReportsController extends GetxController {
  final GateEntryRepository _gateEntryRepository = Get.find<GateEntryRepository>();
  final MaterialLoadingRepository _materialLoadingRepository = Get.find<MaterialLoadingRepository>();
  final InvoiceRepository _invoiceRepository = Get.find<InvoiceRepository>();
  final PdfService _pdfService = Get.find<PdfService>();
  final ExcelService _excelService = Get.find<ExcelService>();
  final AuthService _authService = Get.find<AuthService>();
  
  // Observables
  final RxBool isLoading = false.obs;
  final RxBool isProcessing = false.obs;
  final RxString selectedReport = ''.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<DateTime> startDate = DateTime.now().subtract(const Duration(days: 30)).obs;
  final Rx<DateTime> endDate = DateTime.now().obs;
  
  // Report data
  final RxList<GateEntryModel> gateEntries = <GateEntryModel>[].obs;
  final RxList<MaterialLoadingModel> materialLoadings = <MaterialLoadingModel>[].obs;
  final RxList<InvoiceModel> invoices = <InvoiceModel>[].obs;
  
  // Dashboard statistics
  final RxInt totalVehicles = 0.obs;
  final RxInt vehiclesInProcess = 0.obs;
  final RxInt vehiclesDispatched = 0.obs;
  final RxDouble totalMaterialLoaded = 0.0.obs;
  final RxDouble totalSales = 0.0.obs;
  final RxDouble totalTax = 0.0.obs;
  
  // Form controllers
  final TextEditingController dateController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  
  // Available reports
  final List<Map<String, dynamic>> availableReports = [
    {
      'id': 'daily_vehicle_log',
      'name': 'Daily Vehicle Log',
      'icon': Icons.directions_car,
      'description': 'Report of all vehicle entries and exits for a specific day',
      'requiresDateRange': false,
    },
    {
      'id': 'buyer_wise_sales',
      'name': 'Buyer-wise Sales',
      'icon': Icons.people,
      'description': 'Sales report grouped by buyers for a date range',
      'requiresDateRange': true,
    },
    {
      'id': 'supplier_wise_purchase',
      'name': 'Supplier-wise Purchase',
      'icon': Icons.local_shipping,
      'description': 'Purchase report grouped by suppliers for a date range',
      'requiresDateRange': true,
    },
    {
      'id': 'material_movement',
      'name': 'Material Movement',
      'icon': Icons.category,
      'description': 'Report of material movement for a date range',
      'requiresDateRange': true,
    },
    {
      'id': 'tax_report',
      'name': 'Tax Report',
      'icon': Icons.receipt,
      'description': 'Report of tax collection for a date range',
      'requiresDateRange': true,
    },
  ];
  
  @override
  void onInit() {
    super.onInit();
    
    // Initialize date controllers
    dateController.text = DateFormat(AppConstants.dateFormat).format(selectedDate.value);
    startDateController.text = DateFormat(AppConstants.dateFormat).format(startDate.value);
    endDateController.text = DateFormat(AppConstants.dateFormat).format(endDate.value);
    
    // Load dashboard statistics
    loadDashboardStatistics();
  }
  
  @override
  void onClose() {
    dateController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    super.onClose();
  }
  
  // Load dashboard statistics
  Future<void> loadDashboardStatistics() async {
    isLoading.value = true;
    
    try {
      // Get total vehicles
      final allGateEntries = await _gateEntryRepository.getAllGateEntries();
      totalVehicles.value = allGateEntries.length;
      
      // Get vehicles in process
      vehiclesInProcess.value = allGateEntries.where((entry) => 
        entry.status == AppConstants.vehicleStatusInProcess || 
        entry.status == AppConstants.vehicleStatusLoading || 
        entry.status == AppConstants.vehicleStatusLoaded
      ).length;
      
      // Get vehicles dispatched
      vehiclesDispatched.value = allGateEntries.where((entry) => 
        entry.status == AppConstants.vehicleStatusDispatched
      ).length;
      
      // Get total material loaded
      final allMaterialLoadings = await _materialLoadingRepository.getAllMaterialLoadingRecords();
      
      double totalQuantity = 0;
      for (final loading in allMaterialLoadings) {
        if (loading.status == AppConstants.statusLoaded) {
          totalQuantity += loading.quantity;
        }
      }
      
      totalMaterialLoaded.value = totalQuantity;
      
      // Get total sales and tax
      final allInvoices = await _invoiceRepository.getAllInvoices();
      
      double totalSalesAmount = 0;
      double totalTaxAmount = 0;
      
      for (final invoice in allInvoices) {
        if (invoice.status == AppConstants.invoiceStatusFinal) {
          totalSalesAmount += invoice.baseAmount;
          totalTaxAmount += (invoice.cgstAmount + invoice.sgstAmount + invoice.igstAmount);
        }
      }
      
      totalSales.value = totalSalesAmount;
      totalTax.value = totalTaxAmount;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load dashboard statistics: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Select report
  void selectReport(String reportId) {
    selectedReport.value = reportId;
    
    // Clear previous data
    gateEntries.clear();
    materialLoadings.clear();
    invoices.clear();
  }
  
  // Select date
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      selectedDate.value = picked;
      dateController.text = DateFormat(AppConstants.dateFormat).format(picked);
    }
  }
  
  // Select start date
  Future<void> selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      startDate.value = picked;
      startDateController.text = DateFormat(AppConstants.dateFormat).format(picked);
    }
  }
  
  // Select end date
  Future<void> selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      endDate.value = picked;
      endDateController.text = DateFormat(AppConstants.dateFormat).format(picked);
    }
  }
  
  // Generate report
  Future<String?> generateReport() async {
    if (selectedReport.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a report type',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
    
    isProcessing.value = true;
    
    try {
      String? filePath;
      
      switch (selectedReport.value) {
        case 'daily_vehicle_log':
          await _loadDailyVehicleLogData();
          filePath = await _excelService.generateDailyVehicleLogReport(
            gateEntries,
            selectedDate.value,
          );
          break;
        case 'buyer_wise_sales':
          await _loadBuyerWiseSalesData();
          filePath = await _excelService.generateBuyerWiseSalesReport(
            invoices,
            startDate.value,
            endDate.value,
          );
          break;
        case 'supplier_wise_purchase':
          await _loadSupplierWisePurchaseData();
          filePath = await _excelService.generateSupplierWisePurchaseReport(
            materialLoadings,
            startDate.value,
            endDate.value,
          );
          break;
        case 'material_movement':
          await _loadMaterialMovementData();
          filePath = await _excelService.generateMaterialMovementReport(
            materialLoadings,
            startDate.value,
            endDate.value,
          );
          break;
        case 'tax_report':
          await _loadTaxReportData();
          filePath = await _excelService.generateTaxReport(
            invoices,
            startDate.value,
            endDate.value,
          );
          break;
      }
      
      if (filePath != null) {
        Get.snackbar(
          'Success',
          'Report generated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
      
      return filePath;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate report: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    } finally {
      isProcessing.value = false;
    }
  }
  
  // Load daily vehicle log data
  Future<void> _loadDailyVehicleLogData() async {
    final startOfDay = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
    );
    
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final entries = await _gateEntryRepository.getGateEntriesByDateRange(
      startOfDay,
      endOfDay,
    );
    
    gateEntries.assignAll(entries);
  }
  
  // Load buyer-wise sales data
  Future<void> _loadBuyerWiseSalesData() async {
    final startOfDay = DateTime(
      startDate.value.year,
      startDate.value.month,
      startDate.value.day,
    );
    
    final endOfDay = DateTime(
      endDate.value.year,
      endDate.value.month,
      endDate.value.day,
    ).add(const Duration(days: 1));
    
    final invoiceList = await _invoiceRepository.getInvoicesByDateRange(
      startOfDay,
      endOfDay,
    );
    
    invoices.assignAll(invoiceList);
  }
  
  // Load supplier-wise purchase data
  Future<void> _loadSupplierWisePurchaseData() async {
    final startOfDay = DateTime(
      startDate.value.year,
      startDate.value.month,
      startDate.value.day,
    );
    
    final endOfDay = DateTime(
      endDate.value.year,
      endDate.value.month,
      endDate.value.day,
    ).add(const Duration(days: 1));
    
    final loadings = await _materialLoadingRepository.getMaterialLoadingRecordsByDateRange(
      startOfDay,
      endOfDay,
    );
    
    materialLoadings.assignAll(loadings);
  }
  
  // Load material movement data
  Future<void> _loadMaterialMovementData() async {
    final startOfDay = DateTime(
      startDate.value.year,
      startDate.value.month,
      startDate.value.day,
    );
    
    final endOfDay = DateTime(
      endDate.value.year,
      endDate.value.month,
      endDate.value.day,
    ).add(const Duration(days: 1));
    
    final loadings = await _materialLoadingRepository.getMaterialLoadingRecordsByDateRange(
      startOfDay,
      endOfDay,
    );
    
    materialLoadings.assignAll(loadings);
  }
  
  // Load tax report data
  Future<void> _loadTaxReportData() async {
    final startOfDay = DateTime(
      startDate.value.year,
      startDate.value.month,
      startDate.value.day,
    );
    
    final endOfDay = DateTime(
      endDate.value.year,
      endDate.value.month,
      endDate.value.day,
    ).add(const Duration(days: 1));
    
    final invoiceList = await _invoiceRepository.getInvoicesByDateRange(
      startOfDay,
      endOfDay,
    );
    
    invoices.assignAll(invoiceList);
  }
  
  // Check if user can access reports
  bool get canAccessReports {
    return _authService.hasPermission('reports.view');
  }
  
  // Check if user can export reports
  bool get canExportReports {
    return _authService.hasPermission('reports.export');
  }
}

