# Design Document

## Overview

The Crusher Management Software is designed as a comprehensive offline-first desktop application using Flutter with GetX state management. The system follows a modular architecture with clear separation of concerns, ensuring maintainability and scalability. The application is optimized for Windows desktop environments with responsive design principles and focuses on providing an intuitive user experience for industrial operations.

## Architecture

### High-Level Architecture

The application follows a layered architecture pattern:

```
┌─────────────────────────────────────────┐
│           Presentation Layer            │
│  (UI Screens, Widgets, Controllers)     │
├─────────────────────────────────────────┤
│            Business Layer               │
│     (Services, Use Cases, Logic)        │
├─────────────────────────────────────────┤
│             Data Layer                  │
│  (Repositories, Models, Local Storage)  │
├─────────────────────────────────────────┤
│          Infrastructure Layer           │
│   (Database, File System, Hardware)     │
└─────────────────────────────────────────┘
```

### Technology Stack

- **Framework**: Flutter 3.8.1+ for cross-platform desktop development
- **State Management**: GetX for reactive state management and dependency injection
- **Local Database**: SQLite with sqflite package for offline data persistence
- **PDF Generation**: pdf package for generating invoices and reports
- **File Storage**: path_provider for local file management
- **UI Framework**: Material Design 3 with custom theming for professional appearance
- **Architecture Pattern**: Clean Architecture with Repository pattern

## Components and Interfaces

### Core Components

#### 1. Authentication System
```dart
class AuthController extends GetxController {
  // User session management
  // Role-based access control
  // Auto-logout functionality
}

class User {
  String id;
  String username;
  String fullName;
  UserRole role;
  List<Permission> permissions;
}
```

#### 2. Master Data Management
```dart
class MasterDataController extends GetxController {
  // Material, Supplier, Buyer, Vehicle management
  // CRUD operations with local storage
}

class Material {
  String id;
  String name;
  MaterialType type; // Raw/Crushed/Waste
  String hsnCode;
  List<StoneSize> availableSizes;
}
```

#### 3. Gate Entry System
```dart
class GateEntryController extends GetxController {
  // Vehicle entry/exit management
  // Gate pass generation
  // Status tracking
}

class VehicleSession {
  String sessionId;
  String vehicleNumber;
  VehicleStatus status;
  DateTime entryTime;
  DateTime? exitTime;
  double? tareWeight;
  double? grossWeight;
}
```

#### 4. Weighbridge Integration
```dart
class WeighbridgeController extends GetxController {
  // Weight recording and calculation
  // Hardware integration support
  // Slip generation
}

class WeightRecord {
  String id;
  String sessionId;
  double tareWeight;
  double grossWeight;
  double netWeight;
  DateTime timestamp;
}
```

#### 5. Material Loading System
```dart
class LoadingController extends GetxController {
  // Material assignment
  // Loading confirmation
  // Capacity validation
}

class LoadingRecord {
  String id;
  String sessionId;
  Material material;
  StoneSize size;
  double quantity;
  WeightUnit unit;
  LoadingPurpose purpose;
}
```

#### 6. Billing Engine
```dart
class BillingController extends GetxController {
  // Invoice generation
  // Tax calculations
  // Rate management
}

class Invoice {
  String invoiceNumber;
  Customer buyer;
  List<InvoiceItem> items;
  TaxBreakdown taxes;
  InvoiceStatus status;
  DateTime createdAt;
}
```

### Data Models

#### Core Entities
```dart
// Master Data Models
class Material {
  String id;
  String name;
  MaterialType type;
  String hsnCode;
  double ratePerTon;
  double gstPercentage;
}

class Supplier {
  String id;
  String name;
  String contactPerson;
  String mobile;
  String gstin;
  Address address;
}

class Vehicle {
  String id;
  String vehicleNumber;
  VehicleType type;
  double capacity;
  String ownerName;
  String driverName;
  String driverMobile;
}

// Transaction Models
class VehicleSession {
  String sessionId;
  String vehicleId;
  String supplierId;
  String buyerId;
  VehicleStatus status;
  DateTime entryTime;
  DateTime? exitTime;
  WeightRecord? weights;
  List<LoadingRecord> loadings;
}

class WeightRecord {
  double tareWeight;
  double grossWeight;
  double netWeight;
  DateTime tareTime;
  DateTime grossTime;
  String operatorId;
}
```

### Repository Pattern Implementation

```dart
abstract class Repository<T> {
  Future<List<T>> getAll();
  Future<T?> getById(String id);
  Future<String> create(T entity);
  Future<bool> update(T entity);
  Future<bool> delete(String id);
}

class MaterialRepository extends Repository<Material> {
  final DatabaseHelper _db;
  // Implementation with SQLite operations
}
```

