import 'package:flutter/widgets.dart';

/// Profildeki "Aktivitelerim" listesinin tek öğesi.
class Activity {
  const Activity({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.dateTime,
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
}
