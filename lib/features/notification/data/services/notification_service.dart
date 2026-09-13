import 'package:sky_app/features/notification/data/models/notification_model.dart';

/// Bildirim listesi.
///
/// Backend'de henüz bildirim endpoint'i yok; o gelene kadar liste boş ve
/// sayfa boş durumunu gösteriyor. Sahte veri konmuyor, kullanıcı gerçek
/// sanmasın diye. Bağlantı işi için bkz. GitHub issue (bildirimler/push).
class NotificationService {
  static final List<NotificationModel> list = [];
}