## Data Models

### Database Schema Design

#### Master Tables
```sql
-- Users and Authentication
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  full_name TEXT NOT NULL,
  role TEXT NOT NULL,
  permissions TEXT, -- JSON array
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  is_active BOOLEAN DEFAULT 1
);

-- Materials Master
CREATE TABLE materials (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  type TEXT NOT NULL, -- Raw/Crushed/Waste
  hsn_code TEXT,
  rate_per_ton REAL DEFAULT 0,
  gst_percentage REAL DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Stone Sizes
CREATE TABLE stone_sizes (
  id TEXT PRIMARY KEY,
  size_name TEXT NOT NULL, -- 6mm, 12mm, etc.
  material_id TEXT,
  FOREIGN KEY (material_id) REFERENCES materials(id)
);

-- Suppliers
CREATE TABLE suppliers (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  contact_person TEXT,
  mobile TEXT,
  email TEXT,
  gstin TEXT,
  address TEXT,
  state TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Buyers/Customers
CREATE TABLE buyers (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  contact_person TEXT,
  mobile TEXT,
  email TEXT,
  gstin TEXT,
  billing_address TEXT,
  state TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Vehicles
CREATE TABLE vehicles (
  id TEXT PRIMARY KEY,
  vehicle_number TEXT UNIQUE NOT NULL,
  vehicle_type TEXT,
  capacity REAL,
  owner_name TEXT,
  driver_name TEXT,
  driver_mobile TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

#### Transaction Tables
```sql
-- Vehicle Sessions
CREATE TABLE vehicle_sessions (
  session_id TEXT PRIMARY KEY,
  vehicle_id TEXT NOT NULL,
  supplier_id TEXT,
  buyer_id TEXT,
  status TEXT NOT NULL, -- IN-PROCESS/LOADING/LOADED/DISPATCHED
  entry_time DATETIME NOT NULL,
  exit_time DATETIME,
  gate_pass_number TEXT,
  remarks TEXT,
  created_by TEXT,
  FOREIGN KEY (vehicle_id) REFERENCES vehicles(id),
  FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
  FOREIGN KEY (buyer_id) REFERENCES buyers(id)
);

-- Weight Records
CREATE TABLE weight_records (
  id TEXT PRIMARY KEY,
  session_id TEXT NOT NULL,
  tare_weight REAL,
  gross_weight REAL,
  net_weight REAL,
  tare_time DATETIME,
  gross_time DATETIME,
  operator_id TEXT,
  remarks TEXT,
  FOREIGN KEY (session_id) REFERENCES vehicle_sessions(session_id)
);

-- Loading Records
CREATE TABLE loading_records (
  id TEXT PRIMARY KEY,
  session_id TEXT NOT NULL,
  material_id TEXT NOT NULL,
  stone_size_id TEXT,
  quantity REAL NOT NULL,
  unit TEXT NOT NULL, -- kg/ton
  purpose TEXT NOT NULL, -- Sale/Internal
  confirmed_at DATETIME,
  operator_id TEXT,
  FOREIGN KEY (session_id) REFERENCES vehicle_sessions(session_id),
  FOREIGN KEY (material_id) REFERENCES materials(id)
);

-- Invoices
CREATE TABLE invoices (
  invoice_number TEXT PRIMARY KEY,
  session_id TEXT NOT NULL,
  buyer_id TEXT NOT NULL,
  invoice_date DATETIME NOT NULL,
  total_amount REAL NOT NULL,
  tax_amount REAL NOT NULL,
  grand_total REAL NOT NULL,
  status TEXT NOT NULL, -- Draft/Final/Cancelled
  created_by TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (session_id) REFERENCES vehicle_sessions(session_id),
  FOREIGN KEY (buyer_id) REFERENCES buyers(id)
);
```

### State Management Architecture

#### GetX Controller Structure
```dart
// Base Controller with common functionality
abstract class BaseController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  
  void showLoading() => isLoading.value = true;
  void hideLoading() => isLoading.value = false;
  void setError(String message) => errorMessage.value = message;
  void clearError() => errorMessage.value = '';
}

// Main App Controller
class AppController extends BaseController {
  final currentUser = Rxn<User>();
  final selectedModule = ModuleType.dashboard.obs;
  
  void navigateToModule(ModuleType module) {
    selectedModule.value = module;
  }
}
```

## Error Handling

### Error Handling Strategy

#### 1. Database Errors
```dart
class DatabaseException implements Exception {
  final String message;
  final String? code;
  DatabaseException(this.message, [this.code]);
}

