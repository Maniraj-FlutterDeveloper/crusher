import 'package:get/get.dart';
import '../../core/base/base_repository.dart';
import '../../core/error/app_error.dart';
import '../../core/error/error_handler.dart';
import '../../core/services/logger_service.dart';
import '../models/material_model.dart';
import '../providers/db_provider.dart';

class MaterialRepository extends BaseRepository {
  final DbProvider _dbProvider = Get.find<DbProvider>();
  final LoggerService _logger = Get.find<LoggerService>();
  final ErrorHandler _errorHandler = Get.find<ErrorHandler>();
  
  @override
  String get tableName => 'material_master';
  
  @override
  String get entityType => 'material';
  
  Future<List<MaterialModel>> getAllMaterials() async {
    try {
      final result = await _dbProvider.query(tableName);
      
      return result.map((map) => MaterialModel.fromMap(map)).toList();
    } catch (e, stackTrace) {
      final error = await _errorHandler.handleError(e, stackTrace);
      _logger.error('Failed to get all materials', e);
      throw error;
    }
  }
  
  Future<MaterialModel> getMaterialById(int id) async {
    try {
      final result = await _dbProvider.query(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (result.isEmpty) {
        throw BusinessError.notFound(
          entity: 'Material',
          id: id,
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
  
  Future<List<MaterialModel>> getMaterialsByType(int typeId) async {
    try {
      final result = await _dbProvider.query(
        tableName,
        where: 'material_type_id = ?',
        whereArgs: [typeId],
      );
      
      return result.map((map) => MaterialModel.fromMap(map)).toList();
    } catch (e, stackTrace) {
      final error = await _errorHandler.handleError(e, stackTrace);
      _logger.error('Failed to get materials by type: $typeId', e);
      throw error;
    }
  }
  
  Future<int> createMaterial(MaterialModel material) async {
    try {
      final now = DateTime.now();
      
      final materialMap = material.copyWith(
        createdAt: now,
        updatedAt: now,
      ).toMap();
      
      final id = await createWithSync(materialMap);
      _logger.info('Created material with ID: $id');
      
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
      
      final now = DateTime.now();
      
      final materialMap = material.copyWith(
        updatedAt: now,
      ).toMap();
      
      final rowsAffected = await updateWithSync(
        material.id.toString(),
        materialMap,
      );
      
      if (rowsAffected == 0) {
        throw BusinessError.notFound(
          entity: 'Material',
          id: material.id,
          stackTrace: StackTrace.current,
        );
      }
      
      _logger.info('Updated material with ID: ${material.id}');
    } catch (e, stackTrace) {
      final error = await _errorHandler.handleError(e, stackTrace);
      _logger.error('Failed to update material', e);
      throw error;
    }
  }
  
  Future<void> deleteMaterial(int id) async {
    try {
      // First, check if the material exists to ensure it exists
      await getMaterialById(id);
      
      final rowsAffected = await deleteWithSync(
        id.toString(),
      );
      
      if (rowsAffected == 0) {
        throw BusinessError.notFound(
          entity: 'Material',
          id: id,
          stackTrace: StackTrace.current,
        );
      }
      
      _logger.info('Deleted material with ID: $id');
    } catch (e, stackTrace) {
      final error = await _errorHandler.handleError(e, stackTrace);
      _logger.error('Failed to delete material', e);
      throw error;
    }
  }
}

