import 'package:get/get.dart';
import '../../core/base/base_repository.dart';
import '../../core/error/app_error.dart';
import '../../core/error/error_handler.dart';
import '../../core/services/database_service.dart';
import '../../core/services/logger_service.dart';
import '../models/material_model.dart';

class MaterialRepository extends BaseRepository {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final LoggerService _logger = Get.find<LoggerService>();
  final ErrorHandler _errorHandler = Get.find<ErrorHandler>();
  
  final String _tableName = 'materials';
  
  Future<List<MaterialModel>> getAllMaterials() async {
    try {
      final db = await _databaseService.database;
      final result = await db.query(_tableName);
      
      return result.map((map) => MaterialModel.fromMap(map)).toList();
    } catch (e, stackTrace) {
      final error = await _errorHandler.handleError(e, stackTrace);
      _logger.error('Failed to get all materials', e);
      throw error;
    }
  }
  
  Future<MaterialModel> getMaterialById(int id) async {
    try {
      final db = await _databaseService.database;
      final result = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (result.isEmpty) {
        throw NotFoundError(
          message: 'Material with ID $id not found',
          stackTrace: StackTrace.current,
        );
      }
      
      return MaterialModel.fromMap(result.first);
    } catch (e, stackTrace) {
      final error = await _errorHandler.handleError(e, stackTrace);
      _logger.error('Failed to get material by ID: $id', e);
      throw error;
    }
  }
  
  Future<List<MaterialModel>> getMaterialsByType(String type) async {
    try {
      final db = await _databaseService.database;
      final result = await db.query(
        _tableName,
        where: 'type = ?',
        whereArgs: [type],
      );
      
      return result.map((map) => MaterialModel.fromMap(map)).toList();
    } catch (e, stackTrace) {
      final error = await _errorHandler.handleError(e, stackTrace);
      _logger.error('Failed to get materials by type: $type', e);
      throw error;
    }
  }
  
  Future<int> createMaterial(MaterialModel material) async {
    try {
      final db = await _databaseService.database;
      final now = DateTime.now();
      
      final materialMap = material.copyWith(
        createdAt: now,
        updatedAt: now,
      ).toMap();
      
      final id = await db.insert(_tableName, materialMap);
      _logger.info('Created material with ID: $id');
      
      // Add to sync queue
      await addToSyncQueue(
        entityType: 'material',
        entityId: id.toString(),
        action: 'create',
        data: materialMap,
      );
      
      return id;
    } catch (e, stackTrace) {
      final error = await _errorHandler.handleError(e, stackTrace);
      _logger.error('Failed to create material', e);
      throw error;
    }
  }
  
  Future<void> updateMaterial(MaterialModel material) async {
    try {
      if (material.id == null) {
        throw ValidationError(
          message: 'Material ID cannot be null for update operation',
          stackTrace: StackTrace.current,
        );
      }
      
      final db = await _databaseService.database;
      final now = DateTime.now();
      
      final materialMap = material.copyWith(
        updatedAt: now,
      ).toMap();
      
      final rowsAffected = await db.update(
        _tableName,
        materialMap,
        where: 'id = ?',
        whereArgs: [material.id],
      );
      
      if (rowsAffected == 0) {
        throw NotFoundError(
          message: 'Material with ID ${material.id} not found',
          stackTrace: StackTrace.current,
        );
      }
      
      _logger.info('Updated material with ID: ${material.id}');
      
      // Add to sync queue
      await addToSyncQueue(
        entityType: 'material',
        entityId: material.id.toString(),
        action: 'update',
        data: materialMap,
      );
    } catch (e, stackTrace) {
      final error = await _errorHandler.handleError(e, stackTrace);
      _logger.error('Failed to update material', e);
      throw error;
    }
  }
  
  Future<void> deleteMaterial(int id) async {
    try {
      final db = await _databaseService.database;
      
      // First, check if the material exists
      final material = await getMaterialById(id);
      
      final rowsAffected = await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (rowsAffected == 0) {
        throw NotFoundError(
          message: 'Material with ID $id not found',
          stackTrace: StackTrace.current,
        );
      }
      
      _logger.info('Deleted material with ID: $id');
      
      // Add to sync queue
      await addToSyncQueue(
        entityType: 'material',
        entityId: id.toString(),
        action: 'delete',
        data: material.toMap(),
      );
    } catch (e, stackTrace) {
      final error = await _errorHandler.handleError(e, stackTrace);
      _logger.error('Failed to delete material', e);
      throw error;
    }
  }
}

