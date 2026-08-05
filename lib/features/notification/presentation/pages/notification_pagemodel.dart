part of 'notification_page.dart';

abstract class NotificationPagemodel extends State<NotificationPage> {
  static const double _listVerticalPadding = 8.0;
  static const double _itemGap = 4.0;

  List<NotificationModel> get notifications => NotificationService.list;

  /// Bildirimi açar ve okundu olarak işaretler.
  ///
  /// Liste şimdilik mock veri olduğu için işaretleme doğrudan
  /// [NotificationService.list] üzerinde yapılıyor; API bağlandığında
  /// bunun yerine servise "okundu" isteği gidecek.
  void openNotification(int index) {
    final item = notifications[index];

    if (!item.isRead) {
      setState(() {
        NotificationService.list[index] = item.copyWith(isRead: true);
      });
    }

    NotificationDetailSheet.show(context, item);
  }
}
