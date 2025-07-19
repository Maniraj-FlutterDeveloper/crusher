import 'package:crusher_management/app/data/models/gate_entry_model.dart';
import 'package:crusher_management/app/data/models/material_size_model.dart';
import 'package:crusher_management/app/data/models/material_type_model.dart';
import 'package:crusher_management/app/data/models/user_model.dart';
import 'package:crusher_management/app/data/models/weighbridge_record_model.dart';
import 'package:get/get.dart';
import '../models/material_loading_model.dart';
import '../models/material_model.dart';
import '../providers/db_provider.dart';

class MaterialLoadingRepository {
  final DbProvider _dbProvider = Get.find<DbProvider>();
  
  // Get all material loading records
  Future<List<MaterialLoadingModel>> getAllMaterialLoadingRecords() async {
    final List<Map<String, dynamic>> maps = await _dbProvider.rawQuery('''
      SELECT ml.*, ge.*, m.*, ms.*, wu.*, u.* FROM material_loading ml
      LEFT JOIN gate_entry ge ON ml.gate_entry_id = ge.id
      LEFT JOIN material m ON ml.material_id = m.id
      LEFT JOIN material_size ms ON ml.material_size_id = ms.id
      LEFT JOIN weight_unit_type wu ON ml.weight_unit_id = wu.id
      LEFT JOIN user u ON ml.operator_id = u.id
      ORDER BY ml.created_at DESC
    ''');
    
    return maps.map((map) {
      final materialLoading = MaterialLoadingModel.fromMap({
        'id': map['id'],
        'gate_entry_id': map['gate_entry_id'],
        'material_id': map['material_id'],
        'material_size_id': map['material_size_id'],
        'quantity': map['quantity'],
        'weight_unit_id': map['weight_unit_id'],
        'purpose': map['purpose'],
        'operator_id': map['operator_id'],
        'remarks': map['remarks'],
        'status': map['status'],
        'created_at': map['created_at'],
        'updated_at': map['updated_at'],
      });
      
      // Extract gate entry data
      if (map['gate_entry_id'] != null) {
        final gateEntry = {
          'id': map['gate_entry_id'],
          'session_id': map['session_id'],
          'vehicle_id': map['vehicle_id'],
          'driver_name': map['driver_name'],
          'driver_mobile': map['driver_mobile'],
          'entry_time': map['entry_time'],
          'exit_time': map['exit_time'],
          'tare_weight': map['tare_weight'],
          'gross_weight': map['gross_weight'],
          'net_weight': map['net_weight'],
          'status': map['status'],
          'gate_pass_number': map['gate_pass_number'],
          'remarks': map['remarks'],
          'operator_id': map['operator_id'],
          'created_at': map['created_at'],
          'updated_at': map['updated_at'],
        };
        
        // Extract material data
        final material = {
          'id': map['material_id'],
          'name': map['name'],
          'code': map['code'],
          'material_type_id': map['material_type_id'],
          'rate': map['rate'],
          'tax_configuration_id': map['tax_configuration_id'],
          'is_active': map['is_active'],
          'created_at': map['created_at'],
          'updated_at': map['updated_at'],
        };
        
        // Extract material size data
        final materialSize = map['material_size_id'] != null ? {
          'id': map['material_size_id'],
          'name': map['size_name'],
          'code': map['size_code'],
          'is_active': map['size_is_active'],
          'created_at': map['size_created_at'],
          'updated_at': map['size_updated_at'],
        } : null;
        
        // Extract weight unit data
        final weightUnit = {
          'id': map['weight_unit_id'],
          'name': map['unit_name'],
          'symbol': map['unit_symbol'],
          'conversion_factor': map['conversion_factor'],
          'is_active': map['unit_is_active'],
          'created_at': map['unit_created_at'],
          'updated_at': map['unit_updated_at'],
        };
        
        // Extract operator data
        final operator = {
          'id': map['operator_id'],
          'username': map['username'],
          'name': map['user_name'],
          'email': map['email'],
          'mobile': map['mobile'],
          'is_active': map['user_is_active'],
          'last_login': map['last_login'],
          'created_at': map['user_created_at'],
          'updated_at': map['user_updated_at'],
        };
        
        return materialLoading.copyWith(
          gateEntry: GateEntryModel.fromMap(gateEntry),
          material: MaterialModel.fromMap(material),
          materialSize: materialSize != null ? MaterialSizeModel.fromMap(materialSize) : null,
          weightUnit: WeightUnitModel.fromMap(weightUnit),
          operator: UserModel.fromMap(operator),
        );
      }
      
      return materialLoading;
    }).toList();
  }
  
