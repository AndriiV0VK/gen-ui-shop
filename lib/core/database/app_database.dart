import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'seed_data.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gen_ui_shop.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {

    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        category TEXT NOT NULL,
        brand TEXT NOT NULL,
        total_stock INTEGER NOT NULL,
        bought_count INTEGER NOT NULL DEFAULT 0,
        rating REAL NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        description TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_name TEXT NOT NULL,
        customer_email TEXT NOT NULL,
        customer_password TEXT NOT NULL,
        address TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        items_json TEXT NOT NULL,
        total_price REAL NOT NULL,
        order_date TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'Очікує'
      )
    ''');

    final batch = db.batch();
    for (final product in initialProducts) {
      batch.insert('products', product.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }
}