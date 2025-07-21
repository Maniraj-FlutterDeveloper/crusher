import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../error/error_handler.dart';
import 'logger_service.dart';
import '../../data/models/sync_item_model.dart';
import '../../data/repositories/sync_repository.dart';

class SyncService extends GetxService {
  final LoggerService _logger = Get.find<LoggerService>();
  final ErrorHandler _errorHandler = Get.find<ErrorHandler>();
  final SyncRepository _syncRepository = Get.find<SyncRepository>();
  final Connectivity _connectivity = Connectivity();

  // Observable properties
  final RxBool isOnline = false.obs;
  final RxBool isSyncing = false.obs;
  final RxInt pendingSyncItems = 0.obs;
  final RxDouble syncProgress = 0.0.obs;
  final RxString currentSyncStatus = ''.obs;

  // Stream subscriptions
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  Timer? _syncTimer;

  // Sync configuration
  final int _syncIntervalMinutes;
  final bool _autoSync;

  SyncService({
    int syncIntervalMinutes = 15,
    bool autoSync = true,
  })  : _syncIntervalMinutes = syncIntervalMinutes,
        _autoSync = autoSync;

  /// Initialize the sync service
  Future<SyncService> init() async {
    _logger.info('Initializing SyncService');

    // Check initial connectivity
    await _checkConnectivity();

    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
      _handleConnectivityChange(result);
    });

    // Start sync timer if auto sync is enabled
    if (_autoSync) {
      _startSyncTimer();
    }

    // Load pending sync items count
    await _loadPendingSyncCount();

    return this;
  }

  /// Dispose resources
  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
    super.onClose();
  }

  /// Check current connectivity
  Future<void> _checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _handleConnectivityChange(result);
    } catch (e) {
      _logger.error('Failed to check connectivity', e);
      isOnline.value = false;
    }
  }

  /// Handle connectivity change
  void _handleConnectivityChange(ConnectivityResult result) {
    final wasOnline = isOnline.value;
    isOnline.value = result != ConnectivityResult.none;

    _logger.info('Connectivity changed: $result, isOnline: \${isOnline.value}');

    // If we just came online and auto sync is enabled, trigger a sync
    if (!wasOnline && isOnline.value && _autoSync) {
      _logger.info('Connection restored, triggering sync');
      syncData();
    }
  }

  /// Start the sync timer
  void _startSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(
      Duration(minutes: _syncIntervalMinutes),
      (_) {
        if (isOnline.value) {
          syncData();
        }
      },
    );
    _logger.info('Sync timer started with interval of $_syncIntervalMinutes minutes');
  }

  /// Load the count of pending sync items
  Future<void> _loadPendingSyncCount() async {
    try {
      final count = await _syncRepository.getPendingSyncItemsCount();
      pendingSyncItems.value = count;
      _logger.info('Pending sync items: $count');
    } catch (e) {
      _logger.error('Failed to load pending sync count', e);
    }
  }

  /// Add an item to the sync queue
  Future<void> addToSyncQueue({
    required String entityType,
    required String action,
    required Map<String, dynamic> data,
    required String entityId,
    int priority = 1,
  }) async {
    try {
      final syncItem = SyncItemModel(
        entityType: entityType,
        entityId: entityId,
        action: action,
        data: data,
        status: SyncStatus.pending,
        priority: priority,
        createdAt: DateTime.now(),
        attempts: 0,
      );

      await _syncRepository.addSyncItem(syncItem);
      await _loadPendingSyncCount();

      _logger.info('Added item to sync queue: \${syncItem.entityType}/\${syncItem.entityId}');

      // If we're online and auto sync is enabled, trigger a sync
      if (isOnline.value && _autoSync) {
        syncData();
      }
    } catch (e, stackTrace) {
      final error = await _errorHandler.handleError(e, stackTrace);
      _logger.error('Failed to add item to sync queue', error);
    }
  }

  /// Synchronize data with the server
  Future<bool> syncData() async {
    // If already syncing, don't start another sync
    if (isSyncing.value) {
      _logger.info('Sync already in progress, skipping');
      return false;
    }

    // If offline, don't sync
    if (!isOnline.value) {
      _logger.info('Offline, skipping sync');
      return false;
    }

    isSyncing.value = true;
    syncProgress.value = 0.0;
    currentSyncStatus.value = 'Starting sync...';

    try {
      _logger.info('Starting data synchronization');

      // Get pending sync items
      final items = await _syncRepository.getPendingSyncItems();

      if (items.isEmpty) {
        _logger.info('No pending sync items');
        currentSyncStatus.value = 'No pending items to sync';
        isSyncing.value = false;
        return true;
      }

      _logger.info('Found \${items.length} pending sync items');
      currentSyncStatus.value = 'Syncing \${items.length} items...';

      // Sort items by priority (higher priority first)
      items.sort((a, b) => b.priority.compareTo(a.priority));

      // Process items
      int processed = 0;
      int successful = 0;

      for (final item in items) {
        try {
          currentSyncStatus.value = 'Syncing \${item.entityType}/\${item.entityId}...';

          // Process the sync item based on entity type and action
          final success = await _processSyncItem(item);

          if (success) {
            // Mark as synced
            await _syncRepository.markAsSynced(item.id!);
            successful++;
          } else {
            // Increment attempt count
            await _syncRepository.incrementAttemptCount(item.id!);

            // If max attempts reached, mark as failed
            if (item.attempts >= 5) {
              await _syncRepository.markAsFailed(item.id!);
            }
          }
        } catch (e) {
          _logger.error('Error syncing item \${item.id}', e);
          await _syncRepository.incrementAttemptCount(item.id!);

          // If max attempts reached, mark as failed
          if (item.attempts >= 5) {
            await _syncRepository.markAsFailed(item.id!);
          }
        }

        processed++;
        syncProgress.value = processed / items.length;
      }

      // Update pending count
      await _loadPendingSyncCount();

      currentSyncStatus.value = 'Sync completed: $successful/\${items.length} items synced';
      _logger.info('Sync completed: $successful/\${items.length} items synced');

      return successful == items.length;
    } catch (e, stackTrace) {
      final error = await _errorHandler.handleError(e, stackTrace);
      _logger.error('Sync failed', error);
      currentSyncStatus.value = 'Sync failed: \${error.message}';
      return false;
    } finally {
      isSyncing.value = false;
    }
  }

  /// Process a sync item based on entity type and action
  Future<bool> _processSyncItem(SyncItemModel item) async {
    _logger.info('Processing sync item: \${item.entityType}/\${item.action}');

    // Implement the sync logic for each entity type and action
    switch (item.entityType) {
      case 'vehicle':
        return await _syncVehicle(item);
      case 'material':
        return await _syncMaterial(item);
      case 'supplier':
        return await _syncSupplier(item);
      case 'buyer':
        return await _syncBuyer(item);
      case 'gate_entry':
        return await _syncGateEntry(item);
      case 'weighbridge':
        return await _syncWeighbridge(item);
      case 'material_loading':
        return await _syncMaterialLoading(item);
      case 'invoice':
        return await _syncInvoice(item);
      default:
        _logger.warning('Unknown entity type: \${item.entityType}');
        return false;
    }
  }

  /// Sync vehicle data
  Future<bool> _syncVehicle(SyncItemModel item) async {
    // Implement vehicle sync logic
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
    return true;
  }

  /// Sync material data
  Future<bool> _syncMaterial(SyncItemModel item) async {
    // Implement material sync logic
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
    return true;
  }

  /// Sync supplier data
  Future<bool> _syncSupplier(SyncItemModel item) async {
    // Implement supplier sync logic
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
    return true;
  }

  /// Sync buyer data
  Future<bool> _syncBuyer(SyncItemModel item) async {
    // Implement buyer sync logic
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
    return true;
  }

  /// Sync gate entry data
  Future<bool> _syncGateEntry(SyncItemModel item) async {
    // Implement gate entry sync logic
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
    return true;
  }

  /// Sync weighbridge data
  Future<bool> _syncWeighbridge(SyncItemModel item) async {
    // Implement weighbridge sync logic
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
    return true;
  }

  /// Sync material loading data
  Future<bool> _syncMaterialLoading(SyncItemModel item) async {
    // Implement material loading sync logic
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
    return true;
  }

  /// Sync invoice data
  Future<bool> _syncInvoice(SyncItemModel item) async {
    // Implement invoice sync logic
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
    return true;
  }

  /// Export sync data to a file
  Future<String?> exportSyncData() async {
    try {
      _logger.info('Exporting sync data');

      // Get all sync items
      final items = await _syncRepository.getAllSyncItems();

      if (items.isEmpty) {
        _logger.info('No sync items to export');
        return null;
      }

      // Convert to JSON
      final jsonData = jsonEncode(items.map((e) => e.toJson()).toList());

      // Save to file
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = 'sync_export_$timestamp.json';

      final file = File(filePath);
      await file.writeAsString(jsonData);

      _logger.info('Sync data exported to $filePath');
      return filePath;
    } catch (e, stackTrace) {
      final error = await _errorHandler.handleError(e, stackTrace);
      _logger.error('Failed to export sync data', error);
      return null;
    }
  }

  /// Import sync data from a file
  Future<bool> importSyncData(String filePath) async {
    try {
      _logger.info('Importing sync data from $filePath');

      // Read file
      final file = File(filePath);
      final jsonData = await file.readAsString();

      // Parse JSON
      final List<dynamic> itemsJson = jsonDecode(jsonData);
      final items = itemsJson.map((e) => SyncItemModel.fromJson(e)).toList();

      if (items.isEmpty) {
        _logger.info('No sync items to import');
        return false;
      }

      // Import items
      for (final item in items) {
        await _syncRepository.addSyncItem(item);
      }

      // Update pending count
      await _loadPendingSyncCount();

      _logger.info('Imported \${items.length} sync items');
      return true;
    } catch (e, stackTrace) {
      final error = await _errorHandler.handleError(e, stackTrace);
      _logger.error('Failed to import sync data', error);
      return false;
    }
  }

  /// Clear all sync data
  Future<bool> clearSyncData() async {
    try {
      _logger.info('Clearing sync data');

      await _syncRepository.clearAllSyncItems();
      await _loadPendingSyncCount();

      _logger.info('Sync data cleared');
      return true;
    } catch (e, stackTrace) {
      final error = await _errorHandler.handleError(e, stackTrace);
      _logger.error('Failed to clear sync data', error);
      return false;
    }
  }

  /// Get sync statistics
  Future<Map<String, dynamic>> getSyncStats() async {
    try {
      final pending = await _syncRepository.getPendingSyncItemsCount();
      final synced = await _syncRepository.getSyncedItemsCount();
      final failed = await _syncRepository.getFailedItemsCount();
      final total = pending + synced + failed;

      final entityStats = await _syncRepository.getEntityTypeStats();

      return {
        'pending': pending,
        'synced': synced,
        'failed': failed,
        'total': total,
        'entityStats': entityStats,
        'lastSyncAttempt': await _syncRepository.getLastSyncAttempt(),
        'lastSuccessfulSync': await _syncRepository.getLastSuccessfulSync(),
      };
    } catch (e) {
      _logger.error('Failed to get sync stats', e);
      return {
        'pending': 0,
        'synced': 0,
        'failed': 0,
        'total': 0,
        'entityStats': {},
        'lastSyncAttempt': null,
        'lastSuccessfulSync': null,
      };
    }
  }
}