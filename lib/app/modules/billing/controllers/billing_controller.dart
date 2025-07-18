import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/values/app_constants.dart';
import '../../../data/models/gate_entry_model.dart';
import '../../../data/models/invoice_model.dart';
import '../../../data/models/material_model.dart';
import '../../../data/models/material_loading_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/invoice_repository.dart';
import '../../../data/repositories/gate_entry_repository.dart';
import '../../../data/repositories/material_loading_repository.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/pdf_service.dart';

class BillingController extends GetxController {
  final InvoiceRepository _invoiceRepository = Get.find<InvoiceRepository>();
  final GateEntryRepository _gateEntryRepository = Get.find<GateEntryRepository>();
  final MaterialLoadingRepository _materialLoadingRepository = Get.find<MaterialLoadingRepository>();
  final PdfService _pdfService = Get.find<PdfService>();
  final AuthService _authService = Get.find<AuthService>();
  
  // Observables
  final RxBool isLoading = false.obs;
  final RxBool isProcessing = false.obs;
  final RxList<InvoiceModel> invoices = <InvoiceModel>[].obs;
  final RxList<InvoiceModel> filteredInvoices = <InvoiceModel>[].obs;
  final RxList<BuyerModel> buyers = <BuyerModel>[].obs;
  final RxList<MaterialModel> materials = <MaterialModel>[].obs;
  final RxList<MaterialSizeModel> materialSizes = <MaterialSizeModel>[].obs;
  final RxList<WeightUnitModel> weightUnits = <WeightUnitModel>[].obs;
  final Rx<InvoiceModel?> currentInvoice = Rx<InvoiceModel?>(null);
  final Rx<GateEntryModel?> selectedGateEntry = Rx<GateEntryModel?>(null);
  final Rx<BuyerModel?> selectedBuyer = Rx<BuyerModel?>(null);
  final RxList<InvoiceItemModel> invoiceItems = <InvoiceItemModel>[].obs;
  final RxBool isSameState = true.obs;
  
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
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);
  
  // Form keys
  final GlobalKey<FormState> invoiceFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> buyerFormKey = GlobalKey<FormState>();
  
  // Form controllers
  final TextEditingController sessionIdController = TextEditingController();
  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController driverNameController = TextEditingController();
  final TextEditingController invoiceNumberController = TextEditingController();
  final TextEditingController invoiceDateController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  
  // Buyer form controllers
  final TextEditingController buyerNameController = TextEditingController();
  final TextEditingController gstinController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController contactMobileController = TextEditingController();
  final TextEditingController contactEmailController = TextEditingController();
  
  @override
  void onInit() {
    super.onInit();
    fetchInvoices();
    fetchBuyers();
    fetchMaterials();
    fetchMaterialSizes();
    fetchWeightUnits();
  }
  
  @override
  void onClose() {
    sessionIdController.dispose();
    vehicleNumberController.dispose();
    driverNameController.dispose();
    invoiceNumberController.dispose();
    invoiceDateController.dispose();
    remarksController.dispose();
    
    buyerNameController.dispose();
    gstinController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    contactPersonController.dispose();
    contactMobileController.dispose();
    contactEmailController.dispose();
    
    super.onClose();
  }
  
  // Fetch all invoices
  Future<void> fetchInvoices() async {
    isLoading.value = true;
    try {
      final invoiceList = await _invoiceRepository.getAllInvoices();
      invoices.assignAll(invoiceList);
      applyFilters();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch invoices: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Fetch all buyers
  Future<void> fetchBuyers() async {
    try {
      final buyersList = await _invoiceRepository.getActiveBuyers();
      buyers.assignAll(buyersList);
      
      if (buyers.isNotEmpty) {
        selectedBuyer.value = buyers.first;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch buyers: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  // Fetch all materials
  Future<void> fetchMaterials() async {
    try {
      final materialsList = await _materialLoadingRepository.getActiveMaterials();
      materials.assignAll(materialsList);
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
  
  // Fetch all weight units
  Future<void> fetchWeightUnits() async {
    try {
      final units = await _materialLoadingRepository.getWeightUnits();
      weightUnits.assignAll(units);
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
    List<InvoiceModel> filtered = List.from(invoices);
    
    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((invoice) {
        final invoiceNumber = invoice.invoiceNumber.toLowerCase();
        final sessionId = invoice.gateEntry?.sessionId.toLowerCase() ?? '';
        final vehicleNumber = invoice.gateEntry?.vehicle?.vehicleNumber.toLowerCase() ?? '';
        final buyerName = invoice.buyer?.name.toLowerCase() ?? '';
        
        return invoiceNumber.contains(searchQuery.value.toLowerCase()) ||
               sessionId.contains(searchQuery.value.toLowerCase()) ||
               vehicleNumber.contains(searchQuery.value.toLowerCase()) ||
               buyerName.contains(searchQuery.value.toLowerCase());
      }).toList();
    }
    
    // Apply status filter
    if (statusFilter.value.isNotEmpty) {
      filtered = filtered.where((invoice) => invoice.status == statusFilter.value).toList();
    }
    
    // Apply date range filter
    if (startDate.value != null && endDate.value != null) {
      filtered = filtered.where((invoice) {
        return invoice.invoiceDate.isAfter(startDate.value!) &&
               invoice.invoiceDate.isBefore(endDate.value!.add(const Duration(days: 1)));
      }).toList();
    }
    
    // Apply sorting
    filtered.sort((a, b) {
      int result = 0;
      
      switch (sortColumn.value) {
        case 'invoice_number':
          result = a.invoiceNumber.compareTo(b.invoiceNumber);
          break;
        case 'invoice_date':
          result = a.invoiceDate.compareTo(b.invoiceDate);
          break;
        case 'buyer_name':
          result = (a.buyer?.name ?? '').compareTo(b.buyer?.name ?? '');
          break;
        case 'total_amount':
          result = a.totalAmount.compareTo(b.totalAmount);
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
    
    filteredInvoices.assignAll(filtered);
    
    // Update pagination
    updatePagination();
  }
  
  // Update pagination
  void updatePagination() {
    final totalItems = filteredInvoices.length;
    totalPages.value = (totalItems / rowsPerPage.value).ceil();
    
    if (currentPage.value >= totalPages.value && totalPages.value > 0) {
      currentPage.value = totalPages.value - 1;
    }
  }
  
  // Get paginated invoices
  List<InvoiceModel> getPaginatedInvoices() {
    if (filteredInvoices.isEmpty) return [];
    
    final startIndex = currentPage.value * rowsPerPage.value;
    final endIndex = (startIndex + rowsPerPage.value) > filteredInvoices.length
        ? filteredInvoices.length
        : startIndex + rowsPerPage.value;
    
    if (startIndex >= filteredInvoices.length) return [];
    
    return filteredInvoices.sublist(startIndex, endIndex);
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
  
  // Search invoices
  void searchInvoices(String query) {
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
  
  // Filter by date range
  void filterByDateRange(DateTime start, DateTime end) {
    startDate.value = start;
    endDate.value = end;
    currentPage.value = 0;
    applyFilters();
  }
  
  // Clear date range filter
  void clearDateRangeFilter() {
    startDate.value = null;
    endDate.value = null;
    currentPage.value = 0;
    applyFilters();
  }
  
  // Set gate entry for invoice
  void setGateEntryForInvoice(GateEntryModel gateEntry) async {
    selectedGateEntry.value = gateEntry;
    
    // Populate form fields
    sessionIdController.text = gateEntry.sessionId;
    vehicleNumberController.text = gateEntry.vehicle?.vehicleNumber ?? '';
    driverNameController.text = gateEntry.driverName ?? '';
    
    // Generate invoice number
    invoiceNumberController.text = await _invoiceRepository.generateInvoiceNumber();
    
    // Set invoice date to today
    final today = DateTime.now();
    invoiceDateController.text = DateFormat(AppConstants.dateFormat).format(today);
    
    // Clear invoice items
    invoiceItems.clear();
    
    // Check if material loading records exist for this gate entry
    final materialLoadingRecords = await _materialLoadingRepository.getMaterialLoadingRecordsByGateEntry(gateEntry.id!);
    
    if (materialLoadingRecords.isNotEmpty) {
      // Create invoice items from material loading records
      for (final record in materialLoadingRecords) {
        if (record.status == AppConstants.statusLoaded) {
          final material = await _materialLoadingRepository.getMaterialById(record.materialId);
          
          if (material != null) {
            MaterialSizeModel? materialSize;
            if (record.materialSizeId != null) {
              materialSize = await _materialLoadingRepository.getMaterialSizeById(record.materialSizeId!);
            }
            
            final weightUnit = await _materialLoadingRepository.getWeightUnitById(record.weightUnitId);
            
            if (weightUnit != null) {
              final rate = material.rate ?? 0;
              
              final invoiceItem = InvoiceItemModel(
                invoiceId: 0, // Will be set when invoice is created
                materialId: material.id!,
                materialSizeId: materialSize?.id,
                quantity: record.quantity,
                weightUnitId: weightUnit.id!,
                rate: rate,
                amount: record.quantity * rate,
                cgstPercentage: material.taxConfiguration?.cgstPercentage ?? 0,
                sgstPercentage: material.taxConfiguration?.sgstPercentage ?? 0,
                igstPercentage: material.taxConfiguration?.igstPercentage ?? 0,
                cgstAmount: 0, // Will be calculated
                sgstAmount: 0, // Will be calculated
                igstAmount: 0, // Will be calculated
                totalAmount: 0, // Will be calculated
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                material: material,
                materialSize: materialSize,
                weightUnit: weightUnit,
              );
              
              // Calculate tax amounts
              final calculatedItem = _invoiceRepository.calculateInvoiceItemAmounts(
                invoiceItem,
                isSameState.value,
              );
              
              invoiceItems.add(calculatedItem);
            }
          }
        }
      }
    }
    
    // Check if invoice already exists for this gate entry
    final existingInvoices = await _invoiceRepository.getInvoicesByGateEntry(gateEntry.id!);
    
    if (existingInvoices.isNotEmpty) {
      currentInvoice.value = existingInvoices.first;
      
      // Populate form fields with existing data
      invoiceNumberController.text = currentInvoice.value!.invoiceNumber;
      invoiceDateController.text = DateFormat(AppConstants.dateFormat).format(currentInvoice.value!.invoiceDate);
      
      if (currentInvoice.value!.buyerId != null) {
        selectedBuyer.value = buyers.firstWhere(
          (buyer) => buyer.id == currentInvoice.value!.buyerId,
          orElse: () => buyers.first,
        );
      }
      
      remarksController.text = currentInvoice.value!.remarks ?? '';
      
      // Set invoice items
      if (currentInvoice.value!.items != null) {
        invoiceItems.assignAll(currentInvoice.value!.items!);
      }
    } else {
      currentInvoice.value = null;
    }
  }
  
  // Add invoice item
  void addInvoiceItem(InvoiceItemModel item) {
    invoiceItems.add(item);
  }
  
  // Update invoice item
  void updateInvoiceItem(int index, InvoiceItemModel item) {
    invoiceItems[index] = item;
  }
  
  // Remove invoice item
  void removeInvoiceItem(int index) {
    invoiceItems.removeAt(index);
  }
  
  // Calculate invoice item amounts
  InvoiceItemModel calculateInvoiceItemAmounts(InvoiceItemModel item) {
    return _invoiceRepository.calculateInvoiceItemAmounts(item, isSameState.value);
  }
  
  // Calculate invoice total amounts
  InvoiceModel calculateInvoiceTotalAmounts(InvoiceModel invoice) {
    return _invoiceRepository.calculateInvoiceTotalAmounts(invoice);
  }
  
  // Save invoice
  Future<bool> saveInvoice(String status) async {
    if (!invoiceFormKey.currentState!.validate()) {
      return false;
    }
    
    if (invoiceItems.isEmpty) {
      Get.snackbar(
        'Error',
        'No invoice items added',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
      
      if (selectedBuyer.value == null) {
        Get.snackbar(
          'Error',
          'No buyer selected',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
      
      // Calculate total amounts
      double baseAmount = 0;
      double cgstAmount = 0;
      double sgstAmount = 0;
      double igstAmount = 0;
      double totalAmount = 0;
      
      for (final item in invoiceItems) {
        baseAmount += item.amount;
        cgstAmount += item.cgstAmount;
        sgstAmount += item.sgstAmount;
        igstAmount += item.igstAmount;
        totalAmount += item.totalAmount;
      }
      
      final invoiceDate = DateFormat(AppConstants.dateFormat).parse(invoiceDateController.text);
      
      // Check if invoice already exists
      if (currentInvoice.value != null) {
        // Update existing invoice
        final updatedInvoice = currentInvoice.value!.copyWith(
          invoiceNumber: invoiceNumberController.text,
          invoiceDate: invoiceDate,
          gateEntryId: selectedGateEntry.value!.id!,
          buyerId: selectedBuyer.value!.id!,
          baseAmount: baseAmount,
          cgstAmount: cgstAmount,
          sgstAmount: sgstAmount,
          igstAmount: igstAmount,
          totalAmount: totalAmount,
          status: status,
          remarks: remarksController.text,
          updatedAt: DateTime.now(),
          items: invoiceItems,
        );
        
        await _invoiceRepository.updateInvoice(updatedInvoice);
        
        Get.snackbar(
          'Success',
          'Invoice updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        // Create new invoice
        final newInvoice = InvoiceModel(
          invoiceNumber: invoiceNumberController.text,
          invoiceDate: invoiceDate,
          gateEntryId: selectedGateEntry.value!.id!,
          buyerId: selectedBuyer.value!.id!,
          baseAmount: baseAmount,
          cgstAmount: cgstAmount,
          sgstAmount: sgstAmount,
          igstAmount: igstAmount,
          totalAmount: totalAmount,
          status: status,
          operatorId: currentUser.id!,
          remarks: remarksController.text,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          items: invoiceItems,
        );
        
        await _invoiceRepository.insertInvoice(newInvoice);
        
        Get.snackbar(
          'Success',
          'Invoice saved successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
      
      // Refresh data
      await fetchInvoices();
      
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save invoice: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isProcessing.value = false;
    }
  }
  
  // Update invoice status
  Future<bool> updateInvoiceStatus(int id, String status) async {
    isProcessing.value = true;
    
    try {
      await _invoiceRepository.updateInvoiceStatus(id, status);
      
      Get.snackbar(
        'Success',
        'Invoice status updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      // Refresh data
      await fetchInvoices();
      
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update invoice status: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isProcessing.value = false;
    }
  }
  
  // Generate invoice PDF
  Future<String?> generateInvoicePdf(InvoiceModel invoice) async {
    isProcessing.value = true;
    
    try {
      final pdfPath = await _pdfService.generateInvoicePdf(invoice);
      
      return pdfPath;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate invoice PDF: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    } finally {
      isProcessing.value = false;
    }
  }
  
  // Clear form
  void clearForm() {
    selectedGateEntry.value = null;
    currentInvoice.value = null;
    
    sessionIdController.clear();
    vehicleNumberController.clear();
    driverNameController.clear();
    invoiceNumberController.clear();
    invoiceDateController.clear();
    remarksController.clear();
    
    if (buyers.isNotEmpty) {
      selectedBuyer.value = buyers.first;
    }
    
    invoiceItems.clear();
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
  
  // Save buyer
  Future<bool> saveBuyer() async {
    if (!buyerFormKey.currentState!.validate()) {
      return false;
    }
    
    isProcessing.value = true;
    
    try {
      final buyer = BuyerModel(
        name: buyerNameController.text,
        gstin: gstinController.text,
        address: addressController.text,
        city: cityController.text,
        state: stateController.text,
        pincode: pincodeController.text,
        contactPerson: contactPersonController.text,
        contactMobile: contactMobileController.text,
        contactEmail: contactEmailController.text,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final buyerId = await _invoiceRepository.insertBuyer(buyer);
      
      // Refresh buyers
      await fetchBuyers();
      
      // Select the newly created buyer
      final newBuyer = await _invoiceRepository.getBuyerById(buyerId);
      
      if (newBuyer != null) {
        selectedBuyer.value = newBuyer;
      }
      
      Get.snackbar(
        'Success',
        'Buyer saved successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save buyer: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isProcessing.value = false;
    }
  }
  
  // Clear buyer form
  void clearBuyerForm() {
    buyerNameController.clear();
    gstinController.clear();
    addressController.clear();
    cityController.clear();
    stateController.clear();
    pincodeController.clear();
    contactPersonController.clear();
    contactMobileController.clear();
    contactEmailController.clear();
  }
  
  // Validate invoice number
  String? validateInvoiceNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Invoice number is required';
    }
    return null;
  }
  
  // Validate invoice date
  String? validateInvoiceDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Invoice date is required';
    }
    
    try {
      DateFormat(AppConstants.dateFormat).parse(value);
    } catch (e) {
      return 'Invalid date format';
    }
    
    return null;
  }
  
  // Validate buyer name
  String? validateBuyerName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Buyer name is required';
    }
    return null;
  }
  
  // Validate GSTIN
  String? validateGstin(String? value) {
    if (value == null || value.isEmpty) {
      return null; // GSTIN is optional
    }
    
    // GSTIN format: 2 digit state code + 10 digit PAN + 1 digit entity number + 1 digit check digit + 1 digit Z
    final gstinRegex = RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$');
    
    if (!gstinRegex.hasMatch(value)) {
      return 'Invalid GSTIN format';
    }
    
    return null;
  }
  
  // Check if user can add invoices
  bool get canAddInvoices {
    return _authService.hasPermission('billing.add');
  }
  
  // Check if user can edit invoices
  bool get canEditInvoices {
    return _authService.hasPermission('billing.edit');
  }
  
  // Check if user can delete invoices
  bool get canDeleteInvoices {
    return _authService.hasPermission('billing.delete');
  }
}

