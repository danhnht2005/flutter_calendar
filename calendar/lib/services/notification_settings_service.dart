import 'package:calender/database/database_service.dart';
import 'package:calender/models/notification_settings_model.dart';

class NotificationSettingsService {
  static const String _table = 'notification_settings';

  static Future<NotificationSettingsModel> getSettings(String userId) async {
    final db = await DatabaseService.database;
    final rows = await db.query(
      _table,
      where: 'userId = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (rows.isEmpty) {
      // Tạo cài đặt mặc định nếu chưa có
      final defaultSettings = NotificationSettingsModel(
        userId: userId,
        updatedAt: DateTime.now().toIso8601String(),
      );
      final id = await db.insert(_table, defaultSettings.toMap()..remove('id'));
      return defaultSettings..id = id;
    }
    return NotificationSettingsModel.fromMap(rows.first);
  }

  static Future<void> saveSettings(NotificationSettingsModel settings) async {
    final db = await DatabaseService.database;
    final updated = settings.copyWith();
    if (settings.id == null) {
      await db.insert(_table, updated.toMap()..remove('id'));
    } else {
      await db.update(
        _table,
        updated.toMap(),
        where: 'id = ?',
        whereArgs: [settings.id],
      );
    }
  }
}
