import 'dart:ui' show Color;

import 'package:sky_app/core/models/image_sizes.dart';
import 'package:sky_app/core/extensions/date_time_extensions.dart';

/// Etkinliğin başvuruya göre durumu (bkz. [EventModel.phase]).
enum EventPhase {
  /// Yayında ve bitmemiş: başvuru alınıyor.
  open,

  /// Yayında, bitmemiş ama başvuru kapalı: elle kapatılmış ya da son
  /// başvuru tarihi geçmiş.
  closed,

  ended,

  /// Henüz yayınlanmamış; yalnızca düzenleyebilenler görüyor.
  draft,

  /// İptal edildi; görünür kalıyor.
  cancelled,
}

class EventModel {
  final String id;
  final String name;
  final String coverImageUrl;
  final String description;
  final String location;
  final String startDate;
  final String endDate;
  final String formUrl;
  final bool active;

  /// Sahip ekip: Keycloak grup adı (`MOBILAB`, `GECEKODU`); yetkiler buna göre.
  final String ownerTeam;

  static const Set<String> _clubWideTeams = {'YK', 'DK'};

  /// YK ve DK'nin etkinlikleri kulüp adına olduğu için "SKY LAB" yazıyor;
  /// yetki hesapları yine [ownerTeam]'e bakıyor.
  String get ownerLabel =>
      _clubWideTeams.contains(ownerTeam) ? 'SKY LAB' : ownerTeam;

  EventModel({
    required this.id,
    required this.name,
    required this.coverImageUrl,
    required this.description,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.formUrl,
    required this.active,
    required this.ownerTeam,
    this.linkedin = '',
    this.seasonId = '',
    this.coverImageId = '',
    this.capacity = 0,
    this.ranked = false,
    this.prizeInfo = '',
    this.attendanceRule = '',
    this.attendanceRatio,
    this.doorStaffIds = const [],
    this.coverColors = const [],
    this.coverImageSizes = ImageSizes.none,
    this.status = '',
    this.cancelReason = '',
    this.registrationOpen,
    this.registrationClosed = false,
  });

  final String linkedin;

  /// Bağlı olduğu sezonun id'si; sezona bağlanmamışsa boş.
  final String seasonId;

  // Aşağıdakiler arayüzde gösterilmiyor; düzenlemede aynen geri gönderiliyor.

  /// Kapak görselinin medya id'si; kapak yoksa boş.
  final String coverImageId;

  /// Kontenjan; 0 sınırsız.
  final int capacity;
  final bool ranked;
  final String prizeInfo;

  /// Sertifika için katılım kuralı (`none`, `once`, `ratio`).
  final String attendanceRule;
  final double? attendanceRatio;

  /// Kapı görevlilerinin id'leri; güncellemede gönderilmiyor, core listeyi
  /// olduğu gibi bırakıyor.
  final List<String> doorStaffIds;

  /// Core'un yüklemede hesapladığı zemin renkleri (`CoverColorExtractor`'ın Go
  /// karşılığı); boşsa cihazda hesaplanıyor.
  final List<Color> coverColors;

  /// Kapağın küçük boyutları; renk paleti ve kimlik için asıl adres
  /// ([coverImageUrl]) kullanılıyor.
  final ImageSizes coverImageSizes;

  /// Core'un etkinlik durumu: `draft`, `published`, `cancelled`. Alan gelmezse
  /// yayında sayılıyor.
  final String status;

  final String cancelReason;

  /// Core'un hesapladığı başvuru durumu: yayında, bitmemiş, elle kapatılmamış
  /// ve son tarihi geçmemiş. Eski yanıtta `null`; o zaman [active]'e bakılıyor.
  final bool? registrationOpen;

  /// Elle kapatılmış mı; formdaki "Başvurular açık" anahtarı bunun tersi.
  final bool registrationClosed;

  bool get isDraft => status == 'draft';

  bool get isCancelled => status == 'cancelled';

  /// Core'un `active` kuralıyla aynı: bitiş `endDate`, yoksa başlangıçtan
  /// [_undatedEndsAfter] sonra. Tarihsiz etkinlik hiç bitmiyor.
  bool get hasEnded {
    final end = endDateTime ?? startDateTime?.add(_undatedEndsAfter);
    return end != null && !end.isAfter(DateTime.now());
  }

  static const Duration _undatedEndsAfter = Duration(hours: 24);

  /// Başvuruya göre durum; detaydaki durum satırı ve katılım butonu bundan.
  /// Açık mı sorusunu core'un `registrationOpen`'ı cevaplıyor.
  EventPhase get phase {
    if (isCancelled) return EventPhase.cancelled;
    if (isDraft) return EventPhase.draft;
    if (registrationOpen ?? active) return EventPhase.open;
    return hasEnded ? EventPhase.ended : EventPhase.closed;
  }

