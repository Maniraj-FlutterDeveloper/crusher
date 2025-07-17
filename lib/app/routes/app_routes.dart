abstract class Routes {
  // Auth routes
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  
  // Main routes
  static const HOME = '/home';
  static const DASHBOARD = '/dashboard';
  
  // Master configuration routes
  static const MATERIAL_MASTER = '/material-master';
  static const STONE_SIZE_MASTER = '/stone-size-master';
  static const MATERIAL_TYPE_MASTER = '/material-type-master';
  static const WEIGHT_UNIT_MASTER = '/weight-unit-master';
  static const SUPPLIER_MASTER = '/supplier-master';
  static const BUYER_MASTER = '/buyer-master';
  static const VEHICLE_MASTER = '/vehicle-master';
  static const TAX_CONFIGURATION = '/tax-configuration';
  
  // User management routes
  static const USER_MANAGEMENT = '/user-management';
  static const USER_FORM = '/user-form';
  static const ROLE_MANAGEMENT = '/role-management';
  static const PERMISSION_MANAGEMENT = '/permission-management';
  
  // Gate entry routes
  static const GATE_ENTRY = '/gate-entry';
  static const VEHICLE_IN = '/vehicle-in';
  static const VEHICLE_OUT = '/vehicle-out';
  static const GATE_PASS = '/gate-pass';
  
  // Weighbridge routes
  static const WEIGHBRIDGE = '/weighbridge';
  static const TARE_WEIGHT = '/tare-weight';
  static const GROSS_WEIGHT = '/gross-weight';
  static const WEIGH_SLIP = '/weigh-slip';
  
  // Material loading routes
  static const MATERIAL_LOADING = '/material-loading';
  static const LOADING_CONFIRMATION = '/loading-confirmation';
  
  // Billing routes
  static const BILLING = '/billing';
  static const INVOICE_GENERATION = '/invoice-generation';
  static const INVOICE_VIEW = '/invoice-view';
  
  // Reports routes
  static const REPORTS = '/reports';
  static const DAILY_VEHICLE_LOGS = '/daily-vehicle-logs';
  static const BUYER_SALES_REPORTS = '/buyer-sales-reports';
  static const SUPPLIER_PURCHASE_REPORTS = '/supplier-purchase-reports';
  static const MATERIAL_MOVEMENT_REPORTS = '/material-movement-reports';
  static const EPASS_SUMMARY = '/epass-summary';
  static const TAX_REPORTS = '/tax-reports';
  
  // Security and audit routes
  static const SECURITY_SETTINGS = '/security-settings';
  static const AUDIT_LOGS = '/audit-logs';
}

