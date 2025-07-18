import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';

import '../../../core/base/base_controller.dart';
import '../../../core/services/sync_service.dart';
import '../../../data/models/sync_item_model.dart';
import '../../../data/repositories/sync_repository.dart';

class SyncController extends BaseController {
  final SyncService _syncService = Get.find<SyncService>();
  final SyncRepository _syncRepository = Get.find<SyncRepository>();

  // Observable properties
  final RxBool isOnline = false.obs;
  final RxBool isSyncing = false.obs;
  final RxDouble syncProgress = 0.0.obs;
  final RxString syncStatus = ''.obs;
  final RxList<SyncItemModel> syncItems = <SyncItemModel>[].obs;
  final RxString selectedFilter = 'all'.obs;
  final Rx<DateTime?> lastSyncTime = Rx<DateTime?>(null);

  // Sync statistics
  final RxInt pendingCount = 0.obs;
  final RxInt syncedCount = 0.obs;
  final RxInt failedCount = 0.obs;
  final RxInt totalCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeSync();
  }

  /// Initialize sync
  void _initializeSync() {
    // Bind to sync service observables
    ever(_syncService.isOnline, (value) => isOnline.value = value);
    ever(_syncService.isSyncing, (value) => isSyncing.value = value);
    ever(_syncService.syncProgress, (value) => syncProgress.value = value);
    ever(_syncService.currentSyncStatus, (value) => syncStatus.value = value);
    ever(_syncService.pendingSyncItems, (value) => pendingCount.value = value);

    // Set initial values
    isOnline.value = _syncService.isOnline.value;
    isSyncing.value = _syncService.isSyncing.value;
    syncProgress.value = _syncService.syncProgress.value;
    syncStatus.value = _syncService.currentSyncStatus.value;
    pendingCount.value = _syncService.pendingSyncItems.value;

    // Load sync items and stats
    loadSyncItems();
    loadSyncStats();
  }

  /// Load sync items based on the selected filter
  Future<void> loadSyncItems() async {
    isLoading.value = true;

    try {
      switch (selectedFilter.value) {
        case 'pending':
          syncItems.value = await _syncRepository.getSyncItemsByStatus(SyncStatus.pending);
          break;
        case 'synced':
          syncItems.value = await _syncRepository.getSyncItemsByStatus(SyncStatus.synced);
          break;
        case 'failed':
          syncItems.value = await _syncRepository.getSyncItemsByStatus(SyncStatus.failed);
          break;
        case 'all':
        default:
          syncItems.value = await _syncRepository.getAllSyncItems();
          break;
      }
    } catch (e) {
      _logger.error('Failed to load sync items', e);
      showErrorMessage('Failed to load sync items');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load sync statistics
  Future<void> loadSyncStats() async {
    try {
      final stats = await _syncService.getSyncStats();
      
      pendingCount.value = stats['pending'] as int;
      syncedCount.value = stats['synced'] as int;
      failedCount.value = stats['failed'] as int;
      totalCount.value = stats['total'] as int;
      
      lastSyncTime.value = stats['lastSuccessfulSync'] as DateTime?;
    } catch (e) {
      _logger.error('Failed to load sync stats', e);
    }
  }

  /// Change the filter for sync items
  void changeFilter(String? filter) {
    if (filter != null && filter != selectedFilter.value) {
      selectedFilter.value = filter;
      loadSyncItems();
    }
  }

  /// Sync data
  Future<void> syncData() async {
    if (isSyncing.value) {
      showInfoMessage('Sync already in progress');
      return;
    }

    if (!isOnline.value) {
      showWarningMessage('You are offline. Cannot sync data.');
      return;
    }

    final result = await runAsyncOperation(
      () => _syncService.syncData(),
      showLoading: false,
      showError: true,
    );

    if (result == true) {
      showSuccessMessage('Sync completed successfully');
    } else {
      showWarningMessage('Sync completed with errors');
    }

    // Reload data
    loadSyncItems();
    loadSyncStats();
  }

  /// Reset failed items
  Future<void> resetFailedItems() async {
    final confirmed = await showConfirmationDialog(
      title: 'Reset Failed Items',
      message: 'Are you sure you want to reset all failed sync items to pending?',
    );

    if (!confirmed) return;

    final result = await runAsyncOperation(
      () => _syncRepository.resetAllFailedItems(),
      showLoading: true,
      showError: true,
    );

    if (result != null && result > 0) {
      showSuccessMessage('Reset $result failed items to pending');
      loadSyncItems();
      loadSyncStats();
    } else {
      showInfoMessage('No failed items to reset');
    }
  }

  /// Export sync data
  Future<void> exportSyncData() async {
    final filePath = await runAsyncOperation(
      () => _syncService.exportSyncData(),
      showLoading: true,
      showError: true,
    );

    if (filePath != null) {
      showSuccessMessage('Sync data exported to $filePath');
    } else {
      showWarningMessage('No sync data to export');
    }
  }

  /// Import sync data
  Future<void> importSyncData() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final filePath = result.files.first.path;
      if (filePath == null) {
        showWarningMessage('Invalid file path');
        return;
      }

      final success = await runAsyncOperation(
        () => _syncService.importSyncData(filePath),
        showLoading: true,
        showError: true,
      );

      if (success == true) {
        showSuccessMessage('Sync data imported successfully');
        loadSyncItems();
        loadSyncStats();
      } else {
        showWarningMessage('Failed to import sync data');
      }
    } catch (e) {
      _logger.error('Failed to import sync data', e);
      showErrorMessage('Failed to import sync data');
    }
  }

  /// Clear synced items
  Future<void> clearSyncedItems() async {
    final confirmed = await showConfirmationDialog(
      title: 'Clear Synced Items',
      message: 'Are you sure you want to delete all synced items?',
    );

    if (!confirmed) return;

    final result = await runAsyncOperation(
      () => _syncRepository.deleteSyncedItems(),
      showLoading: true,
      showError: true,
    );

    if (result != null && result > 0) {
      showSuccessMessage('Deleted $result synced items');
      loadSyncItems();
      loadSyncStats();
    } else {
      showInfoMessage('No synced items to delete');
    }
  }

  /// View sync item details
  void viewSyncItemDetails(SyncItemModel item) {
    Get.dialog(
      AlertDialog(
        title: Text('${item.entityType} - ${item.action}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem('ID', item.id.toString()),
              _buildDetailItem('Entity Type', item.entityType),
              _buildDetailItem('Entity ID', item.entityId),
              _buildDetailItem('Action', item.action),
              _buildDetailItem('Status', item.status.toString().split('.').last),
              _buildDetailItem('Priority', item.priority.toString()),
              _buildDetailItem('Created At', item.createdAt.toString()),
              if (item.syncedAt != null)
                _buildDetailItem('Synced At', item.syncedAt.toString()),
              _buildDetailItem('Attempts', item.attempts.toString()),
              if (item.errorMessage != null)
                _buildDetailItem('Error', item.errorMessage!),
              const SizedBox(height: 16),
              const Text(
                'Data:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(item.data.toString()),
              ),
            ],
          ),
        ),
        actions: [
          if (item.status == SyncStatus.failed)
            TextButton(
              onPressed: () {
                Get.back();
                retrySyncItem(item);
              },
              child: const Text('Retry'),
            ),
          TextButton(
            onPressed: () {
              Get.back();
              deleteSyncItem(item);
            },
            child: const Text('Delete'),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  /// Retry a failed sync item
  Future<void> retrySyncItem(SyncItemModel item) async {
    if (item.status != SyncStatus.failed) {
      showWarningMessage('Only failed items can be retried');
      return;
    }

    final result = await runAsyncOperation(
      () => _syncRepository.resetFailedItem(item.id!),
      showLoading: true,
      showError: true,
    );

    if (result != null && result > 0) {
      showSuccessMessage('Item reset for retry');
      loadSyncItems();
      loadSyncStats();
    } else {
      showWarningMessage('Failed to reset item');
    }
  }

  /// Delete a sync item
  Future<void> deleteSyncItem(SyncItemModel item) async {
    final confirmed = await showConfirmationDialog(
      title: 'Delete Sync Item',
      message: 'Are you sure you want to delete this sync item?',
    );

    if (!confirmed) return;

    final result = await runAsyncOperation(
      () => _syncRepository.deleteSyncItem(item.id!),
      showLoading: true,
      showError: true,
    );

    if (result != null && result > 0) {
      showSuccessMessage('Item deleted');
      loadSyncItems();
      loadSyncStats();
    } else {
      showWarningMessage('Failed to delete item');
    }
  }

  @override
  void retryLastOperation() {
    loadSyncItems();
    loadSyncStats();
  }
}

