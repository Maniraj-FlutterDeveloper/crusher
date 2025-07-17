class AppConstants {
  // App info
  static const String appName = 'Crusher Management System';
  static const String appVersion = '1.0.0';
  
  // Storage keys
  static const String storageUserKey = 'user';
  static const String storageThemeKey = 'theme';
  static const String storageLanguageKey = 'language';
  
  // Date formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  
  // Vehicle status
  static const String vehicleStatusInProcess = 'IN-PROCESS';
  static const String vehicleStatusLoading = 'LOADING';
  static const String vehicleStatusLoaded = 'LOADED';
  static const String vehicleStatusDispatched = 'DISPATCHED';
  
  // Material types
  static const String materialTypeRaw = 'RAW';
  static const String materialTypeCrushed = 'CRUSHED';
  static const String materialTypeWaste = 'WASTE';
  
  // Invoice status
  static const String invoiceStatusDraft = 'DRAFT';
  static const String invoiceStatusFinal = 'FINAL';
  static const String invoiceStatusCancelled = 'CANCELLED';
  
  // User roles
  static const String roleAdmin = 'ADMIN';
  static const String roleSupervisor = 'SUPERVISOR';
  static const String roleBilling = 'BILLING';
  static const String roleOperator = 'OPERATOR';
  
  // Pagination
  static const int defaultPageSize = 10;
  static const List<int> availablePageSizes = [10, 20, 50, 100];
  
  // API endpoints (for future online sync)
  static const String baseUrl = 'https://api.example.com';
  static const String apiVersion = 'v1';
  
  // Timeout durations
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  
  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);
  
  // Database
  static const String databaseName = 'crusher_management.db';
  static const int databaseVersion = 1;
  
  // Default values
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  static const double defaultElevation = 2.0;
}

