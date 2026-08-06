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
  final String typeName;

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
    required this.typeName,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      coverImageUrl: json['coverImageUrl'] as String? ?? '',
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      formUrl: json['formUrl'] as String? ?? '',
      active: json['active'] as bool? ?? false,
      typeName: json['type']['name'] as String? ?? '',
    );
  }

  static DateTime? _parse(String value) {
    if (value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

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

  List<DateTime> get eventDays {
    if (startDate.isEmpty || endDate.isEmpty) return [];
    try {
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);

      final days = <DateTime>[];
      var current = DateTime(start.year, start.month, start.day);
      final last = DateTime(end.year, end.month, end.day);

      while (!current.isAfter(last)) {
        days.add(current);
        current = current.add(const Duration(days: 1));
      }
      return days;
    } catch (e) {
      return [];
    }
  }

  String get formattedDate {
    if (startDate.isEmpty) return '';
    try {
      final date = DateTime.parse(startDate);
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } catch (e) {
      return startDate;
    }
  }

  String get formattedTime {
    if (startDate.isEmpty) return '';
    try {
      final date = DateTime.parse(startDate);
      return _clock(date);
    } catch (e) {
      return '';
    }
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
