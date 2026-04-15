import 'package:calender/database/database_service.dart';
import 'package:calender/models/task.dart';

class TaskDbService {
  static const String _table = 'tasks';

  // ─── Lấy danh sách task theo user ──────────────────────────────────────────
  static Future<List<Task>> getListTasks(String userId) async {
    final db = await DatabaseService.database;
    final rows = await db.query(
      _table,
      where: 'userId = ?',
      whereArgs: [int.tryParse(userId)],
      orderBy: 'fromDate ASC',
    );
    return rows.map(_rowToTask).toList();
  }

  // ─── Lấy một task theo ID ──────────────────────────────────────────────────
  static Future<Task?> getTask(String id) async {
    final db = await DatabaseService.database;
    final rows = await db.query(
      _table,
      where: 'id = ?',
      whereArgs: [int.tryParse(id)],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _rowToTask(rows.first);
  }

  // ─── Tạo task mới ──────────────────────────────────────────────────────────
  static Future<int> createTask({
    required String userId,
    int? categoryId,
    required String eventName,
    required String from,
    required String to,
    String background = 'B8B8B8',
    bool isAllDay = false,
  }) async {
    final db = await DatabaseService.database;
    return await db.insert(_table, {
      'userId': int.tryParse(userId),
      'categoryId': categoryId,
      'eventName': eventName,
      'fromDate': from,
      'toDate': to,
      'background': background,
      'isAllDay': isAllDay ? 1 : 0,
    });
  }

  // ─── Cập nhật task ─────────────────────────────────────────────────────────
  static Future<int> editTask({
    required String id,
    int? categoryId,
    required String eventName,
    required String from,
    required String to,
    String background = 'B8B8B8',
    bool isAllDay = false,
  }) async {
    final db = await DatabaseService.database;
    return await db.update(
      _table,
      {
        'categoryId': categoryId,
        'eventName': eventName,
        'fromDate': from,
        'toDate': to,
        'background': background,
        'isAllDay': isAllDay ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [int.tryParse(id)],
    );
  }

  // ─── Xóa task ──────────────────────────────────────────────────────────────
  static Future<int> deleteTask(String id) async {
    final db = await DatabaseService.database;
    return await db.delete(
      _table,
      where: 'id = ?',
      whereArgs: [int.tryParse(id)],
    );
  }

  // ─── Helper ────────────────────────────────────────────────────────────────
  static Task _rowToTask(Map<String, dynamic> row) {
    return Task(
      id: row['id'].toString(),
      categoryId: row['categoryId'] as int?,
      eventName: row['eventName'] as String?,
      from: row['fromDate'] as String?,
      to: row['toDate'] as String?,
      background: row['background'] as String?,
      isAllDay: (row['isAllDay'] as int? ?? 0) == 1,
    );
  }
}
