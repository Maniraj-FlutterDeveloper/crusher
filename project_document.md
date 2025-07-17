Crusher Management Software – Offline Features Document

This document outlines the core features and modules of the Crusher Management Software that can be used offline, ensuring seamless operations even without an internet connection. These features are designed to support local data entry, processing, and reporting.

-----

### **1. Master Configuration (Offline)**

*Purpose: To set foundational data before operational use.*

  * **Material Master**
      * Add/Edit/Delete materials (e.g., Blue Metal, M-Sand)
  * **Stone Size Master**
      * Define available sizes (e.g., 6mm, 12mm, 40mm)
  * **Material Type Master**
      * Raw / Crushed / Waste
  * **Weight Unit Type**
      * Kilograms ($kg$) / Tons
  * **Supplier Master**
      * Add supplier data for raw material sourcing
  * **Buyer Master**
      * Manage customer details for billing & tax
  * **Vehicle Master**
      * Manage Vehicle No, Type, Capacity, and Owner
  * **Tax Configuration**
      * Set GST percentage ($GST,%$) per material

✅ **All master data can be managed offline and referenced in transaction modules using foreign keys.**

-----

### **2. User Management (Offline)**

*Purpose: To manage application users and secure access locally.*

  * **Create/Edit/Delete Users**
  * **Assign Roles** (Admin, Supervisor, Billing, etc.)
  * **Set Role-wise Permissions** (Menu/module access)
  * **Log User Activities** for audit trails

✅ **User management functions work offline with local authentication and session handling.**

-----

### **3. Gate Entry Module (Offline)**

*Purpose: To manage vehicle IN/OUT entries, generate gate passes, and track vehicle status.*

  * **A. Vehicle In (Tare Weight Entry)**

      * **Capture:** Vehicle Number (from local database), Driver Name & Mobile
      * **Time:** Entry Time (auto-generated)
      * **Weight:** Tare Weight (manual or via weighbridge)
      * **Details:** Supplier/Buyer selection, Remarks & optional file upload

  * **B. Gate Pass Creation**

      * Auto-generate gate pass number
      * Print gate pass
      * Reprint or cancel with remarks
      * Save a digital copy locally

  * **C. Vehicle Out (Gross Weight Entry)**

      * Search by Vehicle Number or Session ID
      * Record Gross Weight (manual or from weighbridge)
      * Record Exit Time (auto-generated)
      * Calculate Net Weight: $Gross – Tare$
      * Update vehicle status to "DISPATCHED"

  * **D. Slip/Print Format**

      * Generate weigh slip and gate pass
      * Store as PDF locally for viewing or future printing

✅ **The full gate entry process works offline, including status tracking. Status Flow: "IN-PROCESS" → "LOADING" → "LOADED" → "DISPATCHED".**

-----

### **4. Weighbridge Module (Offline)**

*Purpose: To record and manage tare and gross weights locally.*

  * **A. Record Tare Weight**
      * **Input Fields:** Vehicle Number, Driver Name, Entry Time, Tare Weight, Operator Name, Remarks
  * **B. Record Gross Weight**
      * **Input Fields:** Vehicle Number or Session ID, Gross Weight, Exit Time, Operator Name, Remarks
  * **C. Calculate Net Weight**
      * Formula: $Net = Gross – Tare$
      * Configure decimal precision
      * Store all values locally
  * **D. Print Weigh Slip**
      * Generate a PDF weigh slip
      * Store locally for printing
      * Track reprint history

✅ **Weighbridge data can be entered manually or fetched via hardware integration. This module works fully offline.**

-----

### **5. Material Loading Module (Offline)**

*Purpose: To assign material to vehicles and confirm the loading process.*

  * **A. Select Material, Size, and Quantity**
      * Pull data from Material Master and Stone Size Master
      * Choose unit ($kg/ton$)
  * **B. Assign to Vehicle**
      * Lookup vehicle from the local database
      * Select buyer/supplier and enter the driver's name
      * Choose purpose: Sale or Internal Use
  * **C. Confirm Loading**
      * **Validate:** Vehicle capacity and material availability (if stock module is enabled)
      * **Check:** Session status must be “IN-PROCESS” or “LOADING”
      * Lock quantity after confirmation
      * Mark session as "LOADED" to trigger gross weight recording
  * **D. Store Loading History**
      * Store records including Material type and size, Quantity loaded, Vehicle and session ID, Operator info, and timestamp.

✅ **The entire loading process operates offline with full validation and traceability.**

-----

### **6. Billing Module (Offline)**

*Purpose: To generate invoices and calculate taxes locally.*

  * **A. Auto-Billing Based on Material, Weight, & Rate**
      * Fetch net weight from the weighbridge module
      * Apply the configured rate per ton/kg
      * Compute the base amount automatically
  * **B. Tax Calculation (GST)**
      * Apply CGST/SGST or IGST based on the buyer's state (stored locally)
      * Store the tax breakup for future reports
  * **C. Invoice Format**
      * Auto-generate an invoice with HSN code, Buyer GSTIN, tax breakdown, and an authorized signature placeholder.
      * Save invoice status: Draft / Final / Cancelled
  * **D. Print Invoice (Single/Duplicate/Triplicate)**
      * Generate a printable PDF
      * Watermark each copy accordingly
      * Store digital copies locally

✅ **Billing and tax calculations are fully functional offline. Only final ePass generation and GST filing require online access.**

-----

### **7. Reports & Dashboard (Offline)**

*Purpose: To provide real-time insights and historical reports using local data.*

  * **A. Real-Time Dashboard**
      * Total Trips
      * Weight Summary (Tare, Gross, Net)
      * Top Buyers/Suppliers
      * Tax Summary
  * **B. Exportable Reports (Offline)**
      * Daily Vehicle Logs
      * Buyer-wise Sales Reports
      * Supplier-wise Purchase Reports
      * Material Movement Reports
      * ePass Summary (based on locally generated data)
      * Tax Reports (based on stored billing data)

✅ **Reporting works offline with filters (date, vehicle, buyer, etc.) and offers multiple export options: Excel, PDF, and a Print-friendly layout.**

-----

### **8. Security & Audit (Offline)**

*Purpose: To maintain logs, enforce security, and ensure compliance locally.*

  * **Role-Based Access Control (RBAC)**
  * **Auto Logout Configuration**
  * **Encrypted Local Communication**
  * **Comprehensive Logs:**
      * Gate Entries
      * Weighment Data
      * User Activity
      * Invoice Edits
      * Loading Actions

✅ **Full logging and access control are supported offline with configurable data retention policies.**