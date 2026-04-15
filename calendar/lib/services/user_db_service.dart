import 'package:calender/database/database_service.dart';
import 'package:calender/helpers/generrate_teken.dart';
import 'package:calender/models/user.dart';
import 'package:sqflite/sqflite.dart';

class UserDbService {
  static const String _table = 'users';

  // ─── Đăng nhập ─────────────────────────────────────────────────────────────
  static Future<User?> login(String email, String password) async {
    final db = await DatabaseService.database;
    final rows = await db.query(
      _table,
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _rowToUser(rows.first);
  }

  // ─── Đăng ký ───────────────────────────────────────────────────────────────
  /// Trả về User nếu thành công, null nếu email đã tồn tại.
  static Future<User?> register(
    String fullName,
    String email,
    String password,
  ) async {
    final db = await DatabaseService.database;
    try {
      final token = generateToken();
      final id = await db.insert(_table, {
        'fullName': fullName,
        'email': email,
        'password': password,
        'token': token,
      });
      return User(
        id: id.toString(),
        fullName: fullName,
        email: email,
        password: password,
        token: token,
      );
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) return null; // Email đã tồn tại
      rethrow;
    }
  }

  // ─── Lấy user theo ID ──────────────────────────────────────────────────────
  static Future<User?> getUser(String id) async {
    final db = await DatabaseService.database;
    final rows = await db.query(
      _table,
      where: 'id = ?',
      whereArgs: [int.tryParse(id)],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _rowToUser(rows.first);
  }

  // ─── Helper ────────────────────────────────────────────────────────────────
  static User _rowToUser(Map<String, dynamic> row) {
    return User(
      id: row['id'].toString(),
      fullName: row['fullName'] as String?,
      email: row['email'] as String?,
      password: row['password'] as String?,
      token: row['token'] as String?,
    );
  }
}
