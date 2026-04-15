class NotificationSettingsModel {
  int? id;
  String userId;
  bool enableNotifications;
  int reminderMinutes;
  bool enableSound;
  bool enableVibration;
  bool enableQuietHours;
  String quietHoursStart;
  String quietHoursEnd;
  String? updatedAt;

  NotificationSettingsModel({
    this.id,
    required this.userId,
    this.enableNotifications = true,
    this.reminderMinutes = 30,
    this.enableSound = true,
    this.enableVibration = true,
    this.enableQuietHours = false,
    this.quietHoursStart = '22:00',
    this.quietHoursEnd = '07:00',
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'enableNotifications': enableNotifications ? 1 : 0,
      'reminderMinutes': reminderMinutes,
      'enableSound': enableSound ? 1 : 0,
      'enableVibration': enableVibration ? 1 : 0,
      'enableQuietHours': enableQuietHours ? 1 : 0,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
      'updatedAt': updatedAt,
    };
  }

  factory NotificationSettingsModel.fromMap(Map<String, dynamic> map) {
    return NotificationSettingsModel(
      id: map['id'] as int?,
      userId: map['userId'] as String,
      enableNotifications: (map['enableNotifications'] as int? ?? 1) == 1,
      reminderMinutes: map['reminderMinutes'] as int? ?? 30,
      enableSound: (map['enableSound'] as int? ?? 1) == 1,
      enableVibration: (map['enableVibration'] as int? ?? 1) == 1,
      enableQuietHours: (map['enableQuietHours'] as int? ?? 0) == 1,
      quietHoursStart: map['quietHoursStart'] as String? ?? '22:00',
      quietHoursEnd: map['quietHoursEnd'] as String? ?? '07:00',
      updatedAt: map['updatedAt'] as String?,
    );
  }

  NotificationSettingsModel copyWith({
    bool? enableNotifications,
    int? reminderMinutes,
    bool? enableSound,
    bool? enableVibration,
    bool? enableQuietHours,
    String? quietHoursStart,
    String? quietHoursEnd,
  }) {
    return NotificationSettingsModel(
      id: id,
      userId: userId,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      enableSound: enableSound ?? this.enableSound,
      enableVibration: enableVibration ?? this.enableVibration,
      enableQuietHours: enableQuietHours ?? this.enableQuietHours,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      updatedAt: DateTime.now().toIso8601String(),
    );
  }
}