  // Get material loading records by gate entry
  Future<List<MaterialLoadingModel>> getMaterialLoadingRecordsByGateEntry(int gateEntryId) async {
    final List<Map<String, dynamic>> maps = await _dbProvider.query(
      'material_loading',
      where: 'gate_entry_id = ?',
      whereArgs: [gateEntryId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => MaterialLoadingModel.fromMap(map)).toList();
  }
  
  // Get material loading record by id
  Future<MaterialLoadingModel?> getMaterialLoadingRecordById(int id) async {
    final Map<String, dynamic>? map = await _dbProvider.getById('material_loading', id);
    if (map != null) {
      return MaterialLoadingModel.fromMap(map);
    }
    return null;
  }
  
  // Insert material loading record
  Future<int> insertMaterialLoadingRecord(MaterialLoadingModel materialLoading) async {
    return await _dbProvider.insert('material_loading', materialLoading.toMap());
  }
  
  // Update material loading record
  Future<int> updateMaterialLoadingRecord(MaterialLoadingModel materialLoading) async {
    return await _dbProvider.update('material_loading', materialLoading.toMap(), materialLoading.id!);
  }
  
  // Delete material loading record
  Future<int> deleteMaterialLoadingRecord(int id) async {
    return await _dbProvider.delete('material_loading', id);
  }
  
  // Get material loading records by status
  Future<List<MaterialLoadingModel>> getMaterialLoadingRecordsByStatus(String status) async {
    final List<Map<String, dynamic>> maps = await _dbProvider.query(
      'material_loading',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => MaterialLoadingModel.fromMap(map)).toList();
  }
  
  // Update material loading status
  Future<int> updateMaterialLoadingStatus(int id, String status) async {
    return await _dbProvider.update(
      'material_loading',
      {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      },
      id,
    );
  }
  
  // Get all materials
  Future<List<MaterialModel>> getAllMaterials() async {
    final List<Map<String, dynamic>> maps = await _dbProvider.query(
      'material',
      orderBy: 'name ASC',
    );
    return maps.map((map) => MaterialModel.fromMap(map)).toList();
  }
  
  // Get active materials
  Future<List<MaterialModel>> getActiveMaterials() async {
    final List<Map<String, dynamic>> maps = await _dbProvider.query(
      'material',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
    return maps.map((map) => MaterialModel.fromMap(map)).toList();
  }
  
  // Get material by id
  Future<MaterialModel?> getMaterialById(int id) async {
    final Map<String, dynamic>? map = await _dbProvider.getById('material', id);
    if (map != null) {
      return MaterialModel.fromMap(map);
    }
    return null;
  }
  
  // Get all material sizes
  Future<List<MaterialSizeModel>> getAllMaterialSizes() async {
    final List<Map<String, dynamic>> maps = await _dbProvider.query(
      'material_size',
      orderBy: 'name ASC',
    );
    return maps.map((map) => MaterialSizeModel.fromMap(map)).toList();
  }
  
  // Get active material sizes
  Future<List<MaterialSizeModel>> getActiveMaterialSizes() async {
    final List<Map<String, dynamic>> maps = await _dbProvider.query(
      'material_size',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
    return maps.map((map) => MaterialSizeModel.fromMap(map)).toList();
  }
  
  // Get material size by id
  Future<MaterialSizeModel?> getMaterialSizeById(int id) async {
    final Map<String, dynamic>? map = await _dbProvider.getById('material_size', id);
    if (map != null) {
      return MaterialSizeModel.fromMap(map);
    }
    return null;
  }
  
  // Get all material types
  Future<List<MaterialTypeModel>> getAllMaterialTypes() async {
    final List<Map<String, dynamic>> maps = await _dbProvider.query(
      'material_type',
      orderBy: 'name ASC',
    );
    return maps.map((map) => MaterialTypeModel.fromMap(map)).toList();
  }
  
  // Get active material types
  Future<List<MaterialTypeModel>> getActiveMaterialTypes() async {
    final List<Map<String, dynamic>> maps = await _dbProvider.query(
      'material_type',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
    return maps.map((map) => MaterialTypeModel.fromMap(map)).toList();
  }
  
  // Get material type by id
  Future<MaterialTypeModel?> getMaterialTypeById(int id) async {
    final Map<String, dynamic>? map = await _dbProvider.getById('material_type', id);
    if (map != null) {
      return MaterialTypeModel.fromMap(map);
    }
    return null;
  }
}

