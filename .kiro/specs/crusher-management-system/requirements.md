# Requirements Document

## Introduction

The Crusher Management Software is a comprehensive offline-first desktop application built with Flutter for Windows. The system manages the complete workflow of a stone crushing operation, from material entry through weighbridge operations to billing and reporting. The application uses GetX state management and focuses on responsive design with a user-friendly interface that works seamlessly without internet connectivity.

## Requirements

### Requirement 1

**User Story:** As a crusher plant administrator, I want to configure master data for materials, suppliers, buyers, and vehicles, so that I can establish the foundational data needed for daily operations.

#### Acceptance Criteria

1. WHEN I access the Material Master module THEN the system SHALL allow me to add, edit, and delete materials with properties like name, type (Raw/Crushed/Waste), and HSN code
2. WHEN I configure Stone Size Master THEN the system SHALL allow me to define available sizes (6mm, 12mm, 40mm, etc.) and associate them with materials
3. WHEN I manage Supplier Master THEN the system SHALL store supplier details including name, contact information, GSTIN, and address
4. WHEN I manage Buyer Master THEN the system SHALL store customer details including name, contact information, GSTIN, state, and billing address
5. WHEN I configure Vehicle Master THEN the system SHALL store vehicle number, type, capacity, owner details, and driver information
6. WHEN I set Tax Configuration THEN the system SHALL allow me to configure GST percentages per material and state-wise tax rules
7. WHEN I configure Weight Unit Types THEN the system SHALL support both kilograms and tons with proper conversion handling

### Requirement 2

**User Story:** As a system administrator, I want to manage user accounts and permissions locally, so that I can control access to different modules based on user roles.

#### Acceptance Criteria

1. WHEN I create a new user THEN the system SHALL store username, password (encrypted), full name, and contact details locally
2. WHEN I assign roles THEN the system SHALL support predefined roles like Admin, Supervisor, Billing, Gate Operator, and Weighbridge Operator
3. WHEN I set role-wise permissions THEN the system SHALL control access to specific modules and functions based on assigned roles
4. WHEN a user logs in THEN the system SHALL authenticate against local credentials and create a session
5. WHEN I configure auto-logout THEN the system SHALL automatically log out users after a specified period of inactivity
6. WHEN any user action occurs THEN the system SHALL log the activity with timestamp, user ID, and action details for audit purposes

### Requirement 3

**User Story:** As a gate operator, I want to manage vehicle entry and exit with gate pass generation, so that I can track vehicle movement and maintain proper documentation.

#### Acceptance Criteria

1. WHEN a vehicle enters THEN the system SHALL record vehicle number, driver name, mobile number, entry time, tare weight, and supplier/buyer selection
2. WHEN I create a gate pass THEN the system SHALL auto-generate a unique gate pass number and allow printing with all relevant details
3. WHEN a vehicle exits THEN the system SHALL record gross weight, exit time, and calculate net weight automatically
4. WHEN I search for a vehicle THEN the system SHALL allow lookup by vehicle number or session ID
5. WHEN I need to reprint or cancel a gate pass THEN the system SHALL allow these actions with mandatory remarks
6. WHEN vehicle status changes THEN the system SHALL update status from "IN-PROCESS" → "LOADING" → "LOADED" → "DISPATCHED"
7. WHEN I generate slips THEN the system SHALL create PDF copies stored locally for viewing and printing

### Requirement 4

**User Story:** As a weighbridge operator, I want to record tare and gross weights accurately, so that I can calculate net weight and generate weigh slips.

#### Acceptance Criteria

1. WHEN I record tare weight THEN the system SHALL capture vehicle number, driver name, entry time, tare weight, operator name, and remarks
2. WHEN I record gross weight THEN the system SHALL capture vehicle number/session ID, gross weight, exit time, operator name, and remarks
3. WHEN weights are recorded THEN the system SHALL automatically calculate net weight using the formula: Net = Gross - Tare
4. WHEN I configure decimal precision THEN the system SHALL allow setting precision for weight calculations
5. WHEN I generate a weigh slip THEN the system SHALL create a PDF with all weight details and store it locally
6. WHEN I need to reprint THEN the system SHALL maintain reprint history with timestamps and operator details
7. WHEN hardware integration is available THEN the system SHALL support automatic weight capture from weighbridge equipment

### Requirement 5

**User Story:** As a loading supervisor, I want to assign materials to vehicles and confirm loading, so that I can ensure proper material allocation and track loading operations.