  String get coverCardUrl => coverImageSizes.cardOr(coverImageUrl);

  String get coverPageUrl => coverImageSizes.pageOr(coverImageUrl);

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      linkedin: json['linkedin'] as String? ?? '',
      seasonId: json['seasonId'] as String? ?? '',
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      coverImageUrl: _absoluteImageUrl(json['coverImageUrl'] as String?),
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      formUrl: json['formUrl'] as String? ?? '',
      active: json['active'] as bool? ?? false,
      ownerTeam: json['ownerTeam'] as String? ?? '',
      coverImageId: json['coverImageId'] as String? ?? '',
      capacity: (json['capacity'] as num?)?.toInt() ?? 0,
      ranked: json['ranked'] as bool? ?? false,
      prizeInfo: json['prizeInfo'] as String? ?? '',
      attendanceRule: json['attendanceRule'] as String? ?? '',
      attendanceRatio: (json['attendanceRatio'] as num?)?.toDouble(),
      doorStaffIds: [
        for (final id in json['doorStaffIds'] as List<dynamic>? ?? const [])
          if (id is String) id,
      ],
      coverColors: [
        for (final hex in json['coverColors'] as List<dynamic>? ?? const [])
          ?_parseHex(hex),
      ],
      coverImageSizes: ImageSizes.fromJson(json['coverImageSizes']),
      status: json['status'] as String? ?? '',
      cancelReason: json['cancelReason'] as String? ?? '',
      registrationOpen: json['registrationOpen'] as bool?,
      registrationClosed: json['registrationClosed'] == true,
    );
  }

  static const String _cdnBase = 'https://cdn.yildizskylab.com/';

  /// Core tam CDN adresi veriyor; eski kayıtlardaki göreli anahtar
  /// (`images/<uuid>`) CDN'e bağlanıyor.
  static String _absoluteImageUrl(String? value) {
    if (value == null || value.isEmpty) return '';
    if (value.startsWith('http')) return value;
    return '$_cdnBase${value.startsWith('/') ? value.substring(1) : value}';
  }

  static DateTime? _parse(String value) => ApiDateTime.parse(value);

  /// `#8a602d` → [Color]; biçim bozuksa `null`.
  static Color? _parseHex(Object? value) {
    if (value is! String) return null;
    final hex = value.startsWith('#') ? value.substring(1) : value;
    if (hex.length != 6) return null;
    final rgb = int.tryParse(hex, radix: 16);
    return rgb == null ? null : Color(0xFF000000 | rgb);
  }

  DateTime? get startDateTime => _parse(startDate);

  DateTime? get endDateTime => _parse(endDate);

  /// Bitişi geçmemiş etkinlikler "yaklaşan"; başlangıç baz alınsaydı çok günlük
  /// etkinlik sürerken düşerdi. Tarih okunamıyorsa listelenmiyor.
  bool get isUpcoming {
    final reference = endDateTime ?? startDateTime;
    if (reference == null) return false;
    return !reference.isBefore(DateTime.now());
  }

  String get formattedDate {
    final date = startDateTime;
    if (date == null) return startDate;
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String get formattedTime {
    final date = startDateTime;
    return date == null ? '' : _clock(date);
  }

  static const List<String> _months = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  static const List<String> _weekdays = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar',
  ];

  static String _clock(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';

  bool get isMultiDay {
    final start = startDateTime;
    final end = endDateTime;
    if (start == null || end == null) return false;
    return start.year != end.year ||
        start.month != end.month ||
        start.day != end.day;
  }

  /// Detaydaki okunur tarih: "14 Ağustos Cuma"; çok günlükte aralık ("14 – 16
  /// Ağustos 2026"), gün adı orada anlamsız.
  String get formattedDayLabel {
    final start = startDateTime;
    if (start == null) return '';

    final end = endDateTime;
    if (isMultiDay && end != null) {
      if (start.month == end.month && start.year == end.year) {
        return '${start.day} – ${end.day} ${_months[end.month - 1]} ${end.year}';
      }
      return '${start.day} ${_months[start.month - 1]} – '
          '${end.day} ${_months[end.month - 1]} ${end.year}';
    }

    return '${start.day} ${_months[start.month - 1]} '
        '${_weekdays[start.weekday - 1]}';
  }

  /// "10:00 – 18:00". Bitiş yoksa ya da etkinlik günlere yayılıyorsa yalnız
  /// başlangıç; aralık yanıltıcı olurdu.
  String get formattedTimeRange {
    final start = startDateTime;
    if (start == null) return '';

    final end = endDateTime;
    if (end == null || isMultiDay) return _clock(start);

    return '${_clock(start)} – ${_clock(end)}';
  }
}
