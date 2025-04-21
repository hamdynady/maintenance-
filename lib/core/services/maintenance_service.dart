import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

class MaintenanceService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<Database> get database async => await _dbHelper.database;

  Future<int> createMaintenanceRecord({
    required String phoneNumber,
    required String name,
    required String address,
    required int brandId,
    required int productId,
    required int subProductId,
    required int modelId,
    required DateTime maintenanceDate,
    required String status,
    required String spareParts,
    required String report,
    required String arabicName,
    required String englishName,
    required String manufacturer,
    File? reportImage,
  }) async {
    final db = await database;

    String? imagePath;
    if (reportImage != null) {
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}${path.extension(reportImage.path)}';
      final savedImage = await reportImage.copy('${directory.path}/$fileName');
      imagePath = savedImage.path;
    }

    return await db.insert('maintenance_records', {
      'phone_number': phoneNumber,
      'name': name,
      'address': address,
      'brand_id': brandId,
      'product_id': productId,
      'sub_product_id': subProductId,
      'model_id': modelId,
      'maintenance_date': maintenanceDate.toIso8601String(),
      'status': status,
      'spare_parts': spareParts,
      'report': report,
      'report_image': imagePath,
      'arabic_name': arabicName,
      'english_name': englishName,
      'manufacturer': manufacturer,
    });
  }

  Future<void> updateMaintenanceRecord({
    required int id,
    required String phoneNumber,
    required String name,
    required String address,
    required int brandId,
    required int productId,
    required int subProductId,
    required int modelId,
    required DateTime maintenanceDate,
    required String status,
    required String spareParts,
    required String report,
    required String arabicName,
    required String englishName,
    required String manufacturer,
    File? reportImage,
  }) async {
    final db = await database;

    String? imagePath;
    if (reportImage != null) {
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}${path.extension(reportImage.path)}';
      final savedImage = await reportImage.copy('${directory.path}/$fileName');
      imagePath = savedImage.path;
    }

    await db.update(
      'maintenance_records',
      {
        'phone_number': phoneNumber,
        'name': name,
        'address': address,
        'brand_id': brandId,
        'product_id': productId,
        'sub_product_id': subProductId,
        'model_id': modelId,
        'maintenance_date': maintenanceDate.toIso8601String(),
        'status': status,
        'spare_parts': spareParts,
        'report': report,
        'report_image': imagePath,
        'arabic_name': arabicName,
        'english_name': englishName,
        'manufacturer': manufacturer,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getBrands() async {
    final db = await database;
    return await db.query('brands', distinct: true);
  }

  Future<List<Map<String, dynamic>>> getProducts(int brandId) async {
    final db = await database;
    return await db.query(
      'products',
      where: 'brand_id = ?',
      whereArgs: [brandId],
      orderBy: 'name',
    );
  }

  Future<List<Map<String, dynamic>>> getSubProducts(int productId) async {
    final db = await database;
    return await db.query(
      'sub_products',
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'name',
    );
  }

  Future<List<Map<String, dynamic>>> getModels(int subProductId) async {
    final db = await database;
    return await db.query(
      'models',
      where: 'sub_product_id = ?',
      whereArgs: [subProductId],
      orderBy: 'name',
    );
  }

  Future<Map<String, dynamic>?> getModelDetails(int modelId) async {
    final db = await database;
    final results = await db.query(
      'models',
      where: 'id = ?',
      whereArgs: [modelId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> deleteMaintenanceRecord(int id) async {
    final db = await database;
    await db.delete(
      'maintenance_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
