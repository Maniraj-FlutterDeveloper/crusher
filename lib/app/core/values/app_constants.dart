class AppConstants {
  // App info
  static const String appName = 'Crusher Management System';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String dbName = 'crusher_management.db';
  static const int dbVersion = 1;
  
  // Storage keys
  static const String storageUserKey = 'user';
  static const String storageTokenKey = 'token';
  static const String storageThemeModeKey = 'theme_mode';
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  
  // Date formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm:ss';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm:ss';
  
  // Vehicle status
  static const String vehicleStatusInProcess = 'IN-PROCESS';
  static const String vehicleStatusLoading = 'LOADING';
  static const String vehicleStatusLoaded = 'LOADED';
  static const String vehicleStatusDispatched = 'DISPATCHED';
  
  // Invoice status
  static const String invoiceStatusDraft = 'DRAFT';
  static const String invoiceStatusFinal = 'FINAL';
  static const String invoiceStatusCancelled = 'CANCELLED';
  
  // Material types
  static const String materialTypeRaw = 'RAW';
  static const String materialTypeCrushed = 'CRUSHED';
  static const String materialTypeWaste = 'WASTE';
  
  // Weight units
  static const String weightUnitKg = 'KG';
  static const String weightUnitTon = 'TON';
  
  // Loading purpose
  static const String loadingPurposeSale = 'SALE';
  static const String loadingPurposeInternalUse = 'INTERNAL_USE';
  
  // User roles
  static const String roleAdmin = 'ADMIN';
  static const String roleSupervisor = 'SUPERVISOR';
  static const String roleBilling = 'BILLING';
  static const String roleOperator = 'OPERATOR';
  
  // Responsive breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
}

