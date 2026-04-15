import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'calendar_app.db';
  static const int _dbVersion = 1;

  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    // Lưu trong thư mục databases mặc định của thiết bị
    // Android: /data/data/<package>/databases/calendar/
    // iOS:     <sandbox>/databases/calendar/
    final String base = await getDatabasesPath();
    final String calendarDir = p.join(base, 'calendar');
    final Directory dir = Directory(calendarDir);
    if (!dir.existsSync()) dir.createSync(recursive: true);
    final String dbPath = p.join(calendarDir, _dbName);
    return await openDatabase(dbPath, version: _dbVersion, onCreate: _onCreate);
  }

  static Future<void> _onCreate(Database db, int version) async {
    // ─── users ─────────────────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE users (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT    NOT NULL,
        email    TEXT    NOT NULL UNIQUE,
        password TEXT    NOT NULL,
        token    TEXT    NOT NULL
      )
    ''');

    // ─── categories ────────────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE categories (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        userId      INTEGER NOT NULL,
        name        TEXT    NOT NULL,
        description TEXT    DEFAULT '',
        color       TEXT    DEFAULT 'B8B8B8',
        isActive    INTEGER DEFAULT 1,
        FOREIGN KEY (userId) REFERENCES users(id)
      )
    ''');

    // ─── tasks ─────────────────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE tasks (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        userId     INTEGER NOT NULL,
        categoryId INTEGER,
        eventName  TEXT    NOT NULL,
        fromDate   TEXT    NOT NULL,
        toDate     TEXT    NOT NULL,
        background TEXT    DEFAULT 'B8B8B8',
        isAllDay   INTEGER DEFAULT 0,
        FOREIGN KEY (userId)     REFERENCES users(id),
        FOREIGN KEY (categoryId) REFERENCES categories(id)
      )
    ''');

    // ─── notifications ─────────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE notifications (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        taskId      INTEGER,
        title       TEXT    NOT NULL,
        message     TEXT,
        type        TEXT    DEFAULT 'reminder',
        isRead      INTEGER DEFAULT 0,
        scheduledAt TEXT,
        createdAt   TEXT    NOT NULL
      )
    ''');

    // ─── notification_settings ─────────────────────────────────────────
    await db.execute('''
      CREATE TABLE notification_settings (
        id                  INTEGER PRIMARY KEY AUTOINCREMENT,
        userId              TEXT    NOT NULL UNIQUE,
        enableNotifications INTEGER DEFAULT 1,
        reminderMinutes     INTEGER DEFAULT 30,
        enableSound         INTEGER DEFAULT 1,
        enableVibration     INTEGER DEFAULT 1,
        enableQuietHours    INTEGER DEFAULT 0,
        quietHoursStart     TEXT    DEFAULT '22:00',
        quietHoursEnd       TEXT    DEFAULT '07:00',
        updatedAt           TEXT
      )
    ''');
  }

  static Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
