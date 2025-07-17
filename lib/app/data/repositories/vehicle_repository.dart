import 'package:get/get.dart';
import '../models/vehicle_model.dart';
import '../providers/db_provider.dart';

class VehicleRepository {
  final DbProvider _dbProvider = Get.find<DbProvider>();
  
  // Get all vehicles
  Future<List<VehicleModel>> getAllVehicles() async {
    final List<Map<String, dynamic>> maps = await _dbProvider.getAll('vehicle_master');
    return List.generate(maps.length, (i) {
      return VehicleModel.fromMap(maps[i]);
    });
  }
  
  // Get active vehicles
  Future<List<VehicleModel>> getActiveVehicles() async {
    final List<Map<String, dynamic>> maps = await _dbProvider.getActiveVehicles();
    return List.generate(maps.length, (i) {
      return VehicleModel.fromMap(maps[i]);
    });
  }
  
  // Get vehicle by id
  Future<VehicleModel?> getVehicleById(int id) async {
    final Map<String, dynamic>? map = await _dbProvider.getById('vehicle_master', id);
    if (map != null) {
      return VehicleModel.fromMap(map);
    }
    return null;
  }
  
  // Get vehicle by number
  Future<VehicleModel?> getVehicleByNumber(String vehicleNumber) async {
    final List<Map<String, dynamic>> maps = await _dbProvider.getAll(
      'vehicle_master',
      where: 'vehicle_number = ?',
      whereArgs: [vehicleNumber],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return VehicleModel.fromMap(maps.first);
    }
    return null;
  }
  
  // Insert vehicle
  Future<int> insertVehicle(VehicleModel vehicle) async {
    return await _dbProvider.insert('vehicle_master', vehicle.toMap());
  }
  
  // Update vehicle
  Future<int> updateVehicle(VehicleModel vehicle) async {
    return await _dbProvider.update('vehicle_master', vehicle.toMap(), vehicle.id!);
  }
  
  // Delete vehicle
  Future<int> deleteVehicle(int id) async {
    return await _dbProvider.delete('vehicle_master', id);
  }
  
  // Toggle vehicle active status
  Future<int> toggleVehicleActiveStatus(int id, bool isActive) async {
    return await _dbProvider.update(
      'vehicle_master',
      {
        'is_active': isActive ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      id,
    );
  }
  
  // Search vehicles by number
  Future<List<VehicleModel>> searchVehiclesByNumber(String query) async {
    final List<Map<String, dynamic>> maps = await _dbProvider.getAll(
      'vehicle_master',
      where: 'vehicle_number LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'vehicle_number ASC',
    );
    return List.generate(maps.length, (i) {
      return VehicleModel.fromMap(maps[i]);
    });
  }
  
  // Search vehicles by owner
  Future<List<VehicleModel>> searchVehiclesByOwner(String query) async {
    final List<Map<String, dynamic>> maps = await _dbProvider.getAll(
      'vehicle_master',
      where: 'owner_name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'owner_name ASC',
    );
    return List.generate(maps.length, (i) {
      return VehicleModel.fromMap(maps[i]);
    });
  }
}

