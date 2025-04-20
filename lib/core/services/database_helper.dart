import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:developer' as developer;

// DatabaseHelper is a singleton class that manages the SQLite database
class DatabaseHelper {
  // Singleton instance of DatabaseHelper
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  // Database instance that will be reused
  static Database? _database;

  // Factory constructor to return the singleton instance
  factory DatabaseHelper() => _instance;

  // Private constructor for singleton pattern
  DatabaseHelper._internal();

  // Getter for the database instance
  Future<Database> get database async {
    // If database is already initialized, return it
    if (_database != null) return _database!;
    // Otherwise initialize it
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    // Get the path for the database file
    String path = join(await getDatabasesPath(), 'maintenance.db');
    developer.log('Initializing database at path: $path');
    // Open or create the database
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // Create all necessary tables when the database is first created
  Future<void> _onCreate(Database db, int version) async {
    developer.log('Creating database tables...');

    // Create brands table to store brand information
    await db.execute('''
      CREATE TABLE brands(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_brands_name ON brands(name)');
    developer.log('Created brands table');

    // Create products table to store product information
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        brand_id INTEGER,
        name TEXT NOT NULL,
        FOREIGN KEY (brand_id) REFERENCES brands (id)
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_products_brand_id ON products(brand_id)',
    );
    await db.execute('CREATE INDEX idx_products_name ON products(name)');
    developer.log('Created products table');

    // Create sub_products table to store sub-product information
    await db.execute('''
      CREATE TABLE sub_products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER,
        name TEXT NOT NULL,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_sub_products_product_id ON sub_products(product_id)',
    );
    await db.execute(
      'CREATE INDEX idx_sub_products_name ON sub_products(name)',
    );
    developer.log('Created sub_products table');

    // Create models table to store model information
    await db.execute('''
      CREATE TABLE models(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sub_product_id INTEGER,
        name TEXT NOT NULL,
        arabic_description TEXT,
        english_description TEXT,
        manufacturer TEXT,
        FOREIGN KEY (sub_product_id) REFERENCES sub_products (id)
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_models_sub_product_id ON models(sub_product_id)',
    );
    await db.execute('CREATE INDEX idx_models_name ON models(name)');
    developer.log('Created models table');

    // Create maintenance_records table to store maintenance records
    await db.execute('''
      CREATE TABLE maintenance_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phone_number TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        brand_id INTEGER,
        product_id INTEGER,
        sub_product_id INTEGER,
        model_id INTEGER,
        maintenance_date TEXT,
        status TEXT,
        spare_parts TEXT,
        report TEXT,
        report_image TEXT,
        arabic_name TEXT,
        english_name TEXT,
        manufacturer TEXT,
        FOREIGN KEY (brand_id) REFERENCES brands (id),
        FOREIGN KEY (product_id) REFERENCES products (id),
        FOREIGN KEY (sub_product_id) REFERENCES sub_products (id),
        FOREIGN KEY (model_id) REFERENCES models (id)
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_maintenance_phone ON maintenance_records(phone_number)',
    );
    await db.execute(
      'CREATE INDEX idx_maintenance_date ON maintenance_records(maintenance_date)',
    );
    await db.execute(
      'CREATE INDEX idx_maintenance_status ON maintenance_records(status)',
    );
    developer.log('Created maintenance_records table');
  }

  // Method to verify database structure and data
  Future<void> verifyDatabase() async {
    final db = await database;
    // Get all tables in the database
    final tables = await db.query(
      'sqlite_master',
      where: 'type = ?',
      whereArgs: ['table'],
    );
    developer.log(
      'Database tables: ${tables.map((t) => t['name']).join(', ')}',
    );

    // Check the number of records in each table
    for (var table in ['brands', 'products', 'sub_products', 'models']) {
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $table'),
      );
      developer.log('$table count: $count');
    }
  }

  // Methods for CRUD operations will be added here
}
