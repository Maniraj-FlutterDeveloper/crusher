import 'package:get/get.dart';
import '../models/material_model.dart';
import '../providers/db_provider.dart';

class MaterialRepository {
  final DbProvider _dbProvider = Get.find<DbProvider>();
  
  // Get all materials
  Future<List<MaterialModel>> getAllMaterials() async {
    final List<Map<String, dynamic>> maps = await _dbProvider.getAll('material_master');
    return List.generate(maps.length, (i) {
      return MaterialModel.fromMap(maps[i]);
    });
  }
  
  // Get active materials
  Future<List<MaterialModel>> getActiveMaterials() async {
    final List<Map<String, dynamic>> maps = await _dbProvider.getActiveMaterials();
    return List.generate(maps.length, (i) {
      return MaterialModel.fromMap(maps[i]);
    });
  }
  
  // Get material by id
  Future<MaterialModel?> getMaterialById(int id) async {
    final Map<String, dynamic>? map = await _dbProvider.getById('material_master', id);
    if (map != null) {
      return MaterialModel.fromMap(map);
    }
    return null;
  }
  
  // Get materials by type
  Future<List<MaterialModel>> getMaterialsByType(int materialTypeId) async {
    final List<Map<String, dynamic>> maps = await _dbProvider.getAll(
      'material_master',
      where: 'material_type_id = ?',
      whereArgs: [materialTypeId],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) {
      return MaterialModel.fromMap(maps[i]);
    });
  }
  
  // Insert material
  Future<int> insertMaterial(MaterialModel material) async {
    return await _dbProvider.insert('material_master', material.toMap());
  }
  
  // Update material
  Future<int> updateMaterial(MaterialModel material) async {
    return await _dbProvider.update('material_master', material.toMap(), material.id!);
  }
  
  // Delete material
  Future<int> deleteMaterial(int id) async {
    return await _dbProvider.delete('material_master', id);
  }
  
  // Toggle material active status
  Future<int> toggleMaterialActiveStatus(int id, bool isActive) async {
    return await _dbProvider.update(
      'material_master',
      {
        'is_active': isActive ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      id,
    );
  }
  
  // Search materials by name
  Future<List<MaterialModel>> searchMaterialsByName(String query) async {
    final List<Map<String, dynamic>> maps = await _dbProvider.getAll(
      'material_master',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) {
      return MaterialModel.fromMap(maps[i]);
    });
  }
}

