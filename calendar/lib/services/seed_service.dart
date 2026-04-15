import 'package:calender/database/database_service.dart';
import 'package:calender/services/category_db_service.dart';
import 'package:calender/services/task_db_service.dart';

class SeedService {
  /// Chỉ thêm mock data nếu user chưa có task nào
  static Future<void> seedIfEmpty(String userId) async {
    final existing = await TaskDbService.getListTasks(userId);
    if (existing.isNotEmpty) return;

    // ── 1. Tạo danh mục mẫu ─────────────────────────────────────────
    final catWork = await CategoryDbService.createCategory(
      userId: userId,
      name: 'Công việc',
      description: 'Các task liên quan đến công việc',
      color: '2E86C1',
    );
    final catPersonal = await CategoryDbService.createCategory(
      userId: userId,
      name: 'Cá nhân',
      description: 'Hoạt động cá nhân',
      color: '28B463',
    );
    final catStudy = await CategoryDbService.createCategory(
      userId: userId,
      name: 'Học tập',
      description: 'Lịch học và ôn tập',
      color: '8E44AD',
    );

    // ── 2. Tạo task mẫu ─────────────────────────────────────────────
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final tasks = [
      // Hôm nay
      _TaskSeed(
        name: 'Họp nhóm dự án',
        from: today.add(const Duration(hours: 9)),
        to: today.add(const Duration(hours: 10)),
        catId: catWork,
        color: '2E86C1',
      ),
      _TaskSeed(
        name: 'Review code sprint 3',
        from: today.add(const Duration(hours: 14)),
        to: today.add(const Duration(hours: 15, minutes: 30)),
        catId: catWork,
        color: '2E86C1',
      ),
      _TaskSeed(
        name: 'Tập gym',
        from: today.add(const Duration(hours: 18)),
        to: today.add(const Duration(hours: 19)),
        catId: catPersonal,
        color: '28B463',
      ),
      // Ngày mai
      _TaskSeed(
        name: 'Ôn thi môn Lập trình Mobile',
        from: today.add(const Duration(days: 1, hours: 8)),
        to: today.add(const Duration(days: 1, hours: 11)),
        catId: catStudy,
        color: '8E44AD',
      ),
      _TaskSeed(
        name: 'Gặp mentor',
        from: today.add(const Duration(days: 1, hours: 15)),
        to: today.add(const Duration(days: 1, hours: 16)),
        catId: catWork,
        color: '2E86C1',
      ),
      // Ngày kia
      _TaskSeed(
        name: 'Nộp báo cáo tuần',
        from: today.add(const Duration(days: 2, hours: 9)),
        to: today.add(const Duration(days: 2, hours: 9, minutes: 30)),
        catId: catWork,
        color: '2E86C1',
      ),
      _TaskSeed(
        name: 'Sinh nhật bạn thân',
        from: today.add(const Duration(days: 2)),
        to: today.add(const Duration(days: 2, hours: 23, minutes: 59)),
        catId: catPersonal,
        color: '28B463',
        isAllDay: true,
      ),
      // Hôm qua (để test "quá hạn")
      _TaskSeed(
        name: 'Nộp assignment Flutter',
        from: today.subtract(const Duration(days: 1, hours: -8)),
        to: today.subtract(const Duration(days: 1, hours: -10)),
        catId: catStudy,
        color: '8E44AD',
      ),
    ];

    for (final t in tasks) {
      await TaskDbService.createTask(
        userId: userId,
        categoryId: t.catId,
        eventName: t.name,
        from: t.from.toIso8601String(),
        to: t.to.toIso8601String(),
        background: t.color,
        isAllDay: t.isAllDay,
      );
    }
  }

  /// Xóa toàn bộ data của user (dùng khi cần reset)
  static Future<void> clearAll(String userId) async {
    final db = await DatabaseService.database;
    await db.delete('tasks', where: 'userId = ?', whereArgs: [int.tryParse(userId)]);
    await db.delete('categories', where: 'userId = ?', whereArgs: [int.tryParse(userId)]);
    await db.delete('notifications');
  }
}

class _TaskSeed {
  final String name;
  final DateTime from;
  final DateTime to;
  final int catId;
  final String color;
  final bool isAllDay;

  const _TaskSeed({
    required this.name,
    required this.from,
    required this.to,
    required this.catId,
    required this.color,
    this.isAllDay = false,
  });
}
