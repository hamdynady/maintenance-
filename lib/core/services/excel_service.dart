import 'dart:io';
import 'package:excel/excel.dart';
import 'database_helper.dart';
import 'dart:developer' as developer;
import 'package:path_provider/path_provider.dart';

// Service class for handling Excel data import
class ExcelService {
  // Database helper instance for database operations
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Main method to import data from Excel file
  Future<void> importExcelData() async {
    try {
      developer.log('Starting Excel data import...');

      // Get the Excel file from application documents directory
      final directory = await getApplicationDocumentsDirectory();
      final excelFile = File('${directory.path}/SREENFRESH.xlsx');

      // Check if file exists
      if (!await excelFile.exists()) {
        throw Exception('Excel file not found at ${excelFile.path}');
      }

      // Read and decode Excel file
      final bytes = await excelFile.readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.tables[excel.tables.keys.first]!;

      // Get column headers
      final headers =
          sheet.rows[0].map((cell) => cell?.value.toString()).toList();

      // Find column indices by header names
      final brandIndex = headers.indexOf('BRAND');
      final productIndex = headers.indexOf('Brand Code');
      final subProductIndex = headers.indexOf('Group Code');
      final modelIndex = headers.indexOf('Item Code');
      final arabicDescIndex = headers.indexOf('Item Name');
      final englishDescIndex = headers.indexOf('Item F Name');
      final manufacturerIndex = headers.indexOf('FACTORY');

      // Validate required columns
      if (brandIndex == -1 ||
          productIndex == -1 ||
          subProductIndex == -1 ||
          modelIndex == -1) {
        throw Exception('Required columns not found in Excel file');
      }

      // Create maps to track unique values
      final Map<String, int> brandMap = {}; // BRAND -> brand_id
      final Map<String, int> productMap = {}; // PRODUCT -> product_id
      final Map<String, int> subProductMap =
          {}; // SUB_PRODUCT -> sub_product_id
      final Map<String, int> modelMap = {}; // MODEL -> model_id

      // Get database instance
      final db = await _dbHelper.database;

      // Start a transaction for bulk operations
      await db.transaction((txn) async {
        // Process brands first
        final uniqueBrands = <String>{};
        for (var i = 1; i < sheet.rows.length; i++) {
          final row = sheet.rows[i];
          if (row.isEmpty) continue;

          final brand = row[brandIndex]?.value.toString();
          if (brand != null && !uniqueBrands.contains(brand)) {
            uniqueBrands.add(brand);
            final id = await txn.insert('brands', {'name': brand});
            brandMap[brand] = id;
          }
        }

        // Process products
        final uniqueProducts = <String>{};
        for (var i = 1; i < sheet.rows.length; i++) {
          final row = sheet.rows[i];
          if (row.isEmpty) continue;

          final brand = row[brandIndex]?.value.toString();
          final product = row[productIndex]?.value.toString();
          if (brand != null &&
              product != null &&
              !uniqueProducts.contains(product)) {
            uniqueProducts.add(product);
            final brandId = brandMap[brand];
            if (brandId != null) {
              final id = await txn.insert('products', {
                'brand_id': brandId,
                'name': product,
              });
              productMap[product] = id;
            }
          }
        }

        // Process sub-products
        final uniqueSubProducts = <String>{};
        for (var i = 1; i < sheet.rows.length; i++) {
          final row = sheet.rows[i];
          if (row.isEmpty) continue;

          final product = row[productIndex]?.value.toString();
          final subProduct = row[subProductIndex]?.value.toString();
          if (product != null &&
              subProduct != null &&
              !uniqueSubProducts.contains(subProduct)) {
            uniqueSubProducts.add(subProduct);
            final productId = productMap[product];
            if (productId != null) {
              final id = await txn.insert('sub_products', {
                'product_id': productId,
                'name': subProduct,
              });
              subProductMap[subProduct] = id;
            }
          }
        }

        // Process models
        final uniqueModels = <String>{};
        for (var i = 1; i < sheet.rows.length; i++) {
          final row = sheet.rows[i];
          if (row.isEmpty) continue;

          final subProduct = row[subProductIndex]?.value.toString();
          final model = row[modelIndex]?.value.toString();
          if (subProduct != null &&
              model != null &&
              !uniqueModels.contains(model)) {
            uniqueModels.add(model);
            final subProductId = subProductMap[subProduct];
            if (subProductId != null) {
              await txn.insert('models', {
                'sub_product_id': subProductId,
                'name': model,
                'arabic_description': arabicDescIndex != -1
                    ? row[arabicDescIndex]?.value.toString()
                    : null,
                'english_description': englishDescIndex != -1
                    ? row[englishDescIndex]?.value.toString()
                    : null,
                'manufacturer': manufacturerIndex != -1
                    ? row[manufacturerIndex]?.value.toString()
                    : null,
              });
              modelMap[model] = 1;
            }
          }
        }
      });

      developer.log('Data import completed successfully');
    } catch (e) {
      developer.log('Error importing Excel data: $e', error: e);
      rethrow;
    }
  }
}
