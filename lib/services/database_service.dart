import 'package:sqflite/sqflite.dart';
import '../core/database/app_database.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/gen_ui_response.dart';

class DatabaseService {
  Future<Database> get _db async => await AppDatabase.instance.database;

  Future<List<Product>> filterProducts({
    String? category,
    String? brand,
    double? maxPrice,
    double? minPrice,
    String? keyword,
  }) async {
    final db = await _db;
    final List<String> whereClauses = ['is_active = 1'];
    final List<dynamic> whereArgs = [];

    if (category != null && category.isNotEmpty) {
      whereClauses.add('category LIKE ?');
      whereArgs.add('%$category%');
    }
    if (brand != null && brand.isNotEmpty) {
      whereClauses.add('brand LIKE ?');
      whereArgs.add('%$brand%');
    }
    if (maxPrice != null && maxPrice > 0) {
      whereClauses.add('price <= ?');
      whereArgs.add(maxPrice);
    }
    if (minPrice != null && minPrice > 0) {
      whereClauses.add('price >= ?');
      whereArgs.add(minPrice);
    }
    if (keyword != null && keyword.isNotEmpty) {
      whereClauses.add('(name LIKE ? OR description LIKE ?)');
      whereArgs.add('%$keyword%');
      whereArgs.add('%$keyword%');
    }

    final whereString = whereClauses.join(' AND ');
    final maps = await db.query(
      'products',
      where: whereString,
      whereArgs: whereArgs,
      orderBy: 'price ASC',
    );

    return maps.map((e) => Product.fromMap(e)).toList();
  }

  Future<ChartData> getCategoryStats({required bool isSalesMetric, String chartType = 'bar'}) async {
    final db = await _db;
    final column = isSalesMetric ? 'bought_count' : 'total_stock';
    final title = isSalesMetric ? 'Кількість куплених по категоріях' : 'Залишки на складі по категоріях';

    final result = await db.rawQuery('''
      SELECT category, SUM($column) as total 
      FROM products 
      WHERE is_active = 1 
      GROUP BY category
    ''');

    final labels = <String>[];
    final values = <double>[];

    for (final row in result) {
      labels.add(row['category'] as String);
      values.add(((row['total'] as num?) ?? 0).toDouble());
    }

    return ChartData(
      title: title,
      chartType: chartType,
      labels: labels,
      values: values,
    );
  }

  Future<List<Product>> getAllProducts() async {
    final db = await _db;
    final maps = await db.query('products', where: 'is_active = 1');
    return maps.map((e) => Product.fromMap(e)).toList();
  }

  Future<List<Product>> getProductsByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final db = await _db;
    final placeholders = List.filled(ids.length, '?').join(',');
    final maps = await db.query('products', where: 'id IN ($placeholders)', whereArgs: ids);
    return maps.map((e) => Product.fromMap(e)).toList();
  }

  Future<int> createOrder(OrderModel order) async {
    final db = await _db;
    return await db.transaction((txn) async {
      final orderId = await txn.insert('orders', order.toMap());
      for (final item in order.items) {
        await txn.rawUpdate('''
          UPDATE products 
          SET bought_count = bought_count + ?, 
              total_stock = total_stock - ? 
          WHERE id = ?
        ''', [item.quantity, item.quantity, item.productId]);
      }
      return orderId;
    });
  }

  Future<List<OrderModel>> getAllOrders() async {
    final db = await _db;
    final maps = await db.query('orders', orderBy: 'id DESC');
    return maps.map((e) => OrderModel.fromMap(e)).toList();
  }

  Future<List<OrderModel>> getPendingOrders() async {
    final db = await _db;
    final maps = await db.query('orders', where: 'status = ?', whereArgs: ['Очікує'], orderBy: 'id DESC');
    return maps.map((e) => OrderModel.fromMap(e)).toList();
  }

  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    final db = await _db;
    await db.update('orders', {'status': newStatus}, where: 'id = ?', whereArgs: [orderId]);
  }
}