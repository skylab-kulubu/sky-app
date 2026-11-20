import 'package:flutter/widgets.dart';
import 'package:sky_app/features/profile/data/models/feedback_link.dart';

class Activity {
  const Activity({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.dateTime,
    this.feedback = const [],
  });

  /// Konusu: etkinlik ya da ekip adı.
  final String title;

  /// Ne olduğu ("Ekibe katıldın", "Sertifikanı aldın").
  final String description;

  /// [AppIcons] içindeki ikon adı.
  final String icon;

  /// Solundaki dairenin rengi; aktivite türünü ayırt ediyor.
  final Color color;

  final DateTime dateTime;

  final List<FeedbackLink> feedback;

  int get pendingFeedback => feedback.where((link) => !link.answered).length;
}
