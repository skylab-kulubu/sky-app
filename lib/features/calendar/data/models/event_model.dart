import 'package:sky_app/core/extensions/date_time_extensions.dart';

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

  /// Etkinliği düzenleyen ekip: Keycloak grup adı (`MOBILAB`, `GECEKODU`).
  /// Yetkiler bu ekibe göre veriliyor.
  final String ownerTeam;

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
  });

  /// Etkinliğin LinkedIn gönderisi; düzenleme formu için.
  final String linkedin;

  /// Bağlı olduğu sezonun id'si; sezona bağlanmamışsa boş.
  final String seasonId;

  /// Core `EventResponse`'u (`/v1/events`).
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
    );
  }

  static const String _cdnBase = 'https://cdn.yildizskylab.com/';

  /// Core kapak adresini tam CDN URL'si olarak veriyor; eski kayıtlarda
  /// kalmış göreli bir depolama anahtarı (`images/<uuid>`) gelirse CDN'e
  /// bağlanıyor.
  static String _absoluteImageUrl(String? value) {
    if (value == null || value.isEmpty) return '';
    if (value.startsWith('http')) return value;
    return '$_cdnBase${value.startsWith('/') ? value.substring(1) : value}';
  }

  static DateTime? _parse(String value) => ApiDateTime.parse(value);

  DateTime? get startDateTime => _parse(startDate);

  DateTime? get endDateTime => _parse(endDate);

  /// Bitişi henüz geçmemiş etkinlikler "yaklaşan" sayılır.
  ///
  /// Başlangıç değil bitiş baz alınıyor; aksi hâlde birden çok gün süren bir
  /// etkinlik daha devam ederken listeden düşerdi. Tarih okunamıyorsa etkinlik
  /// listelenmez — belirsiz bir kaydı yaklaşan gibi göstermek yanıltıcı olur.
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

  /// Etkinlik birden fazla güne yayılıyor mu.
  bool get isMultiDay {
    final start = startDateTime;
    final end = endDateTime;
    if (start == null || end == null) return false;
    return start.year != end.year ||
        start.month != end.month ||
        start.day != end.day;
  }

  /// Detay sayfasındaki okunur tarih: "14 Ağustos Cuma".
  ///
  /// Birden çok güne yayılan etkinlikte aralık veriliyor ("14 – 16 Ağustos
  /// 2026"); gün adı o durumda anlamını yitiriyor.
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

  /// "10:00 – 18:00". Bitiş saati yoksa ya da etkinlik günlere yayılıyorsa
  /// yalnızca başlangıç saati; aralık o durumda yanıltıcı olurdu.
  String get formattedTimeRange {
    final start = startDateTime;
    if (start == null) return '';

    final end = endDateTime;
    if (end == null || isMultiDay) return _clock(start);

    return '${_clock(start)} – ${_clock(end)}';
  }
}
