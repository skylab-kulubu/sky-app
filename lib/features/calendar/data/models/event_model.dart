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
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }
}
