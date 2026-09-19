import 'package:sky_app/core/extensions/date_time_extensions.dart';

const List<String> _months = [
  'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', //
  'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
];

String _clock(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:'
    '${d.minute.toString().padLeft(2, '0')}';

/// Etkinlik takvimindeki gün (core `EventDay`). Etkinliğin programı günlere,
/// günler oturumlara ayrılıyor.
class EventDay {
  const EventDay({
    required this.id,
    required this.eventId,
    required this.name,
    this.startDate,
    this.endDate,
  });

  factory EventDay.fromJson(Map<String, dynamic> json) {
    return EventDay(
      id: json['id'] as String? ?? '',
      eventId: json['eventId'] as String? ?? '',
      name: (json['name'] as String? ?? '').trim(),
      startDate: ApiDateTime.parse(json['startDate'] as String?),
      endDate: ApiDateTime.parse(json['endDate'] as String?),
    );
  }

  final String id;
  final String eventId;
  final String name;
  final DateTime? startDate;
  final DateTime? endDate;

  /// "20 Eylül"; tarih yoksa boş.
  String get dateLabel {
    final date = startDate;
    if (date == null) return '';
    return '${date.day} ${_months[date.month - 1]}';
  }

  /// Programda günün başlığı: ad varsa ad, yoksa tarih.
  String get label => name.isNotEmpty ? name : dateLabel;

  Map<String, dynamic> toJson() => {
    'eventId': eventId,
    'name': name,
    'startDate': startDate?.toApiString(),
    'endDate': endDate?.toApiString(),
  };
}

/// Bir gündeki tek oturum (konuşma, atölye …). Yoklama oturum başına
/// alınıyor.
class EventSession {
  const EventSession({
    required this.id,
    required this.dayId,
    required this.title,
    required this.speakerName,
    required this.sessionType,
    required this.cancelled,
    this.speakerLinkedin = '',
    this.description = '',
    this.orderIndex = 0,
    this.startTime,
    this.endTime,
  });

  factory EventSession.fromJson(Map<String, dynamic> json) {
    return EventSession(
      id: json['id'] as String? ?? '',
      dayId: json['eventDayId'] as String? ?? '',
      title: (json['title'] as String? ?? '').trim(),
      speakerName: (json['speakerName'] as String? ?? '').trim(),
      speakerLinkedin: json['speakerLinkedin'] as String? ?? '',
      description: json['description'] as String? ?? '',
      orderIndex: (json['orderIndex'] as num?)?.toInt() ?? 0,
      sessionType: json['sessionType'] as String? ?? '',
      cancelled: json['cancelled'] == true,
      startTime: ApiDateTime.parse(json['startTime'] as String?),
      endTime: ApiDateTime.parse(json['endTime'] as String?),
    );
  }

  final String id;
  final String dayId;
  final String title;

  /// Core'da zorunlu.
  final String speakerName;
  final String speakerLinkedin;
  final String description;
  final int orderIndex;

  /// [types] anahtarlarından biri; core'da zorunlu.
  final String sessionType;
  final bool cancelled;
  final DateTime? startTime;
  final DateTime? endTime;

  /// Yönetim panelindeki oturum türleri ve Türkçe adları.
  static const Map<String, String> types = {
    'PRESENTATION': 'Sunum',
    'WORKSHOP': 'Atölye',
    'PANEL': 'Panel',
    'KEYNOTE': 'Açılış konuşması',
    'NETWORKING': 'Networking',
    'CTF': 'CTF',
    'HACKATHON': 'Hackathon',
    'JAM': 'Jam',
    'OTHER': 'Diğer',
  };

  String get typeLabel => types[sessionType] ?? sessionType;

  /// Şu an bu oturumun saatleri içinde miyiz.
  bool get isNow {
    final start = startTime;
    final end = endTime;
    if (start == null || end == null) return false;
    final now = DateTime.now();
    return !now.isBefore(start) && now.isBefore(end);
  }

  /// "14:00 – 15:30"; saat yoksa boş.
  String get timeRange {
    final start = startTime;
    if (start == null) return '';
    final end = endTime;
    return end == null ? _clock(start) : '${_clock(start)} – ${_clock(end)}';
  }

  /// Oluşturma ve güncelleme gövdesi; core güncellemede bütün alanları
  /// yazıyor, formda olmayanlar da (açıklama, sıra) aynen gönderiliyor.
  Map<String, dynamic> toJson() => {
    'eventDayId': dayId,
    'title': title,
    'speakerName': speakerName,
    'speakerLinkedin': speakerLinkedin,
    'description': description,
    'startTime': startTime?.toApiString(),
    'endTime': endTime?.toApiString(),
    'orderIndex': orderIndex,
    'sessionType': sessionType,
    'cancelled': cancelled,
  };
}

/// Programın bir günü ve o günün oturumları (saate göre sıralı).
class ScheduleDay {
  const ScheduleDay({required this.day, required this.sessions});

  final EventDay day;
  final List<EventSession> sessions;
}
