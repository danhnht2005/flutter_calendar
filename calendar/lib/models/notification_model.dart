class NotificationModel {
  int? id;
  String? taskId;
  String title;
  String? message;
  String type; // 'reminder' | 'info' | 'warning'
  bool isRead;
  String? scheduledAt;
  String createdAt;

  NotificationModel({
    this.id,
    this.taskId,
    required this.title,
    this.message,
    this.type = 'reminder',
    this.isRead = false,
    this.scheduledAt,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'title': title,
      'message': message,
      'type': type,
      'isRead': isRead ? 1 : 0,
      'scheduledAt': scheduledAt,
      'createdAt': createdAt,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as int?,
      taskId: map['taskId'] as String?,
      title: map['title'] as String,
      message: map['message'] as String?,
      type: map['type'] as String? ?? 'reminder',
      isRead: (map['isRead'] as int? ?? 0) == 1,
      scheduledAt: map['scheduledAt'] as String?,
      createdAt: map['createdAt'] as String,
    );
  }
}
