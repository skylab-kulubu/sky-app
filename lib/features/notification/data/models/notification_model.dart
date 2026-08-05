class NotificationModel {
  final String title;
  final String description;
  final String content;
  final bool isRead;
  final DateTime dateTime;

  const NotificationModel({
    required this.title,
    required this.description,
    required this.content,
    this.isRead = false,
    required this.dateTime,
  });

  /// Bildirim açılınca okundu olarak işaretlemek için kullanılır.
  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      title: title,
      description: description,
      content: content,
      isRead: isRead ?? this.isRead,
      dateTime: dateTime,
    );
  }
}
