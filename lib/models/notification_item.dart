enum NotificationType { transfer, payment, security, account, bill }

/// An in-app notification. Saved in the `notifications` Hive box.
class NotificationItem {
  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.dateTime,
    required this.type,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String message;
  final DateTime dateTime;
  final NotificationType type;
  bool isRead;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'message': message,
        'dateTime': dateTime.toIso8601String(),
        'isRead': isRead,
        'type': type.name,
      };

  factory NotificationItem.fromMap(Map<dynamic, dynamic> map) =>
      NotificationItem(
        id: map['id'] as String,
        title: map['title'] as String,
        message: map['message'] as String,
        dateTime: DateTime.parse(map['dateTime'] as String).toLocal(),
        isRead: map['isRead'] as bool? ?? false,
        type: NotificationType.values.byName(map['type'] as String),
      );
}
