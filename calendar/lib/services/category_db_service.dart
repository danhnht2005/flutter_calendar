import 'package:calender/database/database_service.dart';
import 'package:calender/models/categories.dart';

class CategoryDbService {
  static const String _table = 'categories';

  /// Danh sách màu cố định (thay thế color_service từ JSON Server)
  static const List<Map<String, String>> colorOptions = [
    {'name': 'Xám',        'color': 'B8B8B8'},
    {'name': 'Đỏ cam',     'color': 'FF5733'},
    {'name': 'Vàng',       'color': 'FFC300'},
    {'name': 'Xanh lá',    'color': '28B463'},
    {'name': 'Xanh dương', 'color': '2E86C1'},
    {'name': 'Tím',        'color': '8E44AD'},
    {'name': 'Đỏ',         'color': 'E74C3C'},
    {'name': 'Xanh ngọc',  'color': '1ABC9C'},
    {'name': 'Cam',        'color': 'F39C12'},
    {'name': 'Hồng',       'color': 'E91E63'},
  ];

  // ─── Lấy danh sách danh mục theo user ──────────────────────────────────────
  static Future<List<Categories>> getListCategories(String userId) async {
    final db = await DatabaseService.database;
    final rows = await db.query(
      _table,
      where: 'userId = ? AND isActive = 1',
      whereArgs: [int.tryParse(userId)],
      orderBy: 'id DESC',
    );
    return rows.map(_rowToCategory).toList();
  }

  // ─── Lấy một danh mục theo ID ──────────────────────────────────────────────
  static Future<Categories?> getCategory(String id) async {
    final db = await DatabaseService.database;
    final rows = await db.query(
      _table,
      where: 'id = ?',
      whereArgs: [int.tryParse(id)],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _rowToCategory(rows.first);
  }

  // ─── Tạo danh mục mới ──────────────────────────────────────────────────────
  static Future<int> createCategory({
    required String userId,
    required String name,
    String description = '',
    String color = 'B8B8B8',
  }) async {
    final db = await DatabaseService.database;
    return await db.insert(_table, {
      'userId': int.tryParse(userId),
      'name': name,
      'description': description,
      'color': color,
      'isActive': 1,
    });
  }

  // ─── Cập nhật danh mục ─────────────────────────────────────────────────────
  static Future<int> editCategory({
    required String id,
    required String name,
    String description = '',
    required String color,
  }) async {
    final db = await DatabaseService.database;
    return await db.update(
      _table,
      {'name': name, 'description': description, 'color': color},
      where: 'id = ?',
      whereArgs: [int.tryParse(id)],
    );
  }

  // ─── Xóa danh mục (soft delete) ────────────────────────────────────────────
  static Future<int> deleteCategory(String id) async {
    final db = await DatabaseService.database;
    return await db.update(
      _table,
      {'isActive': 0},
      where: 'id = ?',
      whereArgs: [int.tryParse(id)],
    );
  }

  // ─── Helper ────────────────────────────────────────────────────────────────
  static Categories _rowToCategory(Map<String, dynamic> row) {
    return Categories(
      id: row['id'].toString(),
      userId: row['userId'].toString(),
      name: row['name'] as String?,
      description: row['description'] as String?,
      color: row['color'] as String?,
      isActive: (row['isActive'] as int? ?? 1) == 1,
    );
  }
}