#### Acceptance Criteria

1. WHEN I select materials THEN the system SHALL allow me to choose from Material Master, Stone Size Master, and specify quantity in kg/tons
2. WHEN I assign material to a vehicle THEN the system SHALL validate vehicle capacity and material availability
3. WHEN I confirm loading THEN the system SHALL verify session status is "IN-PROCESS" or "LOADING" before allowing confirmation
4. WHEN loading is confirmed THEN the system SHALL lock the quantity, update session status to "LOADED", and trigger gross weight recording requirement
5. WHEN I specify the purpose THEN the system SHALL allow selection between "Sale" and "Internal Use"
6. WHEN loading is completed THEN the system SHALL store complete loading history with material details, quantities, vehicle info, operator details, and timestamps

### Requirement 6

**User Story:** As a billing operator, I want to generate invoices with automatic tax calculations, so that I can create accurate bills for customers based on material rates and applicable taxes.

#### Acceptance Criteria

1. WHEN I create an invoice THEN the system SHALL automatically fetch net weight from weighbridge data and apply configured rates per ton/kg
2. WHEN calculating taxes THEN the system SHALL apply CGST/SGST for intra-state transactions and IGST for inter-state transactions based on buyer's state
3. WHEN generating invoice format THEN the system SHALL include HSN code, buyer GSTIN, itemized billing, tax breakdown, and signature placeholder
4. WHEN I save an invoice THEN the system SHALL support status tracking: Draft, Final, or Cancelled
5. WHEN I print invoices THEN the system SHALL generate PDF copies with options for Single, Duplicate, or Triplicate with appropriate watermarks
6. WHEN invoice is finalized THEN the system SHALL store digital copies locally and update billing records

### Requirement 7

**User Story:** As a plant manager, I want to view real-time dashboards and generate comprehensive reports, so that I can monitor operations and make informed business decisions.

#### Acceptance Criteria

1. WHEN I access the dashboard THEN the system SHALL display real-time metrics including total trips, weight summaries, top buyers/suppliers, and tax summaries
2. WHEN I generate daily reports THEN the system SHALL create vehicle logs with complete trip details and weight information
3. WHEN I need buyer-wise reports THEN the system SHALL generate sales reports filtered by buyer, date range, and material type
4. WHEN I need supplier-wise reports THEN the system SHALL generate purchase reports with supplier details and material quantities
5. WHEN I generate material movement reports THEN the system SHALL show material flow with loading and dispatch details
6. WHEN I export reports THEN the system SHALL support Excel, PDF, and print-friendly formats
7. WHEN I apply filters THEN the system SHALL allow filtering by date range, vehicle, buyer, supplier, material type, and operator

### Requirement 8

**User Story:** As a system administrator, I want comprehensive security and audit capabilities, so that I can ensure data integrity and maintain compliance with operational requirements.

#### Acceptance Criteria

1. WHEN implementing access control THEN the system SHALL enforce role-based permissions for all modules and functions
2. WHEN users are inactive THEN the system SHALL automatically log them out based on configured timeout settings
3. WHEN data is transmitted locally THEN the system SHALL use encrypted communication between application components
4. WHEN any operation occurs THEN the system SHALL log gate entries, weighment data, user activities, invoice edits, and loading actions
5. WHEN configuring data retention THEN the system SHALL allow setting policies for log retention and automatic cleanup
6. WHEN audit trails are needed THEN the system SHALL provide comprehensive logs with timestamps, user identification, and action details
7. WHEN system security is evaluated THEN the system SHALL store all sensitive data with appropriate encryption

### Requirement 9

**User Story:** As an end user, I want a responsive and intuitive interface optimized for Windows desktop, so that I can efficiently perform my tasks regardless of screen size or resolution.

#### Acceptance Criteria

1. WHEN I use the application on different screen sizes THEN the system SHALL adapt the layout responsively while maintaining usability
2. WHEN I navigate between modules THEN the system SHALL provide clear navigation with consistent UI patterns
3. WHEN I perform data entry THEN the system SHALL provide form validation, auto-complete, and helpful error messages
4. WHEN I use keyboard shortcuts THEN the system SHALL support common shortcuts for faster data entry and navigation
5. WHEN I work with large datasets THEN the system SHALL implement pagination, search, and filtering capabilities
6. WHEN the system loads THEN the system SHALL provide loading indicators and progress feedback for better user experience
7. WHEN I need help THEN the system SHALL provide contextual help and tooltips for complex operations