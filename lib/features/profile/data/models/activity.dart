import 'package:flutter/widgets.dart';
import 'package:sky_app/features/profile/data/models/feedback_link.dart';

/// Profildeki "Aktivitelerim" listesinin tek öğesi.
class Activity {
  const Activity({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.dateTime,
    this.feedback = const [],
  });

  /// Aktivitenin konusu: etkinlik, eğitim ya da ekip adı.
  final String title;

  /// Ne olduğu ("Ekibe katıldın", "Sertifikanı aldın").
  final String description;

  /// [AppIcons] içindeki ikon adı.
  final String icon;

  /// Solundaki kutunun rengi; aktivite türünü ayırt ediyor.
  final Color color;

  final DateTime dateTime;

  /// Katıldığı etkinliğin geri bildirim formları; yoksa boş.
  final List<FeedbackLink> feedback;

  /// Doldurulmamış form sayısı.
  int get pendingFeedback => feedback.where((link) => !link.answered).length;
}
