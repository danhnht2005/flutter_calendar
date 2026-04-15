import 'package:calender/database/database_service.dart';
import 'package:calender/models/notification_model.dart';
import 'package:calender/models/task.dart';

class NotificationDbService {
  static const String _table = 'notifications';

  static Future<List<NotificationModel>> getAll() async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> rows = await db.query(
      _table,
      orderBy: 'createdAt DESC',
    );
    return rows.map((r) => NotificationModel.fromMap(r)).toList();
  }

  static Future<int> getUnreadCount() async {
    final db = await DatabaseService.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_table WHERE isRead = 0',
    );
    return result.first['count'] as int? ?? 0;
  }

  static Future<void> insert(NotificationModel notification) async {
    final db = await DatabaseService.database;
    await db.insert(
      _table,
      notification.toMap()..remove('id'),
    );
  }

  static Future<void> markAsRead(int id) async {
    final db = await DatabaseService.database;
    await db.update(
      _table,
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> markAllAsRead() async {
    final db = await DatabaseService.database;
    await db.update(_table, {'isRead': 1});
  }

  static Future<void> delete(int id) async {
    final db = await DatabaseService.database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteAll() async {
    final db = await DatabaseService.database;
    await db.delete(_table);
  }

  /// Tự động tạo thông báo cho các task sắp đến trong 24 giờ tới
  static Future<void> syncFromTasks(List<Task> tasks) async {
    final db = await DatabaseService.database;
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(hours: 24));

    for (final task in tasks) {
      if (task.id == null || task.from == null) continue;
      final fromDate = DateTime.tryParse(task.from!);
      if (fromDate == null) continue;

      // Chỉ xử lý task sắp tới trong 24 giờ
      if (fromDate.isAfter(now) && fromDate.isBefore(tomorrow)) {
        // Kiểm tra đã có thông báo cho task này chưa
        final existing = await db.query(
          _table,
          where: 'taskId = ?',
          whereArgs: [task.id],
          limit: 1,
        );
        if (existing.isEmpty) {
          final hoursLeft = fromDate.difference(now).inHours;
          final minutesLeft = fromDate.difference(now).inMinutes % 60;
          String timeLabel;
          if (hoursLeft > 0) {
            timeLabel = '$hoursLeft giờ ${minutesLeft > 0 ? '$minutesLeft phút' : ''}';
          } else {
            timeLabel = '$minutesLeft phút';
          }

          final notification = NotificationModel(
            taskId: task.id,
            title: task.eventName ?? 'Sự kiện sắp diễn ra',
            message: 'Sự kiện sẽ bắt đầu sau $timeLabel',
            type: 'reminder',
            isRead: false,
            scheduledAt: task.from,
            createdAt: DateTime.now().toIso8601String(),
          );
          await insert(notification);
        }
      }
    }
  }
}
