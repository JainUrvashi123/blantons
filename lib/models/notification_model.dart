class NotificationModel {
  final String notificationId;
  final String userId;
  final String designId;
  final String title;
  final String message;
  final String notificationType;
  final String isRead; // "0" for unread, "1" for read
  final String createDate;

  NotificationModel({
    required this.notificationId,
    required this.userId,
    required this.designId,
    required this.title,
    required this.message,
    required this.notificationType,
    required this.isRead,
    required this.createDate,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notification_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      designId: json['design_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      notificationType: json['notification_type']?.toString() ?? '',
      isRead: json['is_read']?.toString() ?? '0',
      createDate: json['create_date']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notification_id': notificationId,
      'user_id': userId,
      'design_id': designId,
      'title': title,
      'message': message,
      'notification_type': notificationType,
      'is_read': isRead,
      'create_date': createDate,
    };
  }
}