class ErrorHandler {
  static void handleDatabaseError(dynamic error) {
    if (error is DatabaseException) {
      // Log error and show user-friendly message
      Get.snackbar('Database Error', error.message);
    }
  }
}
```

#### 2. Validation Errors
```dart
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  
  ValidationResult(this.isValid, this.errors);
}

class Validator {
  static ValidationResult validateVehicleNumber(String number) {
    // Validation logic
  }
  
  static ValidationResult validateWeight(double weight) {
    // Weight validation logic
  }
}
```

#### 3. Business Logic Errors
```dart
class BusinessException implements Exception {
  final String message;
  final BusinessErrorType type;
  
  BusinessException(this.message, this.type);
}

enum BusinessErrorType {
  vehicleAlreadyInProcess,
  insufficientMaterialStock,
  invalidWeightEntry,
  sessionNotFound
}
```

## Testing Strategy

### Testing Pyramid

#### 1. Unit Tests
- Model validation and business logic
- Repository operations
- Controller state management
- Utility functions and calculations

#### 2. Widget Tests
- Individual screen components
- Form validation
- Navigation flows
- Responsive layout behavior

#### 3. Integration Tests
- Database operations
- Complete user workflows
- PDF generation
- Report generation

### Test Structure
```dart
// Unit Test Example
class MaterialRepositoryTest {
  late MaterialRepository repository;
  late MockDatabaseHelper mockDb;
  
  setUp() {
    mockDb = MockDatabaseHelper();
    repository = MaterialRepository(mockDb);
  }
  
  test('should create material successfully', () async {
    // Test implementation
  });
}

// Widget Test Example
class MaterialFormTest {
  testWidgets('should validate required fields', (tester) async {
    // Widget test implementation
  });
}
```

## UI/UX Design Principles

### Design System

#### 1. Color Palette
```dart
class AppColors {
  static const primary = Color(0xFF1976D2);
  static const secondary = Color(0xFF424242);
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFF9800);
  static const error = Color(0xFFE53935);
  static const background = Color(0xFFF5F5F5);
  static const surface = Color(0xFFFFFFFF);
}
```

#### 2. Typography
```dart
class AppTextStyles {
  static const heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );
  
  static const body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.secondary,
  );
}
```

#### 3. Responsive Layout
```dart
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;
  
  // Responsive breakpoints:
  // Mobile: < 600px
  // Tablet: 600px - 1200px
  // Desktop: > 1200px
}
```

### Navigation Structure

#### Main Navigation
```
Dashboard
├── Master Data
│   ├── Materials
│   ├── Suppliers
│   ├── Buyers
│   ├── Vehicles
│   └── Tax Configuration
├── Operations
│   ├── Gate Entry
│   ├── Weighbridge
│   ├── Material Loading
│   └── Vehicle Tracking
├── Billing
│   ├── Invoice Generation
│   ├── Tax Reports
│   └── Payment Tracking
├── Reports
│   ├── Daily Reports
│   ├── Material Reports
│   ├── Vehicle Reports
│   └── Financial Reports
└── Administration
    ├── User Management
    ├── System Settings
    └── Audit Logs
```

### Screen Layouts

#### 1. Dashboard Layout
- Key metrics cards (4-6 cards in responsive grid)
- Recent activities list
- Quick action buttons
- Real-time status indicators

#### 2. Master Data Screens
- Data table with search and filter
- Add/Edit forms in modal dialogs
- Bulk import/export functionality
- Validation feedback

#### 3. Transaction Screens
- Step-by-step workflow
- Progress indicators
- Real-time validation
- Print/export options

## Performance Considerations

### Optimization Strategies

#### 1. Database Optimization
- Proper indexing on frequently queried columns
- Connection pooling for database operations
- Batch operations for bulk data processing
- Regular database maintenance and cleanup

#### 2. UI Performance
- Lazy loading for large datasets
- Virtual scrolling for long lists
- Image optimization and caching
- Efficient state management with GetX

#### 3. Memory Management
- Proper disposal of controllers and streams
- Image memory optimization
- Background task management
- Cache management for frequently accessed data

## Security Considerations

### Data Security
- Local database encryption using SQLCipher
- Secure password hashing with bcrypt
- Session management with secure tokens
- Audit logging for all critical operations

### Access Control
- Role-based permission system
- Module-level access restrictions
- Function-level security checks
- Auto-logout for inactive sessions

## Deployment and Distribution

### Windows Desktop Deployment
- MSI installer package creation
- Auto-update mechanism
- System requirements validation
- Installation and configuration wizard

### File Structure
```
crusher_management/
├── data/
│   ├── database/
│   ├── reports/
│   ├── invoices/
│   └── backups/
├── config/
│   ├── app_settings.json
│   └── user_preferences.json
└── logs/
    ├── application.log
    ├── error.log
    └── audit.log
```