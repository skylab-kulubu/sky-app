class NotificationModel {
  final String title;
  final String description;
  final String content;
  final bool isRead;
  final DateTime dateTime;

  NotificationModel({
    required this.title,
    required this.description,
    required this.content,
    this.isRead = false,
    required this.dateTime,
  });
}
